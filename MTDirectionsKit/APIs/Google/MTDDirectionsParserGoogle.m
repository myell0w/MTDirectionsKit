#import "MTDDirectionsParserGoogle.h"
#import "MTDDirectionsOverlay.h"
#import "MTDXMLElement.h"
#import "MTDDistance.h"
#import "MTDFunctions.h"
#import "MTDWaypoint.h"
#import "MTDRoute.h"
#import "MTDAddress.h"
#import "MTDManeuver.h"
#import "MTDStatusCodeGoogle.h"


@interface MTDDirectionsParserGoogle ()

@property (nonatomic, strong, readwrite) MTDWaypoint *from; // redefined as read/write
@property (nonatomic, strong, readwrite) MTDWaypoint *to;

@end


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
        // All returned routes (can be several if using alternative routes)
        NSArray *routeNodes = [MTDXMLElement nodesForXPathQuery:@"//route" onXML:self.data];
        NSMutableArray *routes = [NSMutableArray arrayWithCapacity:routeNodes.count];
        NSArray *orderedIntermediateGoals = nil;

        // there is either only one route (possibly optimized with intermediate goals) or several without intermediate goals,
        // so in the second case the locations are always from and to and the locationSequence returns nil (gets checked in mtd_orderedIntermediateGoals)
        NSArray *addressNodesExceptTo = [MTDXMLElement nodesForXPathQuery:@"//route[1]/leg/start_address" onXML:self.data];
        MTDXMLElement *toAddressNode = [MTDXMLElement nodeForXPathQuery:@"//route[1]/leg[last()]/end_address" onXML:self.data];
        NSArray *locationAddressNodes = [addressNodesExceptTo arrayByAddingObject:toAddressNode];
        NSArray *locationSequenceNodes = [MTDXMLElement nodesForXPathQuery:@"//route[1]/waypoint_index" onXML:self.data];

        // Parse Routes
        {
            for (MTDXMLElement *routeNode in routeNodes) {
                MTDRoute *route = [self mtd_routeFromRouteNode:routeNode];

                if (route != nil) {
                    [routes addObject:route];
                }
            }
        }

        // Route optimization can reorder the intermediate goals, we want to know the final order
        if (self.intermediateGoals.count > 0) {
            // Order the intermediate goals in the order returned by the API (optimized)
            // and parse the address information and save the address for each goal (from, to, intermediateGoals)
            orderedIntermediateGoals = [self mtd_orderedIntermediateGoalsWithSequenceNodes:locationSequenceNodes];
        }

        // Parse Addresses
        {
            // We need to use the already ordered intermediate goals here because the addresses come in the in this order
            NSArray *allWaypoints = [self mtd_waypointsIncludingFromAndToWithIntermediateGoals:orderedIntermediateGoals];

            [self mtd_addAddressesFromAddressNodes:locationAddressNodes toWaypoints:allWaypoints];
        }


        overlay = [[MTDDirectionsOverlay alloc] initWithRoutes:routes
                                             intermediateGoals:orderedIntermediateGoals
                                                     routeType:self.routeType];
    } else {
        error = [NSError errorWithDomain:MTDDirectionsKitErrorDomain
                                    code:statusCode
                                userInfo:@{MTDDirectionsKitDataKey: self.data}];

        MTDLogError(@"Error occurred during parsing of directions from %@ to %@:\n%@", self.from, self.to, error);
    }

    [self callCompletion:completion overlay:overlay error:error];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

- (MTDRoute *)mtd_routeFromRouteNode:(MTDXMLElement *)routeNode {
    NSArray *stepNodes = [routeNode childNodesTraversingAllChildrenWithPath:@"leg.step"];
    NSArray *waypointNodes = [routeNode childNodesTraversingAllChildrenWithPath:@"leg.step.polyline.points"];
    NSArray *distanceNodes = [routeNode childNodesTraversingAllChildrenWithPath:@"leg.distance.value"];
    NSArray *timeNodes = [routeNode childNodesTraversingAllChildrenWithPath:@"leg.duration.value"];
    NSArray *warningNodes = [routeNode childNodesWithName:@"warnings"];
    MTDXMLElement *copyrightNode = [routeNode firstChildNodeWithName:@"copyrights"];
    MTDXMLElement *summaryNode = [routeNode firstChildNodeWithName:@"summary"];

    MTDDistance *distance = nil;
    NSTimeInterval timeInSeconds = -1.;
    NSMutableDictionary *additionalInfo = [NSMutableDictionary dictionary];

    // Parse waypoints
    NSArray *waypoints = [self mtd_waypointsFromWaypointNodes:waypointNodes];
    // Parse Maneuvers
    NSArray *maneuvers = [self mtd_maneuversFromStepNodes:stepNodes];

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
            [additionalInfo setValue:copyrightNode.contentString forKey:MTDAdditionalInfoCopyrightsKey];
        }

        if (warningNodes.count > 0) {
            NSArray *warnings = [warningNodes valueForKey:MTDKey(contentString)];
            [additionalInfo setValue:warnings forKey:MTDAdditionalInfoWarningsKey];
        }
    }

    MTDRoute *route = [[MTDRoute alloc] initWithWaypoints:waypoints
                                                maneuvers:maneuvers
                                                 distance:distance
                                            timeInSeconds:timeInSeconds
                                                     name:summaryNode.contentString
                                                routeType:self.routeType
                                           additionalInfo:additionalInfo];
    return route;
}

