#import "MTDDirectionsParserMapQuest.h"
#import "MTDWaypoint.h"
#import "MTDDistance.h"
#import "MTDDirectionsOverlay.h"
#import "MTDDirectionsRouteType.h"
#import "MTDXMLElement.h"
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
        NSArray *timeNodes = [MTDXMLElement nodesForXPathQuery:@"//route/time" onXML:self.data];
        
        NSMutableArray *waypoints = [NSMutableArray arrayWithCapacity:waypointNodes.count+2];
        MTDDistance *distance = nil;
        NSTimeInterval timeInSeconds = -1.;
        
        // Parse Waypoints
        {
            // add start coordinate
            if (CLLocationCoordinate2DIsValid(self.fromCoordinate)) {
                [waypoints addObject:[MTDWaypoint waypointWithCoordinate:self.fromCoordinate]];
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
            if (CLLocationCoordinate2DIsValid(self.toCoordinate)) {
                [waypoints addObject:[MTDWaypoint waypointWithCoordinate:self.toCoordinate]];
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
        }
        
        overlay = [MTDDirectionsOverlay overlayWithWaypoints:[waypoints copy]
                                                    distance:distance
                                               timeInSeconds:timeInSeconds
                                                   routeType:self.routeType];
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
    }
    
    if (completion != nil) {
        completion(overlay, error);
    }
}

@end
