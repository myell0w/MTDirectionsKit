#import "MTDDirectionsOverlayView.h"
#import "MTDDirectionsOverlay.h"
#import "MTDManeuver.h"
#import "MTDDirectionsOverlay+MTDirectionsPrivateAPI.h"
#import "MTDRoute.h"
#import "MTDFunctions.h"
#import "MTDWaypoint.h"


#define kMTDDefaultOverlayColor         [UIColor colorWithRed:0.f green:0.25f blue:1.f alpha:1.f]
#define kMTDDefaultLineWidthFactor      1.8f
#define kMTDMinimumLineWidthFactor      0.7f
#define kMTDMaximumLineWidthFactor      3.0f


NS_INLINE CGFloat MTDDistanceToSegment(CGPoint point, CGPoint segmentPointV, CGPoint segmentPointW);


@interface MTDDirectionsOverlayView ()

@property (nonatomic, readonly) MTDDirectionsOverlay *mtd_directionsOverlay;

@end


@implementation MTDDirectionsOverlayView

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithOverlay:(id<MKOverlay>)overlay {
    if ((self = [super initWithOverlay:overlay])) {
        _overlayLineWidthFactor = kMTDDefaultLineWidthFactor;
        _overlayColor = kMTDDefaultOverlayColor;
        _drawManeuvers = NO;
    }

    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MKOverlayView
////////////////////////////////////////////////////////////////////////

- (void)drawMapRect:(MKMapRect)mapRect
          zoomScale:(MKZoomScale)zoomScale
          inContext:(CGContextRef)context {
    CGFloat screenScale = [UIScreen mainScreen].scale;

    _fullLineWidth = MKRoadWidthAtZoomScale(zoomScale) * self.overlayLineWidthFactor * screenScale;

    // outset the map rect by the line width so that points just outside
    // of the currently drawn rect are included in the generated path.
    MKMapRect clipRect = MKMapRectInset(mapRect, -_fullLineWidth, -_fullLineWidth);

    // we can't sort the routes and draw them simultanously
    @synchronized (self.mtd_directionsOverlay.routes) {
        for (MTDRoute *route in self.mtd_directionsOverlay.routes) {
            CGPathRef path = [self mtd_newPathForPoints:route.points
                                             pointCount:route.pointCount
                                               clipRect:clipRect
                                              zoomScale:zoomScale];

            if (path != NULL) {
                BOOL isActiveRoute = (route == self.mtd_directionsOverlay.activeRoute);

                [self drawPath:path ofRoute:route activeRoute:isActiveRoute mapRect:clipRect zoomScale:zoomScale inContext:context];

                // TODO: Make public
                if (self.drawManeuvers) {
                    for (MTDManeuver *maneuver in self.mtd_directionsOverlay.maneuvers) {
                        [self mtd_drawManeuver:maneuver lineWidth:self.fullLineWidth inContext:context];
                    }
                }

                // Cleanup
                CGPathRelease(path);
            }
        }
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDDirectionsOverlayView
////////////////////////////////////////////////////////////////////////

- (void)drawPath:(CGPathRef)path
         ofRoute:(__unused MTDRoute *)route
     activeRoute:(BOOL)activeRoute
         mapRect:(__unused MKMapRect)mapRect
       zoomScale:(__unused MKZoomScale)zoomScale
       inContext:(CGContextRef)context {
    UIColor *baseColor = self.overlayColor;
    CGFloat shadowAlpha = 0.4f;
    CGFloat secondNormalPathAlpha = 0.7f;
    CGFloat lineWidth = _fullLineWidth;

    // draw non-active routes less intense
    if (!activeRoute) {
        baseColor = [baseColor colorWithAlphaComponent:0.65f];
        lineWidth = _fullLineWidth * 0.75f;
        shadowAlpha = 0.15f;
        secondNormalPathAlpha = 0.45f;
    } else {
        // Watermark - cripple drawing for Demo
        {
            _mtd_wm_ = 1;

            float components[] = {1.f, 0.f, 0.f, 0.35f};
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            CGColorRef wmColor = CGColorCreate(colorSpace, components);

            CGRect boundingBox = CGPathGetBoundingBox(path);
            CGContextSaveGState(context);
            CGContextSetFillColorWithColor(context, wmColor);
            CGContextFillRect(context, boundingBox);
            CGContextRestoreGState(context);

            CGColorRelease(wmColor);
            CGColorSpaceRelease(colorSpace);
        }
    }

    UIColor *darkenedColor = MTDDarkenedColor(baseColor, 0.1f);
    CGFloat darkPathLineWidth = lineWidth;
    CGFloat normalPathLineWidth = roundf(darkPathLineWidth * 0.8f);
    CGFloat innerGlowPathLineWidth = roundf(darkPathLineWidth * 0.9f);

    // Setup graphics context
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);

    // Draw dark path
    CGContextSaveGState(context);
    CGContextSetLineWidth(context, darkPathLineWidth);
    CGContextSetFillColorWithColor(context, darkenedColor.CGColor);
    CGContextSetStrokeColorWithColor(context, darkenedColor.CGColor);
    CGContextSetShadowWithColor(context, CGSizeMake(0.f, darkPathLineWidth/10.f), darkPathLineWidth/10.f, [UIColor colorWithWhite:0.f alpha:shadowAlpha].CGColor);
    CGContextAddPath(context, path);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);

    // Draw normal path
    CGContextSaveGState(context);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    CGContextSetLineWidth(context, normalPathLineWidth);
    CGContextSetStrokeColorWithColor(context, baseColor.CGColor);
    CGContextAddPath(context, path);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);

    // Draw inner glow path
    CGContextSaveGState(context);
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
    CGContextSetStrokeColorWithColor(context, [baseColor colorWithAlphaComponent:secondNormalPathAlpha].CGColor);
    CGContextAddPath(context, path);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}

