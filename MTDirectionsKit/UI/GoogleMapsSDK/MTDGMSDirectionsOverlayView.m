#import "MTDGMSDirectionsOverlayView.h"
#import "MTDRoute+MTDGoogleMapsSDK.h"


#define kMTDDefaultLineWidthFactor      1.8f
#define kMTDMinimumLineWidthFactor      0.5f
#define kMTDMaximumLineWidthFactor      4.0f

#define kMTDMultiplicationFactor         4.f


@interface MTDGMSDirectionsOverlayView ()

@property (nonatomic, mtd_weak) MTDDirectionsOverlay *directionsOverlay;
@property (nonatomic, mtd_weak) MTDRoute *route;

@end

@implementation MTDGMSDirectionsOverlayView

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithDirectionsOverlay:(MTDDirectionsOverlay *)directionsOverlay route:(MTDRoute *)route {
    if ((self = [super init])) {
        self.path = route.path;

        _directionsOverlay = directionsOverlay;
        _route = route;
        _overlayLineWidthFactor = kMTDDefaultLineWidthFactor;

        self.strokeWidth = _overlayLineWidthFactor * kMTDMultiplicationFactor;
    }

    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - GMSPolyline
////////////////////////////////////////////////////////////////////////

- (CGFloat)strokeWidth {
    if (self.directionsOverlay.activeRoute == self.route) {
        return self.overlayLineWidthFactor * kMTDMultiplicationFactor;
    } else {
        return self.overlayLineWidthFactor * kMTDMultiplicationFactor * 0.75f;
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDGMSDirectionsOverlayView
////////////////////////////////////////////////////////////////////////

- (void)setOverlayColor:(UIColor *)overlayColor {
    if (overlayColor != nil) {
        self.strokeColor = overlayColor;
    }
}

- (void)setOverlayLineWidthFactor:(CGFloat)overlayLineWidthFactor {
    if (overlayLineWidthFactor >= kMTDMinimumLineWidthFactor && overlayLineWidthFactor <= kMTDMaximumLineWidthFactor) {
        _overlayLineWidthFactor = overlayLineWidthFactor;
    }
}

// check whether a touch at the given point tried to select the given route
- (CGFloat)distanceBetweenPoint:(CGPoint)point route:(MTDRoute *)route {
    if (route != self.route) {
        MTDLogInfo(@"distanceBetweenPoint:route: called with wrong route");
        return FLT_MAX;
    }
    
	CGFloat shortestDistance = FLT_MAX;
	GMSMapView *mapView = self.map;

    if (mapView != nil) {
        // we remove all instances of [MTDWaypoint waypointForCurrentLocation] from the list because if point
        // refers to the user location (which is the most common use-case for this method) the distance will
        // always be 0.f otherwise
        NSArray *waypointsWithoutCurrentLocation = [route.waypoints filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(MTDWaypoint *evaluatedObject, __unused NSDictionary *bindings) {
            return ![evaluatedObject isWaypointForCurrentLocation];
        }]];

        if (waypointsWithoutCurrentLocation.count > 0) {
            CGPoint startPoint = [mapView.projection pointForCoordinate:[waypointsWithoutCurrentLocation[0] coordinate]];

            for (MTDWaypoint *waypoint in [waypointsWithoutCurrentLocation subarrayWithRange:NSMakeRange(1, waypointsWithoutCurrentLocation.count - 1)]) {
                CGPoint cgWaypoint = [mapView.projection pointForCoordinate:waypoint.coordinate];
                CGFloat distance = MTDDistanceToSegment(point, startPoint, cgWaypoint);

                if (distance < shortestDistance) {
                    shortestDistance = distance;
                }

                startPoint = cgWaypoint;
            }
        }
    }
    
    return shortestDistance;
}

@end
