#import "MTDDirectionsParserMapQuest.h"
#import "MTDWaypoint.h"
#import "MTDDirectionsOverlay.h"
#import "MTDDirectionsRouteType.h"
#import "MTXPathResultNode.h"
#import "MTDManeuver.h"
#import "MTDStatusCodeMapQuest.h"


#define kMTDDirectionsStartPointNode     @"startPoint"
#define kMTDDirectionsDistanceNode       @"distance"
#define kMTDDirectionsTimeNode           @"time"
#define kMTDDirectionsLatitudeNode       @"lat"
#define kMTDDirectionsLongitudeNode      @"lng"

@implementation MTDDirectionsParserMapQuest

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDDirectionsParser
////////////////////////////////////////////////////////////////////////

- (void)parseWithCompletion:(mtd_parser_block)completion {
    NSArray *statusCodeNodes = [MTXPathResultNode nodesForXPathQuery:@"//statusCode" onXML:self.data];
    NSUInteger statusCode = MTDStatusCodeMapQuestSuccess;
    MTDDirectionsOverlay *overlay = nil;
    NSError *error = nil;
    
    if (statusCodeNodes.count > 0) {
        statusCode = [[[statusCodeNodes objectAtIndex:0] contentString] integerValue];
    }
    
    if (statusCode == MTDStatusCodeMapQuestSuccess) {
        NSArray *waypointNodes = [MTXPathResultNode nodesForXPathQuery:@"//shapePoints/latLng" onXML:self.data];
        NSArray *distanceNodes = [MTXPathResultNode nodesForXPathQuery:@"//route/distance" onXML:self.data];
        NSArray *maneuverNodes = [MTXPathResultNode nodesForXPathQuery:@"//legs/leg[1]/maneuvers/maneuver" onXML:self.data];
        
        NSMutableArray *waypoints = [NSMutableArray arrayWithCapacity:waypointNodes.count+2];
        NSMutableArray *maneuvers = [NSMutableArray arrayWithCapacity:maneuverNodes.count];
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
        
        // Parse Maneuvers
        {
            for (MTXPathResultNode *maneuverNode in maneuverNodes) {
                MTXPathResultNode *positionNode = [maneuverNode firstChildNodeWithName:kMTDDirectionsStartPointNode];
                MTXPathResultNode *latitudeNode = [positionNode firstChildNodeWithName:kMTDDirectionsLatitudeNode];
                MTXPathResultNode *longitudeNode = [positionNode firstChildNodeWithName:kMTDDirectionsLongitudeNode];
                
                if (latitudeNode != nil && longitudeNode != nil) {
                    MTXPathResultNode *distanceNode = [maneuverNode firstChildNodeWithName:kMTDDirectionsDistanceNode];
                    MTXPathResultNode *timeNode = [maneuverNode firstChildNodeWithName:kMTDDirectionsTimeNode];
                    
                    CLLocationCoordinate2D maneuverCoordinate = CLLocationCoordinate2DMake([latitudeNode.contentString doubleValue],
                                                                                           [longitudeNode.contentString doubleValue]);
                    CLLocationDistance maneuverDistance = [distanceNode.contentString doubleValue];
                    NSTimeInterval maneuverTime = [timeNode.contentString doubleValue];
                    
                    [maneuvers addObject:[MTDManeuver maneuverWithWaypoint:[MTDWaypoint waypointWithCoordinate:maneuverCoordinate]
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
            
            overlay = [MTDDirectionsOverlay overlayWithWaypoints:[waypoints copy]
                                                        distance:distance
                                                       routeType:self.routeType];
            
            overlay.maneuvers = [maneuvers copy];
        }
    } 
    
    else {
        error = [NSError errorWithDomain:MTDDirectionsKitErrorDomain
                                    code:statusCode
                                userInfo:[NSDictionary dictionaryWithObject:self.data forKey:MTDDirectionsKitDataKey]];
    }
    
    if (completion != nil) {
        completion(overlay, error);
    }
}

@end
