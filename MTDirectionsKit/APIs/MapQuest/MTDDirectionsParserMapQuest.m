#import "MTDDirectionsParserMapQuest.h"
#import "MTDWaypoint.h"
#import "MTDDirectionsOverlay.h"
#import "MTDDirectionsRouteType.h"
#import "MTXPathResultNode.h"


#define kMTDDirectionsStartPointNode     @"startPoint"
#define kMTDDirectionsDistanceNode       @"distance"
#define kMTDDirectionsTimeNode           @"time"
#define kMTDDirectionsLatitudeNode       @"lat"
#define kMTDDirectionsLongitudeNode      @"lng"


@implementation MTDDirectionsParserMapQuest

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDDirectionsParser
////////////////////////////////////////////////////////////////////////

- (void)parseWithCompletion:(mtd_direction_block)completion {
    NSArray *waypointNodes = [MTXPathResultNode nodesForXPathQuery:@"//shapePoints/latLng" onXML:self.data];
    NSArray *distanceNodes = [MTXPathResultNode nodesForXPathQuery:@"//route/distance" onXML:self.data];
    
    NSMutableArray *waypoints = [NSMutableArray arrayWithCapacity:waypointNodes.count+2];
    CLLocationDistance distance = -1.;
    
    // Parse Waypoints
    {
        // add start coordinate
        [waypoints addObject:[MTDWaypoint waypointWithCoordinate:self.fromCoordinate]];
        
        // There should only be one element "shapePoints"
        for (MTXPathResultNode *childNode in waypointNodes) {
            MTXPathResultNode *latitudeNode = [childNode firstChildNodeWithName:kMTDDirectionsLatitudeNode];
            MTXPathResultNode *longitudeNode = [childNode firstChildNodeWithName:kMTDDirectionsLongitudeNode];
            
            if (latitudeNode != nil && longitudeNode != nil) {
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([latitudeNode.contentString doubleValue],
                                                                               [longitudeNode.contentString doubleValue]);;
                MTDWaypoint *waypoint = [MTDWaypoint waypointWithCoordinate:coordinate];
                
                if (![waypoints containsObject:waypoint]) {
                    [waypoints addObject:waypoint];
                }
            }
        }
        
        // add end coordinate
        [waypoints addObject:[MTDWaypoint waypointWithCoordinate:self.toCoordinate]];
    }
    
    // Parse Additional Info of directions
    {
        if (distanceNodes.count > 0) {
            // distance is delivered in km from API
            distance = [[[distanceNodes objectAtIndex:0] contentString] doubleValue] * 1000.;
        }
    }
    
    MTDDirectionsOverlay *overlay = [MTDDirectionsOverlay overlayWithWaypoints:[waypoints copy]
                                                                    distance:distance
                                                                   routeType:self.routeType];
    
    if (completion != nil) {
        completion(overlay);
    }
}

@end
