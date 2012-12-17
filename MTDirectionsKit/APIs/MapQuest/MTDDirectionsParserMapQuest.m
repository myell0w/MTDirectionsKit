#import "MTDDirectionsParserMapQuest.h"
#import "MTDWaypoint.h"
#import "MTDAddress.h"
#import "MTDDistance.h"
#import "MTDFunctions.h"
#import "MTDRoute.h"
#import "MTDManeuver.h"
#import "MTDDirectionsOverlay.h"
#import "MTDDirectionsRouteType.h"
#import "MTDXMLElement.h"
#import "MTDStatusCodeMapQuest.h"
#import "MTDCardinalDirection+MapQuest.h"
#import "MTDTurnType+MapQuest.h"


@interface MTDDirectionsParserMapQuest ()

@property (nonatomic, strong, readwrite) MTDWaypoint *from; // redefined as read/write
@property (nonatomic, strong, readwrite) MTDWaypoint *to;

@end


@implementation MTDDirectionsParserMapQuest

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDDirectionsParser
////////////////////////////////////////////////////////////////////////

- (void)parseWithCompletion:(mtd_parser_block)completion {
    MTDAssert(completion != nil, @"Completion block must be set");

    MTDXMLElement *statusCodeNode = [MTDXMLElement nodeForXPathQuery:@"//statusCode" onXML:self.data];
    MTDStatusCodeMapQuest statusCode = MTDStatusCodeMapQuestSuccess;
    MTDDirectionsOverlay *overlay = nil;
    NSError *error = nil;

    if (statusCodeNode != nil) {
        statusCode = (MTDStatusCodeMapQuest)[statusCodeNode.contentString integerValue];
    }

    if (statusCode == MTDStatusCodeMapQuestSuccess) {
        // All returned routes (can be several if using alternative routes)
        NSArray *routeNodes = [MTDXMLElement nodesForXPathQuery:@"//route" onXML:self.data];
        // there is either only one route (possibly optimized with intermediate goals) or several without intermediate goals,
        // so in the second case the locations are always from and to and the locationSequence is "0,1" for all routes
        NSArray *locationAddressNodes = [MTDXMLElement nodesForXPathQuery:@"/response/route[1]/locations/location" onXML:self.data];
        MTDXMLElement *locationSequenceNode = [MTDXMLElement nodeForXPathQuery:@"/response/route[1]/locationSequence" onXML:self.data];
        NSMutableArray *routes = [NSMutableArray arrayWithCapacity:routeNodes.count];
        NSArray *orderedIntermediateGoals = nil;

        // Route optimization can reorder the intermediate goals, we want to know the final order
        if (self.intermediateGoals.count > 0) {
            // Order the intermediate goals in the order returned by the API (optimized)
            // and parse the address information and save the address for each goal (from, to, intermediateGoals)
            orderedIntermediateGoals = [self mtd_orderedIntermediateGoalsWithSequenceNode:locationSequenceNode];
        }

        // Parse Addresses
        {
            // We need to use the already ordered intermediate goals here because the addresses come in the in this order
            NSArray *allWaypoints = [self mtd_waypointsIncludingFromAndToWithIntermediateGoals:orderedIntermediateGoals];

            [self mtd_addAddressesFromLocationNodes:locationAddressNodes toWaypoints:allWaypoints];
        }

        // Parse Routes
        {
            for (MTDXMLElement *routeNode in routeNodes) {
                MTDRoute *route = [self mtd_routeFromRouteNode:routeNode];

                if (route != nil) {
                    [routes addObject:route];
                }
            }
        }

        overlay = [[MTDDirectionsOverlay alloc] initWithRoutes:routes
                                             intermediateGoals:orderedIntermediateGoals
                                                     routeType:self.routeType];
    } else {
        NSArray *messageNodes = [MTDXMLElement nodesForXPathQuery:@"//messages/message" onXML:self.data];
        NSString *errorMessage = nil;

        if (messageNodes.count > 0) {
            errorMessage = [[messageNodes valueForKey:MTDKey(contentString)] componentsJoinedByString:@"\n"];
        } else {
            errorMessage = @"No error message";
        }

        error = [NSError errorWithDomain:MTDDirectionsKitErrorDomain
                                    code:statusCode
                                userInfo:@{MTDDirectionsKitDataKey: self.data, MTDDirectionsKitErrorMessageKey: errorMessage}];

        MTDLogError(@"Error occurred during parsing of directions from %@ to %@: %@ \n%@",
                    self.from,
                    self.to,
                    errorMessage,
                    error);
    }

    [self callCompletion:completion overlay:overlay error:error];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

// This method parses a route and returns an instance of MTDRoute
- (MTDRoute *)mtd_routeFromRouteNode:(MTDXMLElement *)routeNode {
    NSArray *waypointNodes = [routeNode childNodesTraversingFirstChildWithPath:@"shape.shapePoints.latLng"];
    NSArray *maneuverNodes = [routeNode childNodesTraversingAllChildrenWithPath:@"legs.leg.maneuvers.maneuver"];
    MTDXMLElement *distanceNode = [routeNode firstChildNodeWithName:@"distance"];
    MTDXMLElement *timeNode = [routeNode firstChildNodeWithName:@"time"];
    MTDXMLElement *copyrightNode = [MTDXMLElement nodeForXPathQuery:@"/response/info/copyright/text" onXML:self.data];
    MTDXMLElement *nameNode = [routeNode firstChildNodeWithName:@"name"];

    MTDDistance *distance = nil;
    NSTimeInterval timeInSeconds = -1.;
    NSMutableDictionary *additionalInfo = [NSMutableDictionary dictionary];

    // Parse waypoints
    NSArray *waypoints = [self mtd_waypointsFromWaypointNodes:waypointNodes];
    // Parse Maneuvers
    NSArray *maneuvers = [self mtd_maneuversFromManeuverNodes:maneuverNodes];

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
            [additionalInfo setValue:copyrightNode.contentString forKey:MTDAdditionalInfoCopyrightsKey];
        }
    }

    MTDRoute *route = [[MTDRoute alloc] initWithWaypoints:waypoints
                                                maneuvers:maneuvers
                                                 distance:distance
                                            timeInSeconds:timeInSeconds
                                                     name:nameNode.contentString
                                                routeType:self.routeType
                                           additionalInfo:additionalInfo];
    return route;
}


