#import "MTDDirectionsOverlayView.h"
#import "MTDDirectionsOverlay.h"
#import "MTDManeuver.h"


NS_INLINE BOOL MTDDirectionLineIntersectsRect(MKMapPoint p0, MKMapPoint p1, MKMapRect r) {
    double minX = MIN(p0.x, p1.x);
    double minY = MIN(p0.y, p1.y);
    double maxX = MAX(p0.x, p1.x);
    double maxY = MAX(p0.y, p1.y);
    
    MKMapRect r2 = MKMapRectMake(minX, minY, maxX - minX, maxY - minY);
    return MKMapRectIntersectsRect(r, r2);
}


@interface MTDDirectionsOverlayView ()

@property (nonatomic, readonly) MTDDirectionsOverlay *directionsOverlay;

- (void)drawManeuver:(MTDManeuver *)maneuver zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context;

- (CGPathRef)mtd_newPathForPoints:(MKMapPoint *)points
                       pointCount:(NSUInteger)pointCount
                         clipRect:(MKMapRect)mapRect
                        zoomScale:(MKZoomScale)zoomScale CF_RETURNS_RETAINED;

@end


@implementation MTDDirectionsOverlayView
 
@synthesize drawManeuvers = _drawManeuvers;
@synthesize overlayColor = _overlayColor;

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDDirectionsOverlayView
////////////////////////////////////////////////////////////////////////

- (UIColor *)overlayColor {
    return _overlayColor ?: [UIColor colorWithRed:0.f green:0.25f blue:1.f alpha:0.5f];
}

- (void)setOverlayColor:(UIColor *)overlayColor {
    if (overlayColor != _overlayColor) {
        _overlayColor = overlayColor;
        [self setNeedsDisplay];
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MKOverlayView
////////////////////////////////////////////////////////////////////////

- (void)drawMapRect:(MKMapRect)mapRect
          zoomScale:(MKZoomScale)zoomScale
          inContext:(CGContextRef)context {
    CGFloat lineWidth = MKRoadWidthAtZoomScale(zoomScale) * 1.8f;
    // outset the map rect by the line width so that points just outside
    // of the currently drawn rect are included in the generated path.
    MKMapRect clipRect = MKMapRectInset(mapRect, -lineWidth, -lineWidth);
    CGPathRef path = [self mtd_newPathForPoints:self.directionsOverlay.points
                                     pointCount:self.directionsOverlay.pointCount
                                       clipRect:clipRect
                                      zoomScale:zoomScale];
    
    if (path != NULL) {
        UIColor *fillColor = self.overlayColor;
        
        CGContextSaveGState(context);
        
        {
            CGContextSetFillColorWithColor(context, fillColor.CGColor);
            CGContextSetLineJoin(context, kCGLineJoinRound);
            CGContextSetLineCap(context, kCGLineCapRound);
            CGContextSetLineWidth(context, lineWidth);
            CGContextAddPath(context, path);
            CGContextReplacePathWithStrokedPath(context);
            CGContextFillPath(context);
        }
        
        if (self.drawManeuvers) {
            for (MTDManeuver *maneuver in self.directionsOverlay.maneuvers) {
                [self drawManeuver:maneuver zoomScale:zoomScale inContext:context];
            }
        }
        
        CGContextRestoreGState(context);
        
        CGPathRelease(path);
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

- (MTDDirectionsOverlay *)directionsOverlay {
    return (MTDDirectionsOverlay *)self.overlay;
}

- (void)drawManeuver:(MTDManeuver *)maneuver zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context {
    CGFloat roadWidth = MKRoadWidthAtZoomScale(zoomScale);
    MKMapPoint mapPoint = MKMapPointForCoordinate(maneuver.coordinate);
    CGPoint point = [self pointForMapPoint:mapPoint];
    CGFloat radius = roadWidth * 0.85f;
    CGRect circleRect = CGRectMake(point.x - radius, point.y - radius, 2.f*radius, 2.f*radius);
    
    // NOTE: Internal method, we don't save/restore state here for performance reasons
    
    CGContextBeginPath(context);
    CGContextSetLineWidth(context,2.f);
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.f green:90.f/255.f blue:1.f alpha:0.9f].CGColor);
    CGContextAddEllipseInRect(context, circleRect);
    CGContextFillPath(context);
    
    CGContextBeginPath(context);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:40.f/255.f green:90.f/255.f blue:200.f/255.f alpha:0.9f].CGColor);
    CGContextAddEllipseInRect(context, circleRect);
    CGContextStrokePath(context);
}

- (CGPathRef)mtd_newPathForPoints:(MKMapPoint *)points
                       pointCount:(NSUInteger)pointCount
                         clipRect:(MKMapRect)mapRect
                        zoomScale:(MKZoomScale)zoomScale {
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

@end
