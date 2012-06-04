#import "MTDDirectionsRequestMapQuest.h"
#import "MTDDirectionsRequest+MTDirectionsPrivateAPI.h"
#import "MTDDirectionsRouteType+MapQuest.h"
#import "MTDDirectionsParserMapQuest.h"
#import "MTDWaypoint.h"
#import "MTDFunctions.h"


#define kMTDMapQuestHostName        @"http://open.mapquestapi.com"
#define kMTDMapQuestServiceName     @"directions"
#define kMTDMapQuestVersionNumber   @"v1"
#define kMTDMapQuestRoutingMethod   @"optimizedroute"
#define kMTDMapQuestBaseAddress     kMTDMapQuestHostName @"/" kMTDMapQuestServiceName @"/" kMTDMapQuestVersionNumber @"/" kMTDMapQuestRoutingMethod


@interface MTDDirectionsRequestMapQuest ()

- (void)setup;

@end


@implementation MTDDirectionsRequestMapQuest

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithFrom:(MTDWaypoint *)from
                to:(MTDWaypoint *)to
 intermediateGoals:(NSArray *)intermediateGoals
         routeType:(MTDDirectionsRouteType)routeType
        completion:(mtd_parser_block)completion {
    if ((self = [super initWithFrom:from to:to intermediateGoals:intermediateGoals routeType:routeType completion:completion])) {
        [self setup];
        
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

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

- (void)setup {
    self.httpAddress = kMTDMapQuestBaseAddress;
    self.parserClass = [MTDDirectionsParserMapQuest class];
    
    [self setValue:@"xml" forParameter:@"outFormat"];
    [self setValue:@"ignore" forParameter:@"ambiguities"];
    [self setValue:@"false" forParameter:@"doReverseGeocode"];
    [self setValue:@"k" forParameter:@"unit"];
    [self setValue:@"none" forParameter:@"narrativeType"];
    [self setValue:@"raw" forParameter:@"shapeFormat"];
    [self setValue:@"0" forParameter:@"generalize"];
}

@end