// This method parses the waypointNodes and returns an array of MTDWaypoints
- (NSArray *)mtd_waypointsFromWaypointNodes:(NSArray *)waypointNodes {
    NSMutableArray *waypoints = [NSMutableArray array];

    @autoreleasepool {
        for (MTDXMLElement *waypointNode in waypointNodes) {
            NSString *encodedPolyline = [waypointNode contentString];

            [waypoints addObjectsFromArray:[self mtd_waypointsFromEncodedPolyline:encodedPolyline]];
        }
    }

    // add start coordinate
    if (self.from != nil && CLLocationCoordinate2DIsValid(self.from.coordinate)) {
        [waypoints insertObject:self.from atIndex:0];
    } else if (waypoints.count > 0) {
        self.from = waypoints[0];
    }

    // add end coordinate
    if (self.to != nil && CLLocationCoordinate2DIsValid(self.to.coordinate)) {
        [waypoints addObject:self.to];
    } else {
        self.to = [waypoints lastObject];
    }

    return waypoints;
}

// This method returns an array of all waypoints including from, to and intermediateGoals if specified
- (NSArray *)mtd_waypointsIncludingFromAndToWithIntermediateGoals:(NSArray *)intermediateGoals {
    NSMutableArray *allGoals = intermediateGoals != nil ? [NSMutableArray arrayWithArray:intermediateGoals] : [NSMutableArray array];

    // insert from and to at the right places
    [allGoals insertObject:self.from atIndex:0];
    [allGoals addObject:self.to];

    return allGoals;
}

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


// This method parses all addresses and orders the intermediate goals in the same order as optimised by the API.
// That is, if optimization is enabled the Google can reorder the intermediate goals to provide the fastest route possible.
- (NSArray *)mtd_orderedIntermediateGoalsWithSequenceNodes:(NSArray *)sequenceNodes {
    if (sequenceNodes.count == 0) {
        return self.intermediateGoals;
    }

    NSArray *sequence = [sequenceNodes valueForKey:MTDKey(contentString)];
    // Sort the intermediate goals to be in the order of the numbers contained in sequence
    return MTDOrderedArrayWithSequence(self.intermediateGoals,sequence);
}

// This method updates the addresses of all given waypoints
- (void)mtd_addAddressesFromAddressNodes:(NSArray *)addressNodes toWaypoints:(NSArray *)waypoints {
    MTDAssert(addressNodes.count == waypoints.count, @"Number of addresses doesn't match number of waypoints");

    // Parse Addresses of goals
    [addressNodes enumerateObjectsUsingBlock:^(MTDXMLElement *addressNode, NSUInteger idx, __unused BOOL *stop) {
        MTDAddress *address = [self mtd_addressFromAddressNode:addressNode];
        MTDWaypoint *waypoint = waypoints[idx];

        // update address of corresponding waypoint
        waypoint.address = address;
    }];
}

// This method parses an address and returns an instance of MTDAddress
- (MTDAddress *)mtd_addressFromAddressNode:(MTDXMLElement *)addressNode {
    return [[MTDAddress alloc] initWithAddressString:addressNode.contentString];
}

// This method parses a maneuver and returns an instance of MTDManeuver
- (MTDManeuver *)mtd_maneuverFromStepNode:(MTDXMLElement *)stepNode {
    MTDXMLElement *positionNode = [stepNode firstChildNodeWithName:@"start_location"];
    MTDXMLElement *instructionNode = [stepNode firstChildNodeWithName:@"html_instructions"];
    MTDXMLElement *latitudeNode = [positionNode firstChildNodeWithName:@"lat"];
    MTDXMLElement *longitudeNode = [positionNode firstChildNodeWithName:@"lng"];

    if (latitudeNode != nil && longitudeNode != nil) {
        MTDXMLElement *distanceNode = [[stepNode firstChildNodeWithName:@"distance"] firstChildNodeWithName:@"value"];
        MTDXMLElement *timeNode = [[stepNode firstChildNodeWithName:@"duration"] firstChildNodeWithName:@"value"];

        CLLocationCoordinate2D maneuverCoordinate = CLLocationCoordinate2DMake([latitudeNode.contentString doubleValue],
                                                                               [longitudeNode.contentString doubleValue]);
        CLLocationDistance maneuverDistance = [distanceNode.contentString doubleValue];
        NSTimeInterval maneuverTime = [timeNode.contentString doubleValue];

        MTDManeuver *maneuver =  [[MTDManeuver alloc] initWithWaypoint:[MTDWaypoint waypointWithCoordinate:maneuverCoordinate]
                                                              distance:[MTDDistance distanceWithMeters:maneuverDistance]
                                                         timeInSeconds:maneuverTime
                                                          instructions:MTDStringByStrippingXMLTags(instructionNode.contentString)];

        // Google unfortunately doesn't deliver information about the cardinalDirection or turnType
        // maneuver.cardinalDirection = MTDCardinalDirectionUnknown;
        // maneuver.turnType = MTDTurnTypeUnknown;

        return maneuver;
    } else {
        return nil;
    }
}

// This method parses all maneuver nodes of a route
- (NSArray *)mtd_maneuversFromStepNodes:(NSArray *)stepNodes {
    NSMutableArray *maneuvers = [NSMutableArray arrayWithCapacity:stepNodes.count];
    
    for (MTDXMLElement *stepNode in stepNodes) {
        MTDManeuver *maneuver = [self mtd_maneuverFromStepNode:stepNode];
        
        if (maneuver != nil) {
            [maneuvers addObject:maneuver];
        }
    }
    
    return maneuvers;
}

@end
