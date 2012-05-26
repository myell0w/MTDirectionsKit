#import "MTDDirectionsRequestGoogle.h"
#import "MTDDirectionsRequest+MTDirectionsPrivateAPI.h"
#import "MTDDirectionsRouteType+Google.h"
#import "MTDDirectionsParserGoogle.h"
#import "MTDFunctions.h"


#define kMTDGoogleBaseAddress         @"http://maps.google.com/maps/api/directions/xml"


@interface MTDDirectionsRequestGoogle ()

- (void)setup;

@end

@implementation MTDDirectionsRequestGoogle

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initFrom:(CLLocationCoordinate2D)fromCoordinate
            to:(CLLocationCoordinate2D)toCoordinate
     routeType:(MTDDirectionsRouteType)routeType
    completion:(mtd_parser_block)completion {
    if ((self = [super initFrom:fromCoordinate to:toCoordinate routeType:routeType completion:completion])) {
        [self setup];
        
        [self setValue:[NSString stringWithFormat:@"%f,%f",fromCoordinate.latitude, fromCoordinate.longitude] forParameter:@"origin"];
        [self setValue:[NSString stringWithFormat:@"%f,%f",toCoordinate.latitude, toCoordinate.longitude] forParameter:@"destination"];
        [self setValue:MTDDirectionStringForDirectionRouteTypeGoogle(routeType) forParameter:@"mode"];
    }
    
    return self;
}

- (id)initFromAddress:(NSString *)fromAddress
            toAddress:(NSString *)toAddress
            routeType:(MTDDirectionsRouteType)routeType
           completion:(mtd_parser_block)completion {
    if ((self = [super initFromAddress:fromAddress toAddress:toAddress routeType:routeType completion:completion])) {
        [self setup];
        
        [self setValue:MTDURLEncodedString(fromAddress) forParameter:@"origin"];
        [self setValue:MTDURLEncodedString(toAddress) forParameter:@"destination"];
        [self setValue:MTDDirectionStringForDirectionRouteTypeGoogle(routeType) forParameter:@"mode"];
    }
    
    return self;
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
