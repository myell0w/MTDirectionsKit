#import "MTDDirectionsOverlay.h"
#import "MTDWaypoint.h"
#import "MTDDistance.h"
#import "MTDFunctions.h"
#import "MTDRoute.h"
#import "MTDRoute+MTDirectionsPrivateAPI.h"
#import "MTDDirectionsDefines.h"


@interface MTDDirectionsOverlay () {
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
        _routes = [routes copy];
        _intermediateGoals = [intermediateGoals copy];
        _routeType = routeType;
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
    return self.activeRoute.mtd_polyline.boundingMapRect;
}

- (BOOL)intersectsMapRect:(MKMapRect)mapRect {
    return [self.activeRoute.mtd_polyline intersectsMapRect:mapRect];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDDirectionsOverlay
////////////////////////////////////////////////////////////////////////

- (MTDRoute *)activeRoute {
    // TODO: Return selected route instead of hardcoded route
    return MTDFirstObjectOfArray(self.routes);
}

- (MTDRoute *)bestRoute {
    return MTDFirstObjectOfArray(self.routes);
}

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

@end
