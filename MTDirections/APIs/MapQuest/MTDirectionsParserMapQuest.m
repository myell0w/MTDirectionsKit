#import "MTDirectionsParserMapQuest.h"
#import "MTWaypoint.h"
#import "MTDirectionsOverlay.h"
#import "MTDirectionsRouteType.h"
#import "MTXPathResultNode.h"
#import "MTManeuver.h"

#define kMTDirectionsLatitudeNode       @"lat"
#define kMTDirectionsLongitudeNode      @"lng"

@implementation MTDirectionsParserMapQuest

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDirectionsParser
////////////////////////////////////////////////////////////////////////

- (void)parseWithCompletion:(mt_direction_block)completion {
    NSArray *waypointNodes = [MTXPathResultNode nodesForXPathQuery:@"//shapePoints/latLng" onXML:self.data];
    NSArray *distanceNodes = [MTXPathResultNode nodesForXPathQuery:@"//route/distance" onXML:self.data];
    NSMutableArray *waypoints = [NSMutableArray arrayWithCapacity:waypointNodes.count+2];
    CLLocationDistance distance = -1.;
    
    // add start coordinate
    [waypoints addObject:[MTWaypoint waypointWithCoordinate:self.fromCoordinate]];
    
    // There should only be one element "shapePoints"
    for (MTXPathResultNode *childNode in waypointNodes) {
        MTXPathResultNode *latitudeNode = [childNode firstChildNodeWithName:kMTDirectionsLatitudeNode];
        MTXPathResultNode *longitudeNode = [childNode firstChildNodeWithName:kMTDirectionsLongitudeNode];
        
        if (latitudeNode != nil && longitudeNode != nil) {
            CLLocationCoordinate2D coordinate;
            
            coordinate.latitude = [latitudeNode.contentString doubleValue];
            coordinate.longitude = [longitudeNode.contentString doubleValue];
            
            [waypoints addObject:[MTWaypoint waypointWithCoordinate:coordinate]];
        }
    }
    
    // add end coordinate
    [waypoints addObject:[MTWaypoint waypointWithCoordinate:self.toCoordinate]];
    
    if (distanceNodes.count > 0) {
        // distance is delivered in km from API
        distance = [[[distanceNodes objectAtIndex:0] contentString] doubleValue] * 1000.;
    }
    
    MTDirectionsOverlay *overlay = [MTDirectionsOverlay overlayWithWaypoints:waypoints
                                                                    distance:distance
                                                                   routeType:self.routeType];
    
    if (completion != nil) {
        completion(overlay);
    }
}

@end
