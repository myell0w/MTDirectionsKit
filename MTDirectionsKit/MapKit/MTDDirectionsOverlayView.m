#import "MTDDirectionsOverlayView.h"
#import "MTDDirectionsOverlay.h"
#import "MTDDirectionsOverlay+MTDirectionsPrivateAPI.h"
#import "MTDRoute.h"
#import "MTDFunctions.h"
#import "MTDWaypoint.h"
#import <CoreLocation/CoreLocation.h>


#define kMTDDefaultOverlayColor         [UIColor colorWithRed:0.f green:0.25f blue:1.f alpha:1.f]
#define kMTDDefaultLineWidthFactor      1.8f
#define kMTDMinimumLineWidthFactor      0.7f
#define kMTDMaximumLineWidthFactor      3.0f


@interface MTDDirectionsOverlayView ()

@property (nonatomic, readonly) MTDDirectionsOverlay *mtd_directionsOverlay;

@end


@implementation MTDDirectionsOverlayView

@synthesize overlayColor = _overlayColor;

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithOverlay:(id<MKOverlay>)overlay {
    if ((self = [super initWithOverlay:overlay])) {
        _overlayLineWidthFactor = kMTDDefaultLineWidthFactor;
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDDirectionsOverlayView
////////////////////////////////////////////////////////////////////////

- (UIColor *)overlayColor {
    return _overlayColor ?: kMTDDefaultOverlayColor;
}

- (void)setOverlayColor:(UIColor *)overlayColor {
    if (overlayColor != _overlayColor && overlayColor != nil) {
        _overlayColor = overlayColor;
        [self setNeedsDisplay];
    }
}

- (void)setOverlayLineWidthFactor:(CGFloat)overlayLineWidthFactor {
    if (overlayLineWidthFactor >= kMTDMinimumLineWidthFactor && overlayLineWidthFactor <= kMTDMaximumLineWidthFactor) {
        _overlayLineWidthFactor = overlayLineWidthFactor;
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MKOverlayView
////////////////////////////////////////////////////////////////////////

- (void)drawMapRect:(MKMapRect)mapRect
          zoomScale:(MKZoomScale)zoomScale
          inContext:(CGContextRef)context {
    CGFloat screenScale = [UIScreen mainScreen].scale;
    CGFloat lineWidth = MKRoadWidthAtZoomScale(zoomScale) * self.overlayLineWidthFactor * screenScale;
    
    // outset the map rect by the line width so that points just outside
    // of the currently drawn rect are included in the generated path.
    MKMapRect clipRect = MKMapRectInset(mapRect, -lineWidth, -lineWidth);
    
    for (MTDRoute *route in self.mtd_directionsOverlay.routes) {
        CGPathRef path = [self mtd_newPathForPoints:route.points
                                         pointCount:route.pointCount
                                           clipRect:clipRect
                                          zoomScale:zoomScale];
        
        if (path != NULL) {
            UIColor *baseColor = self.overlayColor;

            if (route != self.mtd_directionsOverlay.activeRoute) {
                baseColor = [baseColor colorWithAlphaComponent:0.75f];
                lineWidth = MKRoadWidthAtZoomScale(zoomScale) * kMTDMinimumLineWidthFactor * screenScale;
            }
            
            UIColor *darkenedColor = MTDDarkenedColor(baseColor, 0.1f);
            
            // Setup graphics context
            CGContextSetLineCap(context, kCGLineCapRound);
            CGContextSetLineJoin(context, kCGLineJoinRound);
            
            // Draw dark path
            CGContextSaveGState(context);
            CGFloat darkPathLineWidth = lineWidth;
            CGContextSetLineWidth(context, darkPathLineWidth);
            CGContextSetFillColorWithColor(context, darkenedColor.CGColor);
            CGContextSetStrokeColorWithColor(context, darkenedColor.CGColor);
            CGContextSetShadowWithColor(context, CGSizeMake(0.f, darkPathLineWidth/10.f), darkPathLineWidth/10.f, [UIColor colorWithWhite:0.f alpha:0.4f].CGColor);
            CGContextAddPath(context, path);
            CGContextStrokePath(context);
            CGContextRestoreGState(context);
            
            // Draw normal path
            CGContextSaveGState(context);
            CGContextSetBlendMode(context, kCGBlendModeCopy);
            CGFloat normalPathLineWidth = roundf(darkPathLineWidth * 0.8f);
            CGContextSetLineWidth(context, normalPathLineWidth);
            CGContextSetStrokeColorWithColor(context, baseColor.CGColor);
            CGContextAddPath(context, path);
            CGContextStrokePath(context);
            CGContextRestoreGState(context);

            // Draw inner glow path
            CGContextSaveGState(context);
            CGFloat innerGlowPathLineWidth = roundf(darkPathLineWidth * 0.9f);
            CGContextSetLineWidth(context, innerGlowPathLineWidth);
            CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:1.f alpha:0.1f].CGColor);
            CGContextAddPath(context, path);
            CGContextStrokePath(context);
            CGContextRestoreGState(context);
            
            // Draw normal path again
            CGContextSaveGState(context);
            CGContextSetBlendMode(context, kCGBlendModeCopy);
            normalPathLineWidth = roundf(lineWidth * 0.6f);
            CGContextSetLineWidth(context, normalPathLineWidth);
            CGContextSetStrokeColorWithColor(context, [[baseColor colorWithAlphaComponent:0.7f] CGColor]);
            CGContextAddPath(context, path);
            CGContextStrokePath(context);
            CGContextRestoreGState(context);
            
            // Cleanup
            CGPathRelease(path);
        }
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

- (MTDDirectionsOverlay *)mtd_directionsOverlay {
    return (MTDDirectionsOverlay *)self.overlay;
}

- (CGPathRef)mtd_newPathForPoints:(MKMapPoint *)points
                       pointCount:(NSUInteger)pointCount
                         clipRect:(MKMapRect)mapRect
                        zoomScale:(MKZoomScale)zoomScale CF_RETURNS_RETAINED {
    // The fastest way to draw a path in an MKOverlayView is to simplify the
    // geometry for the screen by eliding points that are too close together
    // and to omit any line segments that do not intersect the clipping rect.  
    // While it is possible to just add all the points and let CoreGraphics 
    // handle clipping and flatness, it is much faster to do it yourself:
    //
    if (pointCount < 2) {
        return NULL;
    }
    
    CGMutablePathRef path = NULL;
    BOOL needsMove = YES;
    
    // Calculate the minimum distance between any two points by figuring out
    // how many map points correspond to MIN_POINT_DELTA of screen points
    // at the current zoomScale.
    double minPointDelta = 5.f / zoomScale;
    double c2 = minPointDelta * minPointDelta;
    
    MKMapPoint point, lastPoint = points[0];
    NSUInteger i;
    
    for (i = 1; i < pointCount - 1; i++) {
        point = points[i];
        double a2b2 = (point.x - lastPoint.x) * (point.x - lastPoint.x) + (point.y - lastPoint.y) * (point.y - lastPoint.y);
        
        if (a2b2 >= c2) {
            if (MTDDirectionLineIntersectsRect(point, lastPoint, mapRect)) {
                if (!path) {
                    path = CGPathCreateMutable();
                }
                
                if (needsMove) {
                    CGPoint lastCGPoint = [self pointForMapPoint:lastPoint];
                    CGPathMoveToPoint(path, NULL, lastCGPoint.x, lastCGPoint.y);
                }
                
                CGPoint cgPoint = [self pointForMapPoint:point];
                CGPathAddLineToPoint(path, NULL, cgPoint.x, cgPoint.y);
            } else {
                // discontinuity, lift the pen
                needsMove = YES;
            }
            
            lastPoint = point;
        }
    }
    
    // If the last line segment intersects the mapRect at all, add it unconditionally
    point = points[pointCount - 1];
    if (MTDDirectionLineIntersectsRect(lastPoint, point, mapRect)) {
        if (!path) {
            path = CGPathCreateMutable();
        }
        
        if (needsMove) {
            CGPoint lastCGPoint = [self pointForMapPoint:lastPoint];
            CGPathMoveToPoint(path, NULL, lastCGPoint.x, lastCGPoint.y);
        }
        
        CGPoint cgPoint = [self pointForMapPoint:point];
        CGPathAddLineToPoint(path, NULL, cgPoint.x, cgPoint.y);
    }
    
    return path;
}

// gets called from the UIGestureRecognizer on the MTDMapView
- (void)mtd_handleTapAtPoint:(CGPoint)point {
    MTDRoute *selectedRoute = [self mtd_routeTouchedByPoint:point];

    if (selectedRoute != nil && selectedRoute != self.mtd_directionsOverlay.activeRoute) {
        [self.mtd_directionsOverlay mtd_activateRoute:selectedRoute];
        [self setNeedsDisplayInMapRect:MKMapRectWorld];
    }
}

// check whether a touch at the given point tried to select the given route
- (BOOL)mtd_touchAtPoint:(CGPoint)point insideRoute:(MTDRoute *)route {
    MKMapPoint mapPoint = [self mapPointForPoint:point];

    // TODO: How to optimize/improve/fix this check?
    for (MTDWaypoint *waypoint in route.waypoints) {
        MKMapPoint waypointMapPoint = MKMapPointForCoordinate(waypoint.coordinate);
        CLLocationDistance distance = MKMetersBetweenMapPoints(mapPoint, waypointMapPoint);

        if (distance < 100.) {
            return YES;
        }
    }

    return NO;
}

// returns the first route that get's hit by the touch at the given point
- (MTDRoute *)mtd_routeTouchedByPoint:(CGPoint)point {
    for (MTDRoute *route in self.mtd_directionsOverlay.routes) {
        if ([self mtd_touchAtPoint:point insideRoute:route]) {
            return route;
        }
    }

    return nil;
}

@end
