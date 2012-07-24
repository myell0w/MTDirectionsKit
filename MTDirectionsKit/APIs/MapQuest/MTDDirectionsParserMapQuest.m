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


@interface MTDDirectionsParserMapQuest ()

// This method parses the waypointNodes and returns an array of MTDWaypoints
- (NSArray *)mtd_waypointsFromWaypointNodes:(NSArray *)waypointNodes;
// This method parses all addresses and orders the intermediate goals in the same order as optimised by the API.
// That is, if optimization is enabled the MapQuest can reorder the intermediate goals to provide the fastest route possible.
- (NSArray *)mtd_orderedIntermediateGoalsWithSequenceNode:(MTDXMLElement *)sequenceNode addressNodes:(NSArray *)addressNodes;
// This method parses an address and returns an instance of MTDAddress
- (MTDAddress *)mtd_addressFromAddressNode:(MTDXMLElement *)addressNode;

@end


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
        NSArray *locationAddressNodes = [MTDXMLElement nodesForXPathQuery:@"//route/locations/location" onXML:self.data];
        MTDXMLElement *locationSequenceNode = [MTDXMLElement nodeForXPathQuery:@"//route/locationSequence" onXML:self.data];
        
        NSArray *waypoints = [self mtd_waypointsFromWaypointNodes:waypointNodes];
        MTDDistance *distance = nil;
        NSTimeInterval timeInSeconds = -1.;
        NSMutableDictionary *additionalInfo = [NSMutableDictionary dictionary];
        
        // Order the intermediate goals in the order returned by the API (optimized)
        // and parse the address information and save the address for each goal (from, to, intermediateGoals)
        NSArray *orderedIntermediateGoals = [self mtd_orderedIntermediateGoalsWithSequenceNode:locationSequenceNode
                                                                                  addressNodes:locationAddressNodes];
        
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
        }
        
        MTDRoute *route = [[MTDRoute alloc] initWithWaypoints:waypoints
                                                     distance:distance
                                                timeInSeconds:timeInSeconds
                                               additionalInfo:additionalInfo];
        
        overlay = [[MTDDirectionsOverlay alloc] initWithRoutes:[NSArray arrayWithObject:route]
                                             intermediateGoals:orderedIntermediateGoals
                                                     routeType:self.routeType];
    } else {
        MTDXMLElement *messageNode = [MTDXMLElement nodeForXPathQuery:@"//messages/message" onXML:self.data];
        NSString *errorMessage = nil;
        
        if (messageNode != nil) {
            errorMessage = messageNode.contentString;
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

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

- (NSArray *)mtd_waypointsFromWaypointNodes:(NSArray *)waypointNodes {
    NSMutableArray *waypoints = [NSMutableArray arrayWithCapacity:waypointNodes.count+2];
    
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
                                                                           [longitudeNode.contentString doubleValue]);
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
    
    return waypoints;
}

- (NSArray *)mtd_orderedIntermediateGoalsWithSequenceNode:(MTDXMLElement *)sequenceNode addressNodes:(NSArray *)addressNodes {
    NSArray *sequence = [sequenceNode.contentString componentsSeparatedByString:@","];
    // all goals, including from and to
    NSMutableArray *allGoals = [NSMutableArray arrayWithArray:self.intermediateGoals];
    // insert from and to at the right places
    [allGoals insertObject:self.from atIndex:0];
    [allGoals addObject:self.to];
    
    // Sort the intermediate goals to be in the order of the numbers contained in sequence
    NSArray *orderedIntermediateGoals = MTDOrderedArrayWithSequence(allGoals,sequence);
    
    MTDAssert(addressNodes.count == allGoals.count, @"Number of addresses doesn't match number of goals");
    
    // Parse Addresses of goals
    [addressNodes enumerateObjectsUsingBlock:^(MTDXMLElement *addressNode, NSUInteger idx, __unused BOOL *stop) {
        MTDAddress *address = [self mtd_addressFromAddressNode:addressNode];
        MTDWaypoint *waypoint = [orderedIntermediateGoals objectAtIndex:idx];
        
        // update address of corresponding waypoint
        waypoint.address = address;
    }];
    
    return [orderedIntermediateGoals subarrayWithRange:NSMakeRange(1, orderedIntermediateGoals.count-2)];
}

- (MTDAddress *)mtd_addressFromAddressNode:(MTDXMLElement *)addressNode {
    MTDXMLElement *streetNode = [addressNode firstChildNodeWithName:@"street"];
    MTDXMLElement *cityNode = [addressNode firstChildNodeWithName:@"adminArea5"];
    MTDXMLElement *stateNode = [addressNode firstChildNodeWithName:@"adminArea3"];
    MTDXMLElement *countyNode = [addressNode firstChildNodeWithName:@"adminArea4"];
    MTDXMLElement *postalCodeNode = [addressNode firstChildNodeWithName:@"postalCode"];
    MTDXMLElement *countryNode = [addressNode firstChildNodeWithName:@"adminArea1"];
    
    MTDAddress *address = [[MTDAddress alloc] initWithCountry:[countryNode contentString]
                                                        state:[stateNode contentString]
                                                       county:[countyNode contentString]
                                                   postalCode:[postalCodeNode contentString]
                                                         city:[cityNode contentString]
                                                       street:[streetNode contentString]];
    
    return address;
}

@end
