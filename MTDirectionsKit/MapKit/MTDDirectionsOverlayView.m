#import "MTDDirectionsOverlayView.h"
#import "MTDDirectionsOverlay.h"
#import "MTDManeuver.h"
#import "MTDFunctions.h"


@interface MTDDirectionsOverlayView ()

@property (nonatomic, readonly) MTDDirectionsOverlay *directionsOverlay;

- (void)drawManeuver:(MTDManeuver *)maneuver lineWidth:(CGFloat)lineWidth inContext:(CGContextRef)context;

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
    return _overlayColor ?: [UIColor colorWithRed:0.f green:0.25f blue:1.f alpha:1.f]; //[UIColor colorWithRed:0.675 green:0.396 blue:0.702 alpha:1.000];
}

- (void)setOverlayColor:(UIColor *)overlayColor {
    if (overlayColor != _overlayColor && overlayColor != nil) {
        _overlayColor = overlayColor;
        [self setNeedsDisplay];
    }
}

- (void)setDrawManeuvers:(BOOL)drawManeuvers {
    if (drawManeuvers != _drawManeuvers) {
        _drawManeuvers = drawManeuvers;
        [self setNeedsDisplayInMapRect:MKMapRectWorld];
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MKOverlayView
////////////////////////////////////////////////////////////////////////

- (void)drawMapRect:(MKMapRect)mapRect
          zoomScale:(MKZoomScale)zoomScale
          inContext:(CGContextRef)context {
    CGFloat screenScale = [UIScreen mainScreen].scale;
    CGFloat lineWidth = MKRoadWidthAtZoomScale(zoomScale) * 1.8f * screenScale;
    
    // outset the map rect by the line width so that points just outside
    // of the currently drawn rect are included in the generated path.
    MKMapRect clipRect = MKMapRectInset(mapRect, -lineWidth, -lineWidth);
    CGPathRef path = [self mtd_newPathForPoints:self.directionsOverlay.points
                                     pointCount:self.directionsOverlay.pointCount
                                       clipRect:clipRect
                                      zoomScale:zoomScale];
    
    if (path != NULL) {
        UIColor *darkenedColor = MTDDarkenedColor(self.overlayColor, 0.1f);
        
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
        CGFloat normalPathLineWidth = roundf(darkPathLineWidth * 0.8);
        CGContextSetLineWidth(context, normalPathLineWidth);
        CGContextSetStrokeColorWithColor(context, self.overlayColor.CGColor);
        CGContextAddPath(context, path);
        CGContextStrokePath(context);
        CGContextRestoreGState(context);
        
        // Draw inner glow path
        CGContextSaveGState(context);
        CGFloat innerGlowPathLineWidth = roundf(darkPathLineWidth * 0.9);
        CGContextSetLineWidth(context, innerGlowPathLineWidth);
        CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:1.f alpha:0.1f].CGColor);
        CGContextAddPath(context, path);
        CGContextStrokePath(context);
        CGContextRestoreGState(context);
        
        // Draw normal path again
        CGContextSaveGState(context);
        CGContextSetBlendMode(context, kCGBlendModeCopy);
        normalPathLineWidth = roundf(lineWidth * 0.6);
        CGContextSetLineWidth(context, normalPathLineWidth);
        CGContextSetStrokeColorWithColor(context, [[self.overlayColor colorWithAlphaComponent:0.7] CGColor]);
        CGContextAddPath(context, path);
        CGContextStrokePath(context);
        CGContextRestoreGState(context);
        
        // Cleanup
        CGPathRelease(path);
        
        if (self.drawManeuvers) {
            for (MTDManeuver *maneuver in self.directionsOverlay.maneuvers) {
                [self drawManeuver:maneuver lineWidth:lineWidth inContext:context];
            }
        }
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

- (MTDDirectionsOverlay *)directionsOverlay {
    return (MTDDirectionsOverlay *)self.overlay;
}

- (void)drawManeuver:(MTDManeuver *)maneuver lineWidth:(CGFloat)lineWidth inContext:(CGContextRef)context {
    MKMapPoint mapPoint = MKMapPointForCoordinate(maneuver.coordinate);
    CGPoint point = [self pointForMapPoint:mapPoint];
    CGFloat radius = lineWidth;
    CGRect rect = CGRectMake(point.x - radius, point.y - radius, 2.f*radius, 2.f*radius);
    
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, CGSizeMake(0, lineWidth / 10), lineWidth / 10, [[UIColor colorWithWhite:0 alpha:0.40] CGColor]);
    CGContextSetFillColorWithColor(context, [[UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1] CGColor]);
    CGContextSetStrokeColorWithColor(context, [[UIColor colorWithWhite:0 alpha:0.2] CGColor]);
    CGRect outerCircleRect = CGRectInset(rect, lineWidth / 10, lineWidth / 10);
    CGContextSetLineWidth(context, lineWidth / 10);
    CGContextFillEllipseInRect(context, outerCircleRect);
    CGContextStrokeEllipseInRect(context, outerCircleRect);
    CGContextRestoreGState(context);
    
    CGContextSaveGState(context);
    CGContextSetBlendMode(context, kCGBlendModeOverlay);
    CGRect innerShadowCircleRect = CGRectInset(outerCircleRect, lineWidth / 10, lineWidth / 10);
    CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] CGColor]);
    CGContextStrokeEllipseInRect(context, innerShadowCircleRect);
    CGContextRestoreGState(context);
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
