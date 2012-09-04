#import "MTDDirectionsParserBing.h"
#import "MTDDirectionsOverlay.h"
#import "MTDXMLElement.h"
#import "MTDDistance.h"
#import "MTDFunctions.h"
#import "MTDWaypoint.h"
#import "MTDRoute.h"
#import "MTDAddress.h"
#import "MTDStatusCodeBing.h"


#define kMTDNamespacePrefix     @"b"
#define kMTDNamespaceURI        @"http://schemas.microsoft.com/search/local/ws/rest/v1"


@implementation MTDDirectionsParserBing

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDDirectionsParser
////////////////////////////////////////////////////////////////////////

- (void)parseWithCompletion:(mtd_parser_block)completion {
    MTDAssert(completion != nil, @"Completion block must be set");

    MTDXMLElement *statusCodeNode = [MTDXMLElement nodeForXPathQuery:@"/b:Response/b:StatusCode" onXML:self.data namespacePrefix:kMTDNamespacePrefix namespaceURI:kMTDNamespaceURI];
    MTDStatusCodeBing statusCode = MTDStatusCodeBingSuccess;
    MTDDirectionsOverlay *overlay = nil;
    NSError *error = nil;

    if (statusCodeNode != nil) {
        statusCode = (MTDStatusCodeBing)[statusCodeNode.contentString integerValue];
    }

    if (statusCode == MTDStatusCodeBingSuccess) {
        // All returned routes (can be several if using alternative routes)
        NSArray *routeNodes = [MTDXMLElement nodesForXPathQuery:@"//b:Route" onXML:self.data namespacePrefix:kMTDNamespacePrefix namespaceURI:kMTDNamespaceURI];
        MTDXMLElement *copyrightNode = [MTDXMLElement nodeForXPathQuery:@"/b:Response/b:Copyright" onXML:self.data namespacePrefix:kMTDNamespacePrefix namespaceURI:kMTDNamespaceURI];
        NSArray *warningNodes = [MTDXMLElement nodesForXPathQuery:@"//b:Warning" onXML:self.data namespacePrefix:kMTDNamespacePrefix namespaceURI:kMTDNamespaceURI];
        NSMutableArray *routes = [NSMutableArray arrayWithCapacity:routeNodes.count];
        NSArray *orderedIntermediateGoals = nil;

        // there is either only one route (possibly optimized with intermediate goals) or several without intermediate goals,
        // so in the second case the locations are always from and to and the locationSequence returns nil (gets checked in mtd_orderedIntermediateGoals)
        NSArray *addressNodesExceptTo = [MTDXMLElement nodesForXPathQuery:@"//b:Route[1]/b:RouteLeg/b:StartLocation/b:Address" onXML:self.data namespacePrefix:kMTDNamespacePrefix namespaceURI:kMTDNamespaceURI];
        MTDXMLElement *toAddressNode = [MTDXMLElement nodeForXPathQuery:@"//b:Route[1]/b:RouteLeg[last()]/b:EndLocation/b:Address" onXML:self.data namespacePrefix:kMTDNamespacePrefix namespaceURI:kMTDNamespaceURI];
        NSArray *locationAddressNodes = [addressNodesExceptTo arrayByAddingObject:toAddressNode];
        NSArray *locationSequenceNodes = nil; // = [MTDXMLElement nodesForXPathQuery:@"//route[1]/waypoint_index" onXML:self.data];


        // Parse Routes
        {
            NSString *copyright = copyrightNode.contentString;
            NSArray *warnings = warningNodes.count > 0 ? [warningNodes valueForKey:MTDKey(contentString)] : nil;
            
            for (MTDXMLElement *routeNode in routeNodes) {
                MTDRoute *route = [self mtd_routeFromRouteNode:routeNode copyright:copyright warnings:warnings];

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
            //NSArray *allWaypoints = [self mtd_waypointsIncludingFromAndToWithIntermediateGoals:orderedIntermediateGoals];

            // Bing only seems to return addresses for the start- and endlocation
            [self mtd_addAddressesFromAddressNodes:locationAddressNodes toWaypoints:@[self.from, self.to]];
        }

        overlay = [[MTDDirectionsOverlay alloc] initWithRoutes:routes
                                             intermediateGoals:orderedIntermediateGoals
                                                     routeType:self.routeType];
    } else {
        error = [NSError errorWithDomain:MTDDirectionsKitErrorDomain
                                    code:statusCode
                                userInfo:@{MTDDirectionsKitDataKey:self.data}];

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

- (MTDRoute *)mtd_routeFromRouteNode:(MTDXMLElement *)routeNode copyright:(NSString *)copyright warnings:(NSArray *)warnings {
    NSArray *waypointNodes = [routeNode childNodesTraversingAllChildrenWithPath:@"RoutePath.Line.Point"];
    MTDXMLElement *distanceNode = [routeNode firstChildNodeWithName:@"TravelDistance"];
    MTDXMLElement *timeNode = [routeNode firstChildNodeWithName:@"TravelDuration"];
    MTDXMLElement *idNode = [routeNode firstChildNodeWithName:@"Id"];

    MTDDistance *distance = nil;
    NSTimeInterval timeInSeconds = -1.;
    NSMutableDictionary *additionalInfo = [NSMutableDictionary dictionary];

    // Parse waypoints
    NSArray *waypoints = [self mtd_waypointsFromWaypointNodes:waypointNodes];

    // Parse Additional Info of directions
    {
        if (distanceNode != nil) {
            double distanceInKm = [distanceNode.contentString doubleValue];

            distance = [MTDDistance distanceWithValue:distanceInKm measurementSystem:MTDMeasurementSystemMetric];
        }

        if (timeNode != nil) {
            timeInSeconds = [timeNode.contentString doubleValue];
        }

        if (copyright != nil) {
            [additionalInfo setValue:copyright forKey:MTDAdditionalInfoCopyrightsKey];
        }

        if (warnings != nil) {
            [additionalInfo setValue:warnings forKey:MTDAdditionalInfoWarningsKey];
        }
    }

    MTDRoute *route = [[MTDRoute alloc] initWithWaypoints:waypoints
                                                 distance:distance
                                            timeInSeconds:timeInSeconds
                                           additionalInfo:additionalInfo];

    route.name = idNode.contentString;

    return route;
}

// This method parses the waypointNodes and returns an array of MTDWaypoints
- (NSArray *)mtd_waypointsFromWaypointNodes:(NSArray *)waypointNodes {
    NSMutableArray *waypoints = [NSMutableArray arrayWithCapacity:waypointNodes.count+2];

    // add start coordinate
    if (self.from != nil && CLLocationCoordinate2DIsValid(self.from.coordinate)) {
        [waypoints addObject:self.from];
    }

    // There should only be one element "shapePoints"
    for (MTDXMLElement *childNode in waypointNodes) {
        MTDXMLElement *latitudeNode = [childNode firstChildNodeWithName:@"Latitude"];
        MTDXMLElement *longitudeNode = [childNode firstChildNodeWithName:@"Longitude"];

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
    // Parse Addresses of goals
    [addressNodes enumerateObjectsUsingBlock:^(MTDXMLElement *addressNode, NSUInteger idx, __unused BOOL *stop) {
        MTDAddress *address = [self mtd_addressFromAddressNode:addressNode];

        if (idx < waypoints.count) {
        MTDWaypoint *waypoint = waypoints[idx];

        // update address of corresponding waypoint
        waypoint.address = address;
        }
    }];
}

// This method parses an address and returns an instance of MTDAddress
- (MTDAddress *)mtd_addressFromAddressNode:(MTDXMLElement *)addressNode {
    MTDXMLElement *streetNode = [addressNode firstChildNodeWithName:@"AddressLine"];
    MTDXMLElement *cityNode = [addressNode firstChildNodeWithName:@"Locality"];
    MTDXMLElement *stateNode = [addressNode firstChildNodeWithName:@"AdminDistrict"];
    MTDXMLElement *countyNode = [addressNode firstChildNodeWithName:@"AdminDistrict2"];
    MTDXMLElement *postalCodeNode = [addressNode firstChildNodeWithName:@"PostalCode"];
    MTDXMLElement *countryNode = [addressNode firstChildNodeWithName:@"CountryRegion"];

    if (streetNode == nil) {
        streetNode = [addressNode firstChildNodeWithName:@"Landmark"];
    }

    MTDAddress *address = [[MTDAddress alloc] initWithCountry:[countryNode contentString]
                                                        state:[stateNode contentString]
                                                       county:[countyNode contentString]
                                                   postalCode:[postalCodeNode contentString]
                                                         city:[cityNode contentString]
                                                       street:[streetNode contentString]];

    return address;
}

// This method returns an array of all waypoints including from, to and intermediateGoals if specified
- (NSArray *)mtd_waypointsIncludingFromAndToWithIntermediateGoals:(NSArray *)intermediateGoals {
    NSMutableArray *allGoals = intermediateGoals != nil ? [NSMutableArray arrayWithArray:intermediateGoals] : [NSMutableArray array];
    
    // insert from and to at the right places
    [allGoals insertObject:self.from atIndex:0];
    [allGoals addObject:self.to];
    
    return allGoals;
}

@end
