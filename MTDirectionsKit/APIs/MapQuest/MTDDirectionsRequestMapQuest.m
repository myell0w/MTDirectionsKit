#import "MTDDirectionsRequestMapQuest.h"
#import "MTDDirectionsRequest+MTDirectionsPrivateAPI.h"
#import "MTDDirectionsRouteType+MapQuest.h"
#import "MTDDirectionsParserMapQuest.h"
#import "MTDWaypoint.h"
#import "MTDFunctions.h"


#define kMTDMapQuestHostName                    @"http://open.mapquestapi.com"
#define kMTDMapQuestServiceName                 @"directions"
#define kMTDMapQuestVersionNumber               @"v1"
#define kMTDMapQuestRoutingMethodDefault        @"route"
#define kMTDMapQuestRoutingMethodOptimized      @"optimizedroute"
#define kMTDMapQuestRoutingMethodAlternatives   @"alternateroutes"
// http://open.mapquestapi.com/directions/v1/alternateroutes?from=Reading,%20PA&to=Washington,%20DC&maxRoutes=3&ambiguities=ignore


@implementation MTDDirectionsRequestMapQuest

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithFrom:(MTDWaypoint *)from
                to:(MTDWaypoint *)to
 intermediateGoals:(NSArray *)intermediateGoals
     optimizeRoute:(BOOL)optimizeRoute
         routeType:(MTDDirectionsRouteType)routeType
        completion:(mtd_parser_block)completion {
    if ((self = [super initWithFrom:from to:to intermediateGoals:intermediateGoals optimizeRoute:optimizeRoute routeType:routeType completion:completion])) {
        [self mtd_setup];
        
        [self setValue:[from descriptionForAPI:MTDDirectionsAPIMapQuest] forParameter:@"from"];
        // "to" gets set in setValueForParameterWithIntermediateGoals
        // [self setValue:[to descriptionForAPI:MTDDirectionsAPIMapQuest] forParameter:@"to"];
        [self setValue:MTDDirectionStringForDirectionRouteTypeMapQuest(routeType) forParameter:@"routeType"];
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDDirectionsRequest
////////////////////////////////////////////////////////////////////////

- (void)setMaximumNumberOfAlternatives:(NSUInteger)maximumNumberOfAlternatives {
    [super setMaximumNumberOfAlternatives:maximumNumberOfAlternatives];

    // set parameter for alternative routes
    if (maximumNumberOfAlternatives > kMTDDefaultNumberOfAlternatives) {
        [self setValue:[NSString stringWithFormat:@"%d", maximumNumberOfAlternatives + 1] forParameter:@"maxRoutes"];
    }
}

- (void)setValueForParameterWithIntermediateGoals:(NSArray *)intermediateGoals {
    if (intermediateGoals.count > 0) {
        // MapQuest wants all goals (intermediate and end goal) set for parameter "to",
        // we set our destination as the last goal
        NSArray *allDestinations = [intermediateGoals arrayByAddingObject:self.to];
        NSMutableArray *transformedDestinations = [NSMutableArray arrayWithCapacity:allDestinations.count];
        
        // create new array with string-representation of Waypoints for API
        for (MTDWaypoint *destination in allDestinations) {
            [transformedDestinations addObject:[destination descriptionForAPI:MTDDirectionsAPIMapQuest]];
        }
        
        [self setArrayValue:transformedDestinations forParameter:@"to"];
    } else {
        // No intermediate goals, just one to parameter
        [self setValue:[self.to descriptionForAPI:MTDDirectionsAPIMapQuest] forParameter:@"to"];
    }
}

- (NSString *)mtd_HTTPAddress {
    NSString *routingMethod = kMTDMapQuestRoutingMethodDefault;

    if (self.mtd_optimizeRoute) {
        routingMethod = kMTDMapQuestRoutingMethodOptimized;
    } else if (self.maximumNumberOfAlternatives > kMTDDefaultNumberOfAlternatives) {
        routingMethod = kMTDMapQuestRoutingMethodAlternatives;
    }
    
    return [NSString stringWithFormat:@"%@/%@/%@/%@",
            kMTDMapQuestHostName,
            kMTDMapQuestServiceName,
            kMTDMapQuestVersionNumber,
            routingMethod];
}

- (Class)mtd_parserClass {
    return [MTDDirectionsParserMapQuest class];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

- (void)mtd_setup {
    [self setValue:@"xml" forParameter:@"outFormat"];
    [self setValue:@"ignore" forParameter:@"ambiguities"];
    [self setValue:@"true" forParameter:@"doReverseGeocode"];
    [self setValue:@"k" forParameter:@"unit"];
    [self setValue:@"none" forParameter:@"narrativeType"];
    [self setValue:@"raw" forParameter:@"shapeFormat"];
    [self setValue:@"0" forParameter:@"generalize"];
}

@end
