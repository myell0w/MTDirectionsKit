#import "MTDDirectionsRequestGoogle.h"
#import "MTDDirectionsRequest+MTDirectionsPrivateAPI.h"
#import "MTDDirectionsRouteType+Google.h"
#import "MTDDirectionsParserGoogle.h"
#import "MTDWaypoint.h"
#import "MTDFunctions.h"


#define kMTDGoogleBaseAddress         @"http://maps.google.com/maps/api/directions/xml"


@interface MTDDirectionsRequestGoogle ()

- (void)setup;

@end

@implementation MTDDirectionsRequestGoogle

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
    if (intermediateGoals.count > 0) {
        NSMutableString *parameter = [NSMutableString stringWithString:@"optimize:true"];
        
        [intermediateGoals enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [parameter appendFormat:@"|%@",[obj descriptionForAPI:MTDDirectionsAPIGoogle]];
        }];
        
        [self setValue:parameter forParameter:@"waypoints"];
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

- (void)setup {
    self.parserClass = [MTDDirectionsParserGoogle class];
    self.httpAddress = kMTDGoogleBaseAddress;
    
    [self setValue:@"true" forParameter:@"sensor"];
}

@end
