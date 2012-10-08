#import "MTDDirectionsRequestMapQuest.h"
#import "MTDDirectionsRequest+MTDirectionsPrivateAPI.h"
#import "MTDDirectionsRequestOption.h"
#import "MTDDirectionsRouteType+MapQuest.h"
#import "MTDWaypoint.h"
#import "MTDFunctions.h"
#import "MTDLocale+MapQuest.h"


#define kMTDMapQuestHostName                    @"http://open.mapquestapi.com"
#define kMTDMapQuestServiceName                 @"directions"
#define kMTDMapQuestVersionNumber               @"v1"
#define kMTDMapQuestRoutingMethodDefault        @"route"
#define kMTDMapQuestRoutingMethodOptimized      @"optimizedroute"
#define kMTDMapQuestRoutingMethodAlternatives   @"alternateroutes"

#define kMTDMapQuestMaxRoutes                   @"3"


@implementation MTDDirectionsRequestMapQuest

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithFrom:(MTDWaypoint *)from
                to:(MTDWaypoint *)to
 intermediateGoals:(NSArray *)intermediateGoals
         routeType:(MTDDirectionsRouteType)routeType
           options:(NSUInteger)options
        completion:(mtd_parser_block)completion {
    if ((self = [super initWithFrom:from to:to intermediateGoals:intermediateGoals routeType:routeType options:options completion:completion])) {
        [self mtd_setup];

        [self setValue:[from descriptionForAPI:[self API]] forParameter:@"from"];
        // "to" gets set in setValueForParameterWithIntermediateGoals
        // [self setValue:[to descriptionForAPI:[self API]] forParameter:@"to"];
        [self setValue:MTDDirectionStringForDirectionRouteTypeMapQuest(routeType) forParameter:@"routeType"];

        // set parameter for alternative routes?
        BOOL alternativeRoutes = (self.mtd_options & MTDDirectionsRequestOptionAlternativeRoutes) == MTDDirectionsRequestOptionAlternativeRoutes;
        if (alternativeRoutes) {
            [self setValue:kMTDMapQuestMaxRoutes forParameter:@"maxRoutes"];
        }
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDDirectionsRequest
////////////////////////////////////////////////////////////////////////

- (MTDDirectionsAPI)API {
    return MTDDirectionsAPIMapQuest;
}

- (void)setValueForParameterWithIntermediateGoals:(NSArray *)intermediateGoals {
    if (intermediateGoals.count > 0) {
        // MapQuest wants all goals (intermediate and end goal) set for parameter "to",
        // we set our destination as the last goal
        NSArray *allDestinations = [intermediateGoals arrayByAddingObject:self.to];
        NSMutableArray *transformedDestinations = [NSMutableArray arrayWithCapacity:allDestinations.count];
        
        // create new array with string-representation of Waypoints for API
        for (MTDWaypoint *destination in allDestinations) {
            [transformedDestinations addObject:[destination descriptionForAPI:[self API]]];
        }
        
        [self setArrayValue:transformedDestinations forParameter:@"to"];
    } else {
        // No intermediate goals, just one to parameter
        [self setValue:[self.to descriptionForAPI:[self API]] forParameter:@"to"];
    }
}

- (NSString *)HTTPAddress {
    NSString *routingMethod = kMTDMapQuestRoutingMethodDefault;
    BOOL optimizeRoute = (self.mtd_options & MTDDirectionsRequestOptionOptimize) == MTDDirectionsRequestOptionOptimize;
    BOOL alternativeRoutes = (self.mtd_options & MTDDirectionsRequestOptionAlternativeRoutes) == MTDDirectionsRequestOptionAlternativeRoutes;

    if (optimizeRoute) {
        routingMethod = kMTDMapQuestRoutingMethodOptimized;
    } else if (alternativeRoutes) {
        routingMethod = kMTDMapQuestRoutingMethodAlternatives;
    }
    
    return [NSString stringWithFormat:@"%@/%@/%@/%@",
            kMTDMapQuestHostName,
            kMTDMapQuestServiceName,
            kMTDMapQuestVersionNumber,
            routingMethod];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

- (void)mtd_setup {
    NSString *locale = MTDDirectionsGetLocaleMapQuest();
    
    [self setValue:@"xml" forParameter:@"outFormat"];
    [self setValue:@"ignore" forParameter:@"ambiguities"];
    [self setValue:@"true" forParameter:@"doReverseGeocode"];
    [self setValue:@"k" forParameter:@"unit"];
    [self setValue:@"text" forParameter:@"narrativeType"];
    [self setValue:@"false" forParameter:@"enhancedNarrative"];
    [self setValue:@"raw" forParameter:@"shapeFormat"];
    [self setValue:@"0" forParameter:@"generalize"];
    [self setValue:@"25" forParameter:@"timeOverage"];
    [self setValue:locale forParameter:@"locale"];
}

@end
