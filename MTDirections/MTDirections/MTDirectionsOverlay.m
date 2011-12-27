#import "MTDirectionsOverlay.h"
#import "MTWaypoint.h"

@implementation MTDirectionsOverlay

@synthesize polyline = polyline_;

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

+ (MTDirectionsOverlay *)overlayWithWaypoints:(NSArray *)waypoints {
    MTDirectionsOverlay *overlay = [[MTDirectionsOverlay alloc] init];
    MKMapPoint *points = malloc(sizeof(CLLocationCoordinate2D) * waypoints.count);
    
    for (NSUInteger i = 0; i < waypoints.count; i++) {
        MTWaypoint *waypoint = [waypoints objectAtIndex:i];
        MKMapPoint point = MKMapPointForCoordinate(waypoint.coordinate);
        
        points[i] = point;
    }
    
    overlay.polyline = [MKPolyline polylineWithPoints:points count:waypoints.count];
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
