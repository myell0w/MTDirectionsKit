#import "MTDDirectionsRequestGoogle.h"
#import "MTDDirectionsRequest+MTDirectionsPrivateAPI.h"
#import "MTDDirectionsRouteType+Google.h"
#import "MTDDirectionsParserGoogle.h"
#import "MTDFunctions.h"


#define kMTDDirectionBaseURL         @"http://maps.google.com/maps/api/directions/xml?sensor=true"


@implementation MTDDirectionsRequestGoogle

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initFrom:(CLLocationCoordinate2D)fromCoordinate
            to:(CLLocationCoordinate2D)toCoordinate
     routeType:(MTDDirectionsRouteType)routeType
    completion:(mtd_parser_block)completion {
    if ((self = [super initFrom:fromCoordinate to:toCoordinate routeType:routeType completion:completion])) {
        NSString *address = [NSString stringWithFormat:@"%@&origin=%f,%f&destination=%f,%f&mode=%@",
                             kMTDDirectionBaseURL, 
                             fromCoordinate.latitude, fromCoordinate.longitude,
                             toCoordinate.latitude, toCoordinate.longitude,
                             MTDDirectionStringForDirectionRouteTypeGoogle(routeType)];
        
        self.parserClass = [MTDDirectionsParserGoogle class];
        self.httpAddress = address;
    }
    
    return self;
}

- (id)initFromAddress:(NSString *)fromAddress
            toAddress:(NSString *)toAddress
            routeType:(MTDDirectionsRouteType)routeType
           completion:(mtd_parser_block)completion {
    if ((self = [super initFromAddress:fromAddress toAddress:toAddress routeType:routeType completion:completion])) {
        NSString *address = [NSString stringWithFormat:@"%@&origin=%@&destination=%@&mode=%@",
                             kMTDDirectionBaseURL, 
                             MTDURLEncodedString(fromAddress),
                             MTDURLEncodedString(toAddress),
                             MTDDirectionStringForDirectionRouteTypeGoogle(routeType)];
        
        self.parserClass = [MTDDirectionsParserGoogle class];
        self.httpAddress = address;
    }
    
    return self;
}


@end
