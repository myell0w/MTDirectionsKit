#import "MTDDirectionsParserMapQuest.h"
#import "MTDWaypoint.h"
#import "MTDAddress.h"
#import "MTDDistance.h"
#import "MTDFunctions.h"
#import "MTDRoute.h"
#import "MTDDirectionsOverlay.h"
#import "MTDDirectionsRouteType.h"
#import "MTDXMLElement.h"
#import "MTDStatusCodeMapQuest.h"


@implementation MTDDirectionsParserMapQuest

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDDirectionsParser
////////////////////////////////////////////////////////////////////////

- (void)parseWithCompletion:(mtd_parser_block)completion {
    MTDAssert(completion != nil, @"Completion block must be set");
    
    MTDXMLElement *statusCodeNode = [MTDXMLElement nodeForXPathQuery:@"//statusCode" onXML:self.data];
    NSInteger statusCode = MTDStatusCodeMapQuestSuccess;
    MTDDirectionsOverlay *overlay = nil;
    NSError *error = nil;
    
    if (statusCodeNode != nil) {
        statusCode = [statusCodeNode.contentString integerValue];
    }
    
    if (statusCode == MTDStatusCodeMapQuestSuccess) {
        NSArray *waypointNodes = [MTDXMLElement nodesForXPathQuery:@"//shapePoints/latLng" onXML:self.data];
        MTDXMLElement *distanceNode = [MTDXMLElement nodeForXPathQuery:@"//route/distance" onXML:self.data];
        MTDXMLElement *timeNode = [MTDXMLElement nodeForXPathQuery:@"//route/time" onXML:self.data];
        MTDXMLElement *copyrightNode = [MTDXMLElement nodeForXPathQuery:@"//copyright/text" onXML:self.data];
        MTDXMLElement *fromLocationAddressNode = [MTDXMLElement nodeForXPathQuery:@"//route/locations/location[1]" onXML:self.data];
        MTDXMLElement *toLocationAddressNode = [MTDXMLElement nodeForXPathQuery:@"//route/locations/location[last()]" onXML:self.data];
        
        NSMutableArray *waypoints = [NSMutableArray arrayWithCapacity:waypointNodes.count+2];
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
                MTDXMLElement *latitudeNode = [childNode firstChildNodeWithName:@"lat"];
                MTDXMLElement *longitudeNode = [childNode firstChildNodeWithName:@"lng"];
                
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
        
        // Parse Additional Info of directions
        {
            if (distanceNode != nil) {
                // distance is delivered in km from API
                double distanceInKm = [distanceNode.contentString doubleValue];
                
                distance = [MTDDistance distanceWithValue:distanceInKm
                                        measurementSystem:MTDMeasurementSystemMetric];
            }
            
            if (timeNode != nil) {
                timeInSeconds = [timeNode.contentString doubleValue];
            }
            
            if (copyrightNode != nil) {
                [additionalInfo setValue:copyrightNode.contentString forKey:@"copyrights"];
            }
            
            if (fromLocationAddressNode != nil) {
                MTDXMLElement *streetNode = [fromLocationAddressNode firstChildNodeWithName:@"street"];
                MTDXMLElement *cityNode = [fromLocationAddressNode firstChildNodeWithName:@"adminArea5"];
                MTDXMLElement *stateNode = [fromLocationAddressNode firstChildNodeWithName:@"adminArea3"];
                MTDXMLElement *countyNode = [fromLocationAddressNode firstChildNodeWithName:@"adminArea4"];
                MTDXMLElement *postalCodeNode = [fromLocationAddressNode firstChildNodeWithName:@"postalCode"];
                MTDXMLElement *countryNode = [fromLocationAddressNode firstChildNodeWithName:@"adminArea1"];
                
                MTDAddress *fromAddress = [[MTDAddress alloc] initWithCountry:[countryNode contentString]
                                                                        state:[stateNode contentString]
                                                                       county:[countyNode contentString]
                                                                   postalCode:[postalCodeNode contentString]
                                                                         city:[cityNode contentString]
                                                                       street:[streetNode contentString]];
                self.from.address = fromAddress;
            }
            
            if (toLocationAddressNode != nil) {
                MTDXMLElement *streetNode = [toLocationAddressNode firstChildNodeWithName:@"street"];
                MTDXMLElement *cityNode = [toLocationAddressNode firstChildNodeWithName:@"adminArea5"];
                MTDXMLElement *stateNode = [toLocationAddressNode firstChildNodeWithName:@"adminArea3"];
                MTDXMLElement *countyNode = [toLocationAddressNode firstChildNodeWithName:@"adminArea4"];
                MTDXMLElement *postalCodeNode = [toLocationAddressNode firstChildNodeWithName:@"postalCode"];
                MTDXMLElement *countryNode = [toLocationAddressNode firstChildNodeWithName:@"adminArea1"];
                
                MTDAddress *toAddress = [[MTDAddress alloc] initWithCountry:[countryNode contentString]
                                                                      state:[stateNode contentString]
                                                                     county:[countyNode contentString]
                                                                 postalCode:[postalCodeNode contentString]
                                                                       city:[cityNode contentString]
                                                                     street:[streetNode contentString]];
                self.to.address = toAddress;
            }
        }
        
        MTDRoute *route = [[MTDRoute alloc] initWithWaypoints:waypoints
                                                     distance:distance
                                                timeInSeconds:timeInSeconds
                                               additionalInfo:additionalInfo];
        
        overlay = [[MTDDirectionsOverlay alloc] initWithRoutes:[NSArray arrayWithObject:route]
                                             intermediateGoals:self.intermediateGoals
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
    }
}

@end
