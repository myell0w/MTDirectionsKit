#import "MTDDirectionsRequestMapQuest.h"
#import "MTDDirectionsRequest+MTDirectionsPrivateAPI.h"
#import "MTDDirectionsRouteType+MapQuest.h"
#import "MTDDirectionsParserMapQuest.h"
#import "MTDFunctions.h"


#define kMTDMapQuestBaseAddress         @"http://open.mapquestapi.com/directions/v0/route"


@interface MTDDirectionsRequestMapQuest ()

- (void)setup;

@end


@implementation MTDDirectionsRequestMapQuest

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initFrom:(CLLocationCoordinate2D)fromCoordinate
            to:(CLLocationCoordinate2D)toCoordinate
     routeType:(MTDDirectionsRouteType)routeType
    completion:(mtd_parser_block)completion {
    if ((self = [super initFrom:fromCoordinate to:toCoordinate routeType:routeType completion:completion])) {
        [self setup];
        
        [self setValue:[NSString stringWithFormat:@"%f,%f", fromCoordinate.latitude, fromCoordinate.longitude] forParameter:@"from"];
        [self setValue:[NSString stringWithFormat:@"%f,%f", toCoordinate.latitude, toCoordinate.longitude] forParameter:@"to"];
        [self setValue:MTDDirectionStringForDirectionRouteTypeMapQuest(routeType) forParameter:@"routeType"];
    }
    
    return self;
}

- (id)initFromAddress:(NSString *)fromAddress
            toAddress:(NSString *)toAddress
            routeType:(MTDDirectionsRouteType)routeType
           completion:(mtd_parser_block)completion {
    if ((self = [super initFromAddress:fromAddress toAddress:toAddress routeType:routeType completion:completion])) {
        [self setup];
        
        [self setValue:MTDURLEncodedString(fromAddress) forParameter:@"from"];
        [self setValue:MTDURLEncodedString(toAddress) forParameter:@"to"];
        [self setValue:MTDDirectionStringForDirectionRouteTypeMapQuest(routeType) forParameter:@"routeType"];
    }
    
    return self;
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
