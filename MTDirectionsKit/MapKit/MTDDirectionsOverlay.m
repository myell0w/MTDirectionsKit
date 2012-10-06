#import "MTDDirectionsOverlay.h"
#import "MTDWaypoint.h"
#import "MTDDistance.h"
#import "MTDFunctions.h"
#import "MTDRoute.h"
#import "MTDRoute+MTDirectionsPrivateAPI.h"
#import "MTDDirectionsDefines.h"


@interface MTDDirectionsOverlay () {
    NSMutableArray *_routes;
    MTDRoute *_bestRoute;
    MTDRoute *_activeRoute;
    MTDRoute *_shortestRoute;
    MTDRoute *_fastestRoute;
}

// Re-defining properties as read/write
@property (nonatomic, copy, readwrite) NSArray *routes;
@property (nonatomic, assign, readwrite) MTDDirectionsRouteType routeType;
@property (nonatomic, copy, readwrite) NSArray *intermediateGoals;

@end


@implementation MTDDirectionsOverlay

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithRoutes:(NSArray *)routes
   intermediateGoals:(NSArray *)intermediateGoals
           routeType:(MTDDirectionsRouteType)routeType {
    if ((self = [super init])) {
        _routes = [routes mutableCopy];
        _bestRoute = _activeRoute = MTDFirstObjectOfArray(_routes);
        _intermediateGoals = [intermediateGoals copy];
        _routeType = routeType;

        [self mtd_sortRoutes];
    }

    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MKOverlay
////////////////////////////////////////////////////////////////////////

- (CLLocationCoordinate2D)coordinate {
    return self.activeRoute.mtd_polyline.coordinate;
}

- (MKMapRect)boundingMapRect {
    if (self.routes.count > 0) {
        __block MKMapRect boundingMapRect = MKMapRectNull;

        [self.routes enumerateObjectsUsingBlock:^(MTDRoute *route, NSUInteger idx, __unused BOOL *stop) {
            if (idx == 0) {
                boundingMapRect = route.mtd_polyline.boundingMapRect;
            } else {
                boundingMapRect = MKMapRectUnion(boundingMapRect, route.mtd_polyline.boundingMapRect);
            }
        }];

        return boundingMapRect;
    } else {
        return MKMapRectNull;
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDDirectionsOverlay
////////////////////////////////////////////////////////////////////////

- (MTDRoute *)fastestRoute {
    if (_fastestRoute == nil) {
        NSNumber *minTime = [self.routes valueForKeyPath:[NSString stringWithFormat:@"@min.%@", MTDKey(timeInSeconds)]];
        NSUInteger index = [self.routes indexOfObjectPassingTest:^BOOL(MTDRoute *route, __unused NSUInteger idx, __unused BOOL *stop) {
            return route.timeInSeconds == [minTime doubleValue];
        }];

        _fastestRoute = MTDObjectAtIndexOfArray(self.routes, index);
    }

    return _fastestRoute;
}

- (MTDRoute *)shortestRoute {
    if (_shortestRoute == nil) {
        NSNumber *minDistance = [self.routes valueForKeyPath:[NSString stringWithFormat:@"@min.%@.%@", MTDKey(distance), MTDKey(distanceInMeter)]];
        NSUInteger index = [self.routes indexOfObjectPassingTest:^BOOL(MTDRoute *route, __unused NSUInteger idx, __unused BOOL *stop) {
            return route.distance.distanceInMeter == [minDistance doubleValue];
        }];

        _shortestRoute = MTDObjectAtIndexOfArray(self.routes, index);
    }

    return _shortestRoute;
}

- (NSArray *)waypoints {
    return self.activeRoute.waypoints;
}

- (CLLocationCoordinate2D)fromCoordinate {
    return self.activeRoute.from.coordinate;
}

- (CLLocationCoordinate2D)toCoordinate {
    return self.activeRoute.to.coordinate;
}

- (MTDAddress *)fromAddress {
    return self.activeRoute.from.address;
}

- (MTDAddress *)toAddress {
    return self.activeRoute.to.address;
}

- (MTDDistance *)distance {
    return self.activeRoute.distance;
}

- (NSTimeInterval)timeInSeconds {
    return self.activeRoute.timeInSeconds;
}

- (NSString *)formattedTime {
    return self.activeRoute.formattedTime;
}

- (NSString *)formattedTimeWithFormat:(NSString *)format {
    return [self.activeRoute formattedTimeWithFormat:format];
}

- (NSArray *)maneuvers {
    return self.activeRoute.maneuvers;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

// This method sets a new active route (is called when user taps a route on the mapView)
- (void)mtd_activateRoute:(MTDRoute *)route {
    if (route != nil) {
        _activeRoute = route;
        [self mtd_sortRoutes];
    }
}

// This method re-orders the routes s.t. the active route is last in the array (to get drawn on top of the others)
- (void)mtd_sortRoutes {
    @synchronized(_routes) {
        [_routes sortUsingComparator:^NSComparisonResult(MTDRoute *route1, MTDRoute *route2) {
            if (route1 == self.activeRoute) {
                return NSOrderedDescending;
            } else if (route2 == self.activeRoute) {
                return NSOrderedAscending;
            } else {
                return NSOrderedSame;
            }
        }];
    }
}

@end
