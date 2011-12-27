#import "MTDirectionsOverlay.h"
#import "MTWaypoint.h"

@implementation MTDirectionsOverlay

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

+ (MTDirectionsOverlay *)overlayWithWaypoints:(NSArray *)waypoints {
    MKMapPoint *points = malloc(sizeof(CLLocationCoordinate2D) * waypoints.count);
    
    for (NSUInteger i = 0; i < waypoints.count; i++) {
        MTWaypoint *waypoint = [waypoints objectAtIndex:i];
        MKMapPoint point = MKMapPointForCoordinate(waypoint.coordinate);
        
        points[i] = point;
    }
    
    MTDirectionsOverlay *overlay = (MTDirectionsOverlay *)[MKPolyline polylineWithPoints:points count:waypoints.count];
    free(points);
    
    return overlay;
}

@end
