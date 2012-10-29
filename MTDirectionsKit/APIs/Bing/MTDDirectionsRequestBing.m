#import "MTDDirectionsRequestBing.h"
#import "MTDDirectionsRequest+MTDirectionsPrivateAPI.h"
#import "MTDDirectionsRequestOption.h"
#import "MTDDirectionsRouteType+Bing.h"
#import "MTDWaypoint.h"
#import "MTDFunctions.h"
#import "MTDLocale+Bing.h"


#define kMTDBingHostName                    @"http://dev.virtualearth.net/REST"
#define kMTDBingVersionNumber               @"v1"
#define kMTDBingRestAPI                     @"Routes"

#define kMTDBingMaxRoutes                   @"3"


static NSString *mtd_apiKey = nil;


@implementation MTDDirectionsRequestBing

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

        [self setValue:[from descriptionForAPI:MTDDirectionsAPIBing] forParameter:@"waypoint.0"];
        // "to" gets set in setValueForParameterWithIntermediateGoals
        // [self setValue:[to descriptionForAPI:MTDDirectionsAPIBing] forParameter:@"to"];
        [self setValue:MTDDirectionStringForDirectionRouteTypeBing(routeType) forParameter:@"travelMode"];

        // set parameter for alternative routes?
        BOOL alternativeRoutes = (self.mtd_options & MTDDirectionsRequestOptionAlternativeRoutes) == MTDDirectionsRequestOptionAlternativeRoutes;
        BOOL optimizeRoute = (self.mtd_options & MTDDirectionsRequestOptionOptimize) == MTDDirectionsRequestOptionOptimize;

        if (alternativeRoutes) {
            [self setValue:kMTDBingMaxRoutes forParameter:@"maxSolutions"];
        }
        if (intermediateGoals.count > 0 && optimizeRoute) {
            MTDLogInfo(@"Bing Routes API unfortunately doesn't support optimizing route goals.");
        }

        // set parameter route type
        if (routeType == MTDDirectionsRouteTypeFastestDriving) {
            [self setValue:@"time" forParameter:@"optimize"];
        } else if (routeType == MTDDirectionsRouteTypeShortestDriving) {
            [self setValue:@"distance" forParameter:@"optimize"];
        }

            // set parameter for API Key
        MTDAssert(mtd_apiKey != nil, @"An API Key must be set using [MTDDirectionsRequestBing registerAPIKey:] to use Bing Routes.");
        if (mtd_apiKey != nil) {
            [self setValue:mtd_apiKey forParameter:@"key"];
        }
    }

    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDDirectionsRequest
////////////////////////////////////////////////////////////////////////

- (MTDDirectionsAPI)API {
    return MTDDirectionsAPIBing;
}

- (void)setValueForParameterWithIntermediateGoals:(NSArray *)intermediateGoals {
    __block NSUInteger waypointIndex = 1;

    // set all intermediate waypoints
    [intermediateGoals enumerateObjectsUsingBlock:^(MTDWaypoint *waypoint, NSUInteger idx, __unused BOOL *stop) {
        NSString *parameter = [NSString stringWithFormat:@"viaWaypoint.%d", idx + 1];

        [self setValue:[waypoint descriptionForAPI:[self API]] forParameter:parameter];
        waypointIndex++;
    }];

    // Set last waypoint (=to)
    [self setValue:[self.to descriptionForAPI:MTDDirectionsAPIBing]
      forParameter:[NSString stringWithFormat:@"waypoint.%d", waypointIndex]];
}

- (NSString *)HTTPAddress {
    return [NSString stringWithFormat:@"%@/%@/%@%@",
            kMTDBingHostName,
            kMTDBingVersionNumber,
            kMTDBingRestAPI,
			self.routeType == MTDDirectionsRouteTypePedestrian ? @"/Walking" : @""];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDDirectionsRequestBing
////////////////////////////////////////////////////////////////////////

+ (void)registerAPIKey:(NSString *)APIKey {
    mtd_apiKey = APIKey;
}

+ (BOOL)isAPIKeyRegistered {
    return mtd_apiKey.length > 0;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

- (void)mtd_setup {
    NSString *locale = MTDDirectionsGetLocaleBing();
    
    [self setValue:@"xml" forParameter:@"output"];
    [self setValue:@"true" forParameter:@"suppressStatus"];
    [self setValue:@"Points" forParameter:@"routePathOutput"];
    [self setValue:@"km" forParameter:@"distanceUnit"];
    [self setValue:locale forParameter:@"culture"];
}

@end
