#import "MTDDirectionsParserMapQuest.h"
#import "MTDWaypoint.h"
#import "MTDDistance.h"
#import "MTDFunctions.h"
#import "MTDDirectionsOverlay.h"
#import "MTDDirectionsRouteType.h"
#import "MTDManeuver.h"
#import "MTDXMLElement.h"
#import "MTDStatusCodeMapQuest.h"
#import "MTDLogging.h"

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
    NSArray *statusCodeNodes = [MTDXMLElement nodesForXPathQuery:@"//statusCode" onXML:self.data];
    NSUInteger statusCode = MTDStatusCodeMapQuestSuccess;
    MTDDirectionsOverlay *overlay = nil;
    NSError *error = nil;
    
    if (statusCodeNodes.count > 0) {
        statusCode = [[[statusCodeNodes objectAtIndex:0] contentString] integerValue];
    }
    
    if (statusCode == MTDStatusCodeMapQuestSuccess) {
        NSArray *waypointNodes = [MTDXMLElement nodesForXPathQuery:@"//shapePoints/latLng" onXML:self.data];
        NSArray *distanceNodes = [MTDXMLElement nodesForXPathQuery:@"//route/distance" onXML:self.data];
        NSArray *maneuverNodes = [MTDXMLElement nodesForXPathQuery:@"//legs/leg[1]/maneuvers/maneuver" onXML:self.data];
        NSArray *timeNodes = [MTDXMLElement nodesForXPathQuery:@"//route/time" onXML:self.data];
        NSArray *copyrightNodes = [MTDXMLElement nodesForXPathQuery:@"//copyright/text" onXML:self.data];
        
        NSMutableArray *waypoints = [NSMutableArray arrayWithCapacity:waypointNodes.count+2];
        NSMutableArray *maneuvers = [NSMutableArray arrayWithCapacity:maneuverNodes.count];
        MTDDistance *distance = nil;
        NSTimeInterval timeInSeconds = -1.;
        NSMutableDictionary *additionalInfo = [NSMutableDictionary dictionary];
        
        // Parse Waypoints
        {
            // add start coordinate
            if (self.from != nil && CLLocationCoordinate2DIsValid(self.from.coordinate)) {
                [waypoints addObject:self.from];
            }
            
            // There should only be one element "shapePoints"
            for (MTDXMLElement *childNode in waypointNodes) {
                MTDXMLElement *latitudeNode = [childNode firstChildNodeWithName:kMTDDirectionsLatitudeNode];
                MTDXMLElement *longitudeNode = [childNode firstChildNodeWithName:kMTDDirectionsLongitudeNode];
                
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
            if (self.to != nil && CLLocationCoordinate2DIsValid(self.to.coordinate)) {
                [waypoints addObject:self.to];
            }
        }
        
        // Parse Maneuvers
        {
            for (MTDXMLElement *maneuverNode in maneuverNodes) {
                MTDXMLElement *positionNode = [maneuverNode firstChildNodeWithName:kMTDDirectionsStartPointNode];
                MTDXMLElement *latitudeNode = [positionNode firstChildNodeWithName:kMTDDirectionsLatitudeNode];
                MTDXMLElement *longitudeNode = [positionNode firstChildNodeWithName:kMTDDirectionsLongitudeNode];
                
                if (latitudeNode != nil && longitudeNode != nil) {
                    MTDXMLElement *distanceNode = [maneuverNode firstChildNodeWithName:kMTDDirectionsDistanceNode];
                    MTDXMLElement *timeNode = [maneuverNode firstChildNodeWithName:kMTDDirectionsTimeNode];
                    
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
                double distanceInKm = [[[distanceNodes objectAtIndex:0] contentString] doubleValue];
                
                distance = [MTDDistance distanceWithValue:distanceInKm
                                        measurementSystem:MTDMeasurementSystemMetric];
            }
            
            if (timeNodes.count > 0) {
                timeInSeconds = [[[timeNodes objectAtIndex:0] contentString] doubleValue];
            }
            
            if (copyrightNodes.count > 0) {
                NSString *copyright = [[copyrightNodes objectAtIndex:0] contentString];
                [additionalInfo setValue:copyright forKey:@"copyrights"];
            }
        }
        
        overlay = [MTDDirectionsOverlay overlayWithWaypoints:[waypoints copy]
                                                    distance:distance
                                               timeInSeconds:timeInSeconds
                                                   routeType:self.routeType];
        
        overlay.maneuvers = [maneuvers copy];

        // set read-only properties via KVO to not pollute API
        [overlay setValue:self.from.address forKey:NSStringFromSelector(@selector(fromAddress))];
        [overlay setValue:self.to.address forKey:NSStringFromSelector(@selector(toAddress))];
        [overlay setValue:additionalInfo forKey:NSStringFromSelector(@selector(additionalInfo))];
    } else {
        NSArray *messageNodes = [MTDXMLElement nodesForXPathQuery:@"//messages/message" onXML:self.data];
        NSString *errorMessage = nil;
        
        if (messageNodes.count > 0) {
            errorMessage = [[messageNodes objectAtIndex:0] contentString];
        }
        
        error = [NSError errorWithDomain:MTDDirectionsKitErrorDomain
                                    code:statusCode
                                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                          self.data, MTDDirectionsKitDataKey,
                                          errorMessage, MTDDirectionsKitErrorMessageKey,
                                          nil]];
        
        MTDLogError(@"Error occurred during parsing of directions from %@ to %@: %@ \n%@", 
                    self.from,
                    self.to,
                    errorMessage ?: @"No error message",
                    error);
    }
    
    if (completion != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(overlay, error);
        });
    } else {
        MTDLogWarning(@"No completion block was set.");
    }
}

@end
