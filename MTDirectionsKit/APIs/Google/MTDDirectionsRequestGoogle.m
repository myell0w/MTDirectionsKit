#import "MTDDirectionsRequestGoogle.h"
#import "MTDDirectionsRequest+MTDirectionsPrivateAPI.h"
#import "MTDDirectionsRouteType+Google.h"
#import "MTDDirectionsParserGoogle.h"
#import "MTDWaypoint.h"
#import "MTDFunctions.h"


#define kMTDGoogleBaseAddress         @"http://maps.googleapis.com/maps/api/directions/xml"


@implementation MTDDirectionsRequestGoogle

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
        
        [self setValue:[from descriptionForAPI:MTDDirectionsAPIGoogle] forParameter:@"origin"];
        [self setValue:[to descriptionForAPI:MTDDirectionsAPIGoogle] forParameter:@"destination"];
        [self setValue:MTDDirectionStringForDirectionRouteTypeGoogle(routeType) forParameter:@"mode"];
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDDirectionsRequest
////////////////////////////////////////////////////////////////////////

- (void)setValueForParameterWithIntermediateGoals:(NSArray *)intermediateGoals {
    if (intermediateGoals.count > 0 && self.routeType != MTDDirectionsRouteTypePedestrianIncludingPublicTransport) {
        NSMutableString *parameter = [NSMutableString stringWithString:(self.mtd_optimizeRoute ? @"optimize:true" : @"optimize:false")];
        
        [intermediateGoals enumerateObjectsUsingBlock:^(id obj, __unused NSUInteger idx, __unused BOOL *stop) {
            [parameter appendFormat:@"|%@",[obj descriptionForAPI:MTDDirectionsAPIGoogle]];
        }];
        
        [self setValue:parameter forParameter:@"waypoints"];
    }
}

- (NSString *)mtd_HTTPAddress {
    return kMTDGoogleBaseAddress;
}

- (Class)mtd_parserClass {
    return [MTDDirectionsParserGoogle class];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

- (void)mtd_setup {
    [self setValue:@"true" forParameter:@"sensor"];
}

@end
