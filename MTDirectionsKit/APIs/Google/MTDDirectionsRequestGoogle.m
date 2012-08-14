#import "MTDDirectionsRequestGoogle.h"
#import "MTDDirectionsRequest+MTDirectionsPrivateAPI.h"
#import "MTDDirectionsRequestOption.h"
#import "MTDDirectionsRouteType+Google.h"
#import "MTDDirectionsParserGoogle.h"
#import "MTDWaypoint.h"
#import "MTDFunctions.h"


#define kMTDGoogleBaseAddress         @"http://maps.googleapis.com/maps/api/directions/xml"


static NSString *mtd_clientId = nil;
static NSString *mtd_signature = nil;


@implementation MTDDirectionsRequestGoogle

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
        
        [self setValue:[from descriptionForAPI:MTDDirectionsAPIGoogle] forParameter:@"origin"];
        [self setValue:[to descriptionForAPI:MTDDirectionsAPIGoogle] forParameter:@"destination"];
        [self setValue:MTDDirectionStringForDirectionRouteTypeGoogle(routeType) forParameter:@"mode"];


        // set parameter for alternative routes?
        BOOL alternativeRoutes = (self.mtd_options & MTDDirectionsRequestOptionAlternativeRoutes) == MTDDirectionsRequestOptionAlternativeRoutes;
        if (alternativeRoutes) {
            [self setValue:@"true" forParameter:@"alternatives"];
        }
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDDirectionsRequest
////////////////////////////////////////////////////////////////////////

- (MTDDirectionsAPI)API {
    return MTDDirectionsAPIGoogle;
}

- (void)setValueForParameterWithIntermediateGoals:(NSArray *)intermediateGoals {
    if (intermediateGoals.count > 0 && self.routeType != MTDDirectionsRouteTypePedestrianIncludingPublicTransport) {
        BOOL optimizeRoute = (self.mtd_options & MTDDirectionsRequestOptionOptimize) == MTDDirectionsRequestOptionOptimize;
        NSMutableString *parameter = [NSMutableString stringWithString:(optimizeRoute ? @"optimize:true" : @"optimize:false")];
        
        [intermediateGoals enumerateObjectsUsingBlock:^(id obj, __unused NSUInteger idx, __unused BOOL *stop) {
            [parameter appendFormat:@"|%@",[obj descriptionForAPI:MTDDirectionsAPIGoogle]];
        }];
        
        [self setValue:parameter forParameter:@"waypoints"];
    }
}

- (NSString *)mtd_HTTPAddress {
    return kMTDGoogleBaseAddress;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDDirectionsRequestGoogle
////////////////////////////////////////////////////////////////////////

+ (void)registerBusinessWithClientId:(NSString *)clientId
                           signature:(NSString *)signature {
    mtd_clientId = clientId;
    mtd_signature = signature;
}

+ (BOOL)businessRegistered {
    return mtd_clientId.length > 0 && mtd_signature.length > 0;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

- (void)mtd_setup {
    [self setValue:@"true" forParameter:@"sensor"];

    if ([[self class] businessRegistered]) {
        [self setValue:mtd_clientId forKey:@"client"];
        [self setValue:mtd_signature forKey:@"signature"];
    }
}

@end
