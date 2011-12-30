#import "MTDirectionsOverlay.h"
#import "MTWaypoint.h"

@interface MTDirectionsOverlay ()

// Re-defining properties as readwrite
@property (nonatomic, assign, readwrite) CLLocationDistance distance;
@property (nonatomic, assign, readwrite) MTDirectionsRouteType routeType;

@end

@implementation MTDirectionsOverlay

@synthesize polyline = polyline_;
@synthesize waypoints = waypoints_;
@synthesize distance = distance_;
@synthesize routeType = routeType_;

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

@end
