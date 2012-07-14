#import "MTDDirectionsOverlay.h"
#import "MTDWaypoint.h"
#import "MTDDistance.h"
#import "MTDRoute.h"
#import "MTDRoute+MTDirectionsPrivateAPI.h"
#import "MTDDirectionsDefines.h"


@interface MTDDirectionsOverlay ()

// Re-defining properties as read/write
@property (nonatomic, copy, readwrite) NSArray *routes;
@property (nonatomic, assign, readwrite) MTDDirectionsRouteType routeType;
@property (nonatomic, copy, readwrite) NSArray *intermediateGoals;

@end


@implementation MTDDirectionsOverlay

@synthesize routes = _routes;
@synthesize routeType = _routeType;
@synthesize intermediateGoals = _intermediateGoals;

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
    return self.activeRoute.polyline.coordinate;
}

- (MKMapRect)boundingMapRect {
    return self.activeRoute.polyline.boundingMapRect;
}

- (BOOL)intersectsMapRect:(MKMapRect)mapRect {
    return [self.activeRoute.polyline intersectsMapRect:mapRect];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDDirectionsOverlay
////////////////////////////////////////////////////////////////////////

- (MTDRoute *)activeRoute {
    // TODO: Return selected route instead of hardcoded route
    return [self.routes objectAtIndex:0];
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

- (MKMapPoint *)points {
    return self.activeRoute.points;
}

- (NSUInteger)pointCount {
    return self.activeRoute.pointCount;
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