// This method parses the waypointNodes and returns an array of MTDWaypoints
- (NSArray *)mtd_waypointsFromWaypointNodes:(NSArray *)waypointNodes {
    NSMutableArray *waypoints = [NSMutableArray arrayWithCapacity:waypointNodes.count+2];

    @autoreleasepool {
        // There should only be one element "shapePoints"
        for (MTDXMLElement *childNode in waypointNodes) {
            MTDXMLElement *latitudeNode = [childNode firstChildNodeWithName:@"lat"];
            MTDXMLElement *longitudeNode = [childNode firstChildNodeWithName:@"lng"];

            if (latitudeNode != nil && longitudeNode != nil) {
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([latitudeNode.contentString doubleValue],
                                                                               [longitudeNode.contentString doubleValue]);
                MTDWaypoint *waypoint = [MTDWaypoint waypointWithCoordinate:coordinate];

                [waypoints addObject:waypoint];
            }
        }
    }

    // add start coordinate
    if (self.from != nil && self.from.hasValidCoordinate) {
        [waypoints insertObject:self.from atIndex:0];
    } else if (waypoints.count > 0) {
        self.from = waypoints[0];
    }

    // add end coordinate
    if (self.to != nil && self.to.hasValidCoordinate) {
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

// This method parses all addresses and orders the intermediate goals in the same order as optimised by the API.
// That is, if optimization is enabled the MapQuest can reorder the intermediate goals to provide the fastest route possible.
- (NSArray *)mtd_orderedIntermediateGoalsWithSequenceNode:(MTDXMLElement *)sequenceNode {
    NSArray *sequence = [sequenceNode.contentString componentsSeparatedByString:@","];
    // all goals, including from and to, because the sequenceNode contains them too
    NSArray *allGoals = [self mtd_waypointsIncludingFromAndToWithIntermediateGoals:self.intermediateGoals];
    // Sort the intermediate goals to be in the order of the numbers contained in sequence
    NSArray *allOrderedNodes = MTDOrderedArrayWithSequence(allGoals,sequence);

    // remove from and to again from intermediate goals
    return [allOrderedNodes subarrayWithRange:NSMakeRange(1, allOrderedNodes.count-2)];
}

// This method updates the addresses of all given waypoints
- (void)mtd_addAddressesFromLocationNodes:(NSArray *)locationNodes toWaypoints:(NSArray *)waypoints {
    MTDAssert(locationNodes.count == waypoints.count, @"Number of locations doesn't match number of waypoints");

    // Parse Addresses of goals
    [locationNodes enumerateObjectsUsingBlock:^(MTDXMLElement *locationNode, NSUInteger idx, __unused BOOL *stop) {
        MTDAddress *address = [self mtd_addressFromLocationNode:locationNode];
        MTDWaypoint *waypoint = waypoints[idx];

        // update address of corresponding waypoint
        waypoint.address = address;

        // update coordinate if not available
        if (!waypoint.hasValidCoordinate) {
            CLLocationCoordinate2D coordinate = [self mtd_coordinateFromLocationNode:locationNode];

            waypoint.coordinate = coordinate;
        }
    }];
}

// This method parses an address and returns an instance of MTDAddress
- (MTDAddress *)mtd_addressFromLocationNode:(MTDXMLElement *)locationNode {
    MTDXMLElement *streetNode = [locationNode firstChildNodeWithName:@"street"];
    MTDXMLElement *cityNode = [locationNode firstChildNodeWithName:@"adminArea5"];
    MTDXMLElement *stateNode = [locationNode firstChildNodeWithName:@"adminArea3"];
    MTDXMLElement *countyNode = [locationNode firstChildNodeWithName:@"adminArea4"];
    MTDXMLElement *postalCodeNode = [locationNode firstChildNodeWithName:@"postalCode"];
    MTDXMLElement *countryNode = [locationNode firstChildNodeWithName:@"adminArea1"];

    MTDAddress *address = [[MTDAddress alloc] initWithCountry:[countryNode contentString]
                                                        state:[stateNode contentString]
                                                       county:[countyNode contentString]
                                                   postalCode:[postalCodeNode contentString]
                                                         city:[cityNode contentString]
                                                       street:[streetNode contentString]];

    return address;
}

- (CLLocationCoordinate2D)mtd_coordinateFromLocationNode:(MTDXMLElement *)locationNode {
    MTDXMLElement *positionNode = [locationNode firstChildNodeWithName:@"latLng"];
    MTDXMLElement *latitudeNode = [positionNode firstChildNodeWithName:@"lat"];
    MTDXMLElement *longitudeNode = [positionNode firstChildNodeWithName:@"lng"];

    if (latitudeNode != nil && longitudeNode != nil) {
        return CLLocationCoordinate2DMake([latitudeNode.contentString doubleValue], [longitudeNode.contentString doubleValue]);
    } else {
        return kCLLocationCoordinate2DInvalid;
    }
}

// This method parses a maneuver and returns an instance of MTDManeuver
- (MTDManeuver *)mtd_maneuverFromManeuverNode:(MTDXMLElement *)maneuverNode {
    MTDXMLElement *positionNode = [maneuverNode firstChildNodeWithName:@"startPoint"];
    MTDXMLElement *latitudeNode = [positionNode firstChildNodeWithName:@"lat"];
    MTDXMLElement *longitudeNode = [positionNode firstChildNodeWithName:@"lng"];

    if (latitudeNode != nil && longitudeNode != nil) {
        MTDXMLElement *directionNode = [maneuverNode firstChildNodeWithName:@"direction"];
        MTDXMLElement *instructionNode = [maneuverNode firstChildNodeWithName:@"narrative"];
        MTDXMLElement *distanceNode = [maneuverNode firstChildNodeWithName:@"distance"];
        MTDXMLElement *timeNode = [maneuverNode firstChildNodeWithName:@"time"];
        MTDXMLElement *turnTypeNode = [maneuverNode firstChildNodeWithName:@"turnType"];

        CLLocationCoordinate2D maneuverCoordinate = CLLocationCoordinate2DMake([latitudeNode.contentString doubleValue],
                                                                               [longitudeNode.contentString doubleValue]);
        CLLocationDistance maneuverDistance = [distanceNode.contentString doubleValue];
        NSTimeInterval maneuverTime = [timeNode.contentString doubleValue];

        MTDManeuver *maneuver = [[MTDManeuver alloc] initWithWaypoint:[MTDWaypoint waypointWithCoordinate:maneuverCoordinate]
                                                             distance:[MTDDistance distanceWithValue:maneuverDistance measurementSystem:MTDMeasurementSystemMetric]
                                                        timeInSeconds:maneuverTime
                                                         instructions:instructionNode.contentString];

        maneuver.cardinalDirection = MTDCardinalDirectionFromMapQuestDescription(directionNode.contentString);
        maneuver.turnType = MTDTurnTypeFromMapQuestDescription(turnTypeNode.contentString);

        return maneuver;
    } else {
        return nil;
    }
}

// This method parses all maneuver nodes of a route
- (NSArray *)mtd_maneuversFromManeuverNodes:(NSArray *)maneuverNodes {
    NSMutableArray *maneuvers = [NSMutableArray arrayWithCapacity:maneuverNodes.count];
    
    for (MTDXMLElement *maneuverNode in maneuverNodes) {
        MTDManeuver *maneuver = [self mtd_maneuverFromManeuverNode:maneuverNode];
        
        if (maneuver != nil) {
            [maneuvers addObject:maneuver];
        }
    }

    // manually add maneuver for arriving at destination
	MTDManeuver *arrivalManeuver = [self mtd_arrivalManeuverWithWaypoint:self.to];
	[maneuvers addObject:arrivalManeuver];
    
    return maneuvers;
}

// This method returns a hand-made arrival maneuver
- (MTDManeuver *)mtd_arrivalManeuverWithWaypoint:(MTDWaypoint *)waypoint {
    // TODO: localize, offer possibility for custom localization
    NSString *destination = waypoint.address != nil ? [waypoint.address fullAddress] : @"destination";
    NSString *instructions = [NSString stringWithFormat:@"Arrive at %@", destination];
    MTDManeuver *arrivalManeuver = [[MTDManeuver alloc] initWithWaypoint:waypoint
                                                                distance:nil
                                                           timeInSeconds:0.
                                                            instructions:instructions];

	arrivalManeuver.turnType = MTDTurnTypeArrive;

    return arrivalManeuver;
}

@end
