#import "MTDDirectionsOverlay.h"
#import "MTDWaypoint.h"
#import "MTDDirectionsDefines.h"


@interface MTDDirectionsOverlay ()

/** 
 Internally we use a MKPolyline to represent the overlay since MKPolyline
 cannot be subclassed sanely and we don't want to reinvent the wheel
 */
@property (nonatomic, strong) MKPolyline *polyline;

// Re-defining properties as readwrite
@property (nonatomic, strong, readwrite) NSArray *waypoints;
@property (nonatomic, assign, readwrite) CLLocationDistance distance;
@property (nonatomic, assign, readwrite) MTDDirectionsRouteType routeType;

@end


@implementation MTDDirectionsOverlay

@synthesize polyline = _polyline;
@synthesize waypoints = _waypoints;
@synthesize distance = _distance;
@synthesize routeType = _routeType;

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

+ (MTDDirectionsOverlay *)overlayWithWaypoints:(NSArray *)waypoints 
                                     distance:(CLLocationDistance)distance
                                    routeType:(MTDDirectionsRouteType)routeType {
    MTDDirectionsOverlay *overlay = [[MTDDirectionsOverlay alloc] init];
    MKMapPoint *points = malloc(sizeof(CLLocationCoordinate2D) * waypoints.count);
    
    for (NSUInteger i = 0; i < waypoints.count; i++) {
        MTDWaypoint *waypoint = [waypoints objectAtIndex:i];
        MKMapPoint point = MKMapPointForCoordinate(waypoint.coordinate);
        
        points[i] = point;
    }
    
    overlay.polyline = [MKPolyline polylineWithPoints:points count:waypoints.count];
    overlay.waypoints = waypoints;
    overlay.distance = distance;
    overlay.routeType = routeType;
    
    free(points);
    
    return overlay;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MKOverlay
////////////////////////////////////////////////////////////////////////

- (CLLocationCoordinate2D)coordinate {
    return self.polyline.coordinate;
}

- (MKMapRect)boundingMapRect {
    return self.polyline.boundingMapRect;
}

- (BOOL)intersectsMapRect:(MKMapRect)mapRect {
    return [self.polyline intersectsMapRect:mapRect];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDDirectionsOverlay
////////////////////////////////////////////////////////////////////////

- (MKMapPoint *)points {
    return self.polyline.points;
}

- (NSUInteger)pointCount {
    return self.polyline.pointCount;
}

- (CLLocationCoordinate2D)fromCoordinate {
    if (self.waypoints.count > 0) {
        MTDWaypoint *firstWaypoint = [self.waypoints objectAtIndex:0];
        return firstWaypoint.coordinate;
    }
    
    return MTDInvalidCLLocationCoordinate2D;
}

- (CLLocationCoordinate2D)toCoordinate {
    if (self.waypoints.count > 0) {
        MTDWaypoint *lastWaypoint = [self.waypoints lastObject];
        return lastWaypoint.coordinate;
    }
    
    return MTDInvalidCLLocationCoordinate2D;
}

@end
