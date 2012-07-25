#import "MTDDirectionsParserGoogle.h"
#import "MTDDirectionsOverlay.h"
#import "MTDXMLElement.h"
#import "MTDDistance.h"
#import "MTDFunctions.h"
#import "MTDWaypoint.h"
#import "MTDRoute.h"
#import "MTDAddress.h"
#import "MTDStatusCodeGoogle.h"


@implementation MTDDirectionsParserGoogle

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDDirectionsParser
////////////////////////////////////////////////////////////////////////

- (void)parseWithCompletion:(mtd_parser_block)completion {
    MTDAssert(completion != nil, @"Completion block must be set");
    
    MTDXMLElement *statusCodeNode = [MTDXMLElement nodeForXPathQuery:@"//DirectionsResponse/status" onXML:self.data];
    MTDStatusCodeGoogle statusCode = MTDStatusCodeGoogleSuccess;
    MTDDirectionsOverlay *overlay = nil;
    NSError *error = nil;
    
    if (statusCodeNode != nil) {
        statusCode = MTDStatusCodeGoogleFromDescription(statusCodeNode.contentString);
    }
    
    if (statusCode == MTDStatusCodeGoogleSuccess) {
        NSArray *waypointNodes = [MTDXMLElement nodesForXPathQuery:@"//route[1]/leg/step/polyline/points" onXML:self.data];
        NSArray *distanceNodes = [MTDXMLElement nodesForXPathQuery:@"//route[1]/leg/distance/value" onXML:self.data];
        NSArray *timeNodes = [MTDXMLElement nodesForXPathQuery:@"//route[1]/leg/duration/value" onXML:self.data];
        MTDXMLElement *copyrightNode = [MTDXMLElement nodeForXPathQuery:@"//route[1]/copyrights" onXML:self.data];
        NSArray *warningNodes = [MTDXMLElement nodesForXPathQuery:@"//route[1]/warnings" onXML:self.data];
        NSArray *addressNodesExceptTo = [MTDXMLElement nodesForXPathQuery:@"//route[1]/leg/start_address" onXML:self.data];
        MTDXMLElement *toAddressNode = [MTDXMLElement nodeForXPathQuery:@"//route[1]/leg[last()]/end_address" onXML:self.data];
        NSArray *locationSequenceNodes = [MTDXMLElement nodesForXPathQuery:@"//route[1]/waypoint_index" onXML:self.data];

        NSArray *waypoints = [self mtd_waypointsFromWaypointNodes:waypointNodes];
        MTDDistance *distance = nil;
        NSTimeInterval timeInSeconds = -1.;
        NSMutableDictionary *additionalInfo = [NSMutableDictionary dictionary];

        // Order the intermediate goals in the order returned by the API (optimized)
        // and parse the address information and save the address for each goal (from, to, intermediateGoals)
        NSArray *orderedIntermediateGoals = [self mtd_orderedIntermediateGoalsWithSequenceNodes:locationSequenceNodes
                                                                               addressNodes:[addressNodesExceptTo arrayByAddingObject:toAddressNode]];

        // Parse Additional Info of directions
        {
            if (distanceNodes.count > 0) {
                double distanceInMeters = 0.;
                
                for (MTDXMLElement *distanceNode in distanceNodes) {
                    distanceInMeters += [[distanceNode contentString] doubleValue];
                }
                
                distance = [MTDDistance distanceWithMeters:distanceInMeters];
            }
            
            if (timeNodes.count > 0) {
                timeInSeconds = 0.;
                
                for (MTDXMLElement *timeNode in timeNodes) {
                    timeInSeconds += [[timeNode contentString] doubleValue];
                }
            }
            
            if (copyrightNode != nil) {
                [additionalInfo setValue:copyrightNode.contentString forKey:@"copyrights"];
            }
            
            if (warningNodes.count > 0) {
                NSArray *warnings = [warningNodes valueForKey:MTDKey(contentString)];
                [additionalInfo setValue:warnings forKey:@"warnings"];
            }
        }
        
        MTDRoute *route = [[MTDRoute alloc] initWithWaypoints:waypoints
                                                     distance:distance
                                                timeInSeconds:timeInSeconds
                                               additionalInfo:additionalInfo];
        
        overlay = [[MTDDirectionsOverlay alloc] initWithRoutes:@[route]
                                             intermediateGoals:orderedIntermediateGoals
                                                     routeType:self.routeType];
    } else {
        error = [NSError errorWithDomain:MTDDirectionsKitErrorDomain
                                    code:statusCode
                                userInfo:@{MTDDirectionsKitDataKey: self.data}];
        
        MTDLogError(@"Error occurred during parsing of directions from %@ to %@:\n%@", self.from, self.to, error);
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

// This method decodes a polyline and returns an array of MTDWaypoints
// Algorithm description:
// http://code.google.com/apis/maps/documentation/utilities/polylinealgorithm.html
- (NSArray *)mtd_waypointsFromEncodedPolyline:(NSString *)encodedPolyline {
    if (encodedPolyline.length == 0) {
        return nil;
    }
    
    const char *bytes = [encodedPolyline UTF8String];
    NSUInteger length = [encodedPolyline lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    NSUInteger index = 0;
    double latitude = 0.;
    double longitude = 0.;
    NSMutableArray *waypoints = [NSMutableArray array];
    
    while (index < length) {
        char byte = 0;
        int res = 0;
        char shift = 0;
        
        do {
            byte = bytes[index++] - 63;
            res |= (byte & 0x1F) << shift;
            shift += 5;
        } while (byte >= 0x20);
        
        float deltaLat = ((res & 1) ? ~(res >> 1) : (res >> 1));
        latitude += deltaLat;
        
        shift = 0;
        res = 0;
        
        do {
            byte = bytes[index++] - 0x3F;
            res |= (byte & 0x1F) << shift;
            shift += 5;
        } while (byte >= 0x20);
        
        double deltaLon = ((res & 1) ? ~(res >> 1) : (res >> 1));
        longitude += deltaLon;
        
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude * 1E-5, longitude * 1E-5);
        [waypoints addObject:[MTDWaypoint waypointWithCoordinate:coordinate]];
    }
    
    return waypoints;
}

// This method parses the waypointNodes and returns an array of MTDWaypoints
- (NSArray *)mtd_waypointsFromWaypointNodes:(NSArray *)waypointNodes {
    NSMutableArray *waypoints = [NSMutableArray array];
    
    // add start coordinate
    if (self.from != nil && CLLocationCoordinate2DIsValid(self.from.coordinate)) {
        [waypoints addObject:self.from];
    }
    
    for (MTDXMLElement *waypointNode in waypointNodes) {
        NSString *encodedPolyline = [waypointNode contentString];
        
        [waypoints addObjectsFromArray:[self mtd_waypointsFromEncodedPolyline:encodedPolyline]];
    }
    
    // add end coordinate
    if (self.to != nil && CLLocationCoordinate2DIsValid(self.to.coordinate)) {
        [waypoints addObject:self.to];
    }

    return waypoints;
}

// This method parses all addresses and orders the intermediate goals in the same order as optimised by the API.
// That is, if optimization is enabled the Google can reorder the intermediate goals to provide the fastest route possible.
- (NSArray *)mtd_orderedIntermediateGoalsWithSequenceNodes:(NSArray *)sequenceNodes addressNodes:(NSArray *)addressNodes {
    NSArray *sequence = [sequenceNodes valueForKey:MTDKey(contentString)];
    // Sort the intermediate goals to be in the order of the numbers contained in sequence
    NSArray *orderedIntermediateGoals = MTDOrderedArrayWithSequence(self.intermediateGoals,sequence);
    
    // all goals, including from and to
    NSMutableArray *allGoals = [NSMutableArray arrayWithArray:orderedIntermediateGoals];
    // insert from and to at the right places
    [allGoals insertObject:self.from atIndex:0];
    [allGoals addObject:self.to];
    
    MTDAssert(addressNodes.count == allGoals.count, @"Number of addresses doesn't match number of goals");
    
    // Parse Addresses of goals
    [addressNodes enumerateObjectsUsingBlock:^(MTDXMLElement *addressNode, NSUInteger idx, __unused BOOL *stop) {
        MTDAddress *address = [self mtd_addressFromAddressNode:addressNode];
        MTDWaypoint *waypoint = allGoals[idx];
        
        // update address of corresponding waypoint
        waypoint.address = address;
    }];
    
    return orderedIntermediateGoals;
}

// This method parses an address and returns an instance of MTDAddress
- (MTDAddress *)mtd_addressFromAddressNode:(MTDXMLElement *)addressNode {
    return [[MTDAddress alloc] initWithAddressString:addressNode.contentString];
}

@end
