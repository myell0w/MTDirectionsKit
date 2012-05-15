#import "MTDDirectionsRequestMapQuest.h"
#import "MTDDirectionsRequest+MTDirectionsPrivateAPI.h"
#import "MTDDirectionsRouteType+MapQuest.h"
#import "MTDDirectionsParserMapQuest.h"
#import "MTDFunctions.h"


#define kMTDDirectionBaseURL         @"http://open.mapquestapi.com/directions/v0/route?outFormat=xml&unit=k&narrativeType=none&shapeFormat=raw&generalize=50&ambiguities=ignore"


@implementation MTDDirectionsRequestMapQuest

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initFrom:(CLLocationCoordinate2D)fromCoordinate
            to:(CLLocationCoordinate2D)toCoordinate
     routeType:(MTDDirectionsRouteType)routeType
    completion:(mtd_parser_block)completion {
    if ((self = [super initFrom:fromCoordinate to:toCoordinate routeType:routeType completion:completion])) {
        NSString *address = [NSString stringWithFormat:@"%@&from=%f,%f&to=%f,%f&routeType=%@",
                             kMTDDirectionBaseURL, 
                             fromCoordinate.latitude, fromCoordinate.longitude,
                             toCoordinate.latitude, toCoordinate.longitude,
                             MTDDirectionStringForDirectionRouteTypeMapQuest(routeType)];
        
        self.parserClass = [MTDDirectionsParserMapQuest class];
        self.httpAddress = address;
    }
    
    return self;
}

- (id)initFromAddress:(NSString *)fromAddress
            toAddress:(NSString *)toAddress
            routeType:(MTDDirectionsRouteType)routeType
           completion:(mtd_parser_block)completion {
    if ((self = [super initFromAddress:fromAddress toAddress:toAddress routeType:routeType completion:completion])) {
        NSString *address = [NSString stringWithFormat:@"%@&from=%@&to=%@&routeType=%@",
                             kMTDDirectionBaseURL, 
                             MTDURLEncodedString(fromAddress),
                             MTDURLEncodedString(toAddress),
                             MTDDirectionStringForDirectionRouteTypeMapQuest(routeType)];
        
        self.parserClass = [MTDDirectionsParserMapQuest class];
        self.httpAddress = address;
    }
    
    return self;
}

@end
