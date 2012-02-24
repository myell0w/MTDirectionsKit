#import "MTDirectionsOverlay.h"
#import "MTWaypoint.h"

@interface MTDirectionsOverlay ()

/** 
 Internally using a MKPolyline to represent the overlay since MKPolyline cannot be subclassed
 and we don't want to reinvent the wheel here
 */
@property (nonatomic, strong) MKPolyline *polyline;

// Re-defining properties as readwrite
@property (nonatomic, strong, readwrite) NSArray *waypoints;
@property (nonatomic, assign, readwrite) CLLocationDistance distance;
@property (nonatomic, assign, readwrite) MTDirectionsRouteType routeType;

@end

@implementation MTDirectionsOverlay

@synthesize polyline = _polyline;
@synthesize waypoints = _waypoints;
@synthesize distance = _distance;
@synthesize routeType = _routeType;
@synthesize maneuvers = _maneuvers;

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

+ (MTDirectionsOverlay *)overlayWithWaypoints:(NSArray *)waypoints 
                                     distance:(CLLocationDistance)distance
                                    routeType:(MTDirectionsRouteType)routeType {
    MTDirectionsOverlay *overlay = [[MTDirectionsOverlay alloc] init];
    MKMapPoint *points = malloc(sizeof(CLLocationCoordinate2D) * waypoints.count);
    
    for (NSUInteger i = 0; i < waypoints.count; i++) {
        MTWaypoint *waypoint = [waypoints objectAtIndex:i];
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
#pragma mark - MTDirectionsOverlay
////////////////////////////////////////////////////////////////////////

- (MKMapPoint *)points {
    return self.polyline.points;
}

- (NSUInteger)pointCount {
    return self.polyline.pointCount;
}

@end
