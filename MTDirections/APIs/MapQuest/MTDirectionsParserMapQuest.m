#import "MTDirectionsParserMapQuest.h"
#import "MTWaypoint.h"
#import "MTDirectionsOverlay.h"
#import "MTDirectionsRouteType.h"
#import "MTXPathResultNode.h"
#import "MTManeuver.h"

#define kMTDirectionsStartPointNode     @"startPoint"
#define kMTDirectionsDistanceNode       @"distance"
#define kMTDirectionsTimeNode           @"time"
#define kMTDirectionsLatitudeNode       @"lat"
#define kMTDirectionsLongitudeNode      @"lng"

@implementation MTDirectionsParserMapQuest

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDirectionsParser
////////////////////////////////////////////////////////////////////////

- (void)parseWithCompletion:(mt_direction_block)completion {
    NSArray *waypointNodes = [MTXPathResultNode nodesForXPathQuery:@"//shapePoints/latLng" onXML:self.data];
    NSArray *distanceNodes = [MTXPathResultNode nodesForXPathQuery:@"//route/distance" onXML:self.data];
    NSArray *maneuverNodes = [MTXPathResultNode nodesForXPathQuery:@"//legs/leg[1]/maneuvers/maneuver" onXML:self.data];
    
    NSMutableArray *waypoints = [NSMutableArray arrayWithCapacity:waypointNodes.count+2];
    NSMutableArray *maneuvers = [NSMutableArray arrayWithCapacity:maneuverNodes.count];
    CLLocationDistance distance = -1.;
    
    // Parse Waypoints
    {
        // add start coordinate
        [waypoints addObject:[MTWaypoint waypointWithCoordinate:self.fromCoordinate]];
        
        // There should only be one element "shapePoints"
        for (MTXPathResultNode *childNode in waypointNodes) {
            MTXPathResultNode *latitudeNode = [childNode firstChildNodeWithName:kMTDirectionsLatitudeNode];
            MTXPathResultNode *longitudeNode = [childNode firstChildNodeWithName:kMTDirectionsLongitudeNode];
            
            if (latitudeNode != nil && longitudeNode != nil) {
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([latitudeNode.contentString doubleValue],
                                                                               [longitudeNode.contentString doubleValue]);;
                MTWaypoint *waypoint = [MTWaypoint waypointWithCoordinate:coordinate];
                
                if (![waypoints containsObject:waypoint]) {
                    [waypoints addObject:waypoint];
                }
            }
        }
        
        // add end coordinate
        [waypoints addObject:[MTWaypoint waypointWithCoordinate:self.toCoordinate]];
    }
    
    // Parse Maneuvers
    {
        for (MTXPathResultNode *maneuverNode in maneuverNodes) {
            MTXPathResultNode *positionNode = [maneuverNode firstChildNodeWithName:kMTDirectionsStartPointNode];
            MTXPathResultNode *latitudeNode = [positionNode firstChildNodeWithName:kMTDirectionsLatitudeNode];
            MTXPathResultNode *longitudeNode = [positionNode firstChildNodeWithName:kMTDirectionsLongitudeNode];
            
            if (latitudeNode != nil && longitudeNode != nil) {
                MTXPathResultNode *distanceNode = [maneuverNode firstChildNodeWithName:kMTDirectionsDistanceNode];
                MTXPathResultNode *timeNode = [maneuverNode firstChildNodeWithName:kMTDirectionsTimeNode];
                
                CLLocationCoordinate2D maneuverCoordinate = CLLocationCoordinate2DMake([latitudeNode.contentString doubleValue],
                                                                                       [longitudeNode.contentString doubleValue]);
                CLLocationDistance maneuverDistance = [distanceNode.contentString doubleValue];
                NSTimeInterval maneuverTime = [timeNode.contentString doubleValue];
                
                [maneuvers addObject:[MTManeuver maneuverWithWaypoint:[MTWaypoint waypointWithCoordinate:maneuverCoordinate]
                                                             distance:maneuverDistance
                                                                 time:maneuverTime]];
            }
        }
    }
    
    // Parse Additional Info of directions
    {
        if (distanceNodes.count > 0) {
            // distance is delivered in km from API
            distance = [[[distanceNodes objectAtIndex:0] contentString] doubleValue] * 1000.;
        }
    }
    
    MTDirectionsOverlay *overlay = [MTDirectionsOverlay overlayWithWaypoints:[waypoints copy]
                                                                    distance:distance
                                                                   routeType:self.routeType];
    
    overlay.maneuvers = [maneuvers copy];
    
    if (completion != nil) {
        completion(overlay);
    }
}

@end