- (void)setOverlayColor:(UIColor *)overlayColor {
    if (overlayColor != _overlayColor && overlayColor != nil) {
        _overlayColor = overlayColor;
        [self setNeedsDisplayInMapRect:MKMapRectWorld];
    }
}

- (void)setOverlayLineWidthFactor:(CGFloat)overlayLineWidthFactor {
    if (overlayLineWidthFactor >= kMTDMinimumLineWidthFactor && overlayLineWidthFactor <= kMTDMaximumLineWidthFactor) {
        _overlayLineWidthFactor = overlayLineWidthFactor;
        [self setNeedsDisplayInMapRect:MKMapRectWorld];
    }
}

- (void)setDrawManeuvers:(BOOL)drawManeuvers {
    if (drawManeuvers != _drawManeuvers) {
        _drawManeuvers = drawManeuvers;
        [self setNeedsDisplayInMapRect:MKMapRectWorld];
    }
}

// check whether a touch at the given point tried to select the given route
- (CGFloat)distanceBetweenPoint:(CGPoint)point route:(MTDRoute *)route {
	CGFloat shortestDistance = FLT_MAX;
	MKMapView *mapView = (MKMapView *)self.superview;

    // walk view hierarchy to find mapView
	while (mapView != nil) {
		mapView = (MKMapView *)mapView.superview;

        if ([mapView isKindOfClass:[MKMapView class]]) {
			break;
        }
	}

	CGPoint tapPoint = [mapView convertPoint:point fromView:self];
	CGPoint startPoint = [mapView convertCoordinate:((MTDWaypoint *)route.waypoints[0]).coordinate
                                      toPointToView:mapView];

    for (MTDWaypoint *waypoint in [route.waypoints subarrayWithRange:NSMakeRange(1, route.waypoints.count - 1)]) {
		CGPoint cgWaypoint = [mapView convertCoordinate:waypoint.coordinate toPointToView:mapView];
		CGFloat distance = MTDDistanceToSegment(tapPoint, startPoint, cgWaypoint);

        if (distance < shortestDistance) {
            shortestDistance = distance;
        }

		startPoint = cgWaypoint;
    }

    return shortestDistance;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

- (MTDDirectionsOverlay *)mtd_directionsOverlay {
    return (MTDDirectionsOverlay *)self.overlay;
}

- (void)mtd_drawManeuver:(MTDManeuver *)maneuver lineWidth:(CGFloat)lineWidth inContext:(CGContextRef)context {
    MKMapPoint mapPoint = MKMapPointForCoordinate(maneuver.waypoint.coordinate);
    CGPoint point = [self pointForMapPoint:mapPoint];
    CGFloat radius = lineWidth;
    CGRect rect = CGRectMake(point.x - radius, point.y - radius, 2.f*radius, 2.f*radius);

    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, CGSizeMake(0.f, lineWidth/10.f), lineWidth/10.f, [[UIColor colorWithWhite:0.f alpha:0.4f] CGColor]);
    CGContextSetFillColorWithColor(context, [[UIColor colorWithRed:0.97f green:0.97f blue:0.97f alpha:1.f] CGColor]);
    CGContextSetStrokeColorWithColor(context, [[UIColor colorWithWhite:0.f alpha:0.2f] CGColor]);
    CGRect outerCircleRect = CGRectInset(rect, lineWidth/10.f, lineWidth/10.f);
    CGContextSetLineWidth(context, lineWidth/10.f);
    CGContextFillEllipseInRect(context, outerCircleRect);
    CGContextStrokeEllipseInRect(context, outerCircleRect);
    CGContextRestoreGState(context);

    CGContextSaveGState(context);
    CGContextSetBlendMode(context, kCGBlendModeOverlay);
    CGRect innerShadowCircleRect = CGRectInset(outerCircleRect, lineWidth/10.f, lineWidth/10.f);
    CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] CGColor]);
    CGContextStrokeEllipseInRect(context, innerShadowCircleRect);
    CGContextRestoreGState(context);
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

    @autoreleasepool {
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

// returns the first route that get's hit by the touch at the given point
- (MTDRoute *)mtd_routeTouchedByPoint:(CGPoint)point {
    MTDRoute *nearestRoute = nil;
    CGFloat minimumDistance = 25.f;

    for (MTDRoute *route in self.mtd_directionsOverlay.routes) {
        CGFloat distance = [self distanceBetweenPoint:point route:route];

        if (distance < minimumDistance) {
            minimumDistance = distance;
            nearestRoute = route;
        }
    }

    return nearestRoute;
}

@end


////////////////////////////////////////////////////////////////////////
#pragma mark - Helper Functions
////////////////////////////////////////////////////////////////////////

// Helper functions for calculating the distance to each line segment
// Taken from http://stackoverflow.com/a/12185597/235297

NS_INLINE CGFloat MTDSqr(CGFloat x) {
	return x*x;
}

NS_INLINE CGFloat MTDDist2(CGPoint v, CGPoint w) {
	return MTDSqr(v.x - w.x) + MTDSqr(v.y - w.y);
}

NS_INLINE CGFloat MTDDistanceToSegmentSquared(CGPoint p, CGPoint v, CGPoint w) {
    CGFloat l2 = MTDDist2(v, w);

    if (l2 == 0.f) {
        return MTDDist2(p, v);
    }

    CGFloat t = ((p.x - v.x) * (w.x - v.x) + (p.y - v.y) * (w.y - v.y)) / l2;

    if (t < 0.f) {
        return MTDDist2(p, v);
    }

    if (t > 1.f) {
        return MTDDist2(p, w);
    }

    return MTDDist2(p, CGPointMake(v.x + t * (w.x - v.x), v.y + t * (w.y - v.y)));
}

NS_INLINE CGFloat MTDDistanceToSegment(CGPoint point, CGPoint segmentPointV, CGPoint segmentPointW) {
    return sqrtf(MTDDistanceToSegmentSquared(point, segmentPointV, segmentPointW));
}
