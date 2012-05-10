#import "MTDDirectionsRequestGoogle.h"
#import "MTDDirectionsRequest+MTDirectionsPrivateAPI.h"
#import "MTDDirectionsRouteType+Google.h"
#import "MTDDirectionsParserGoogle.h"


#define kMTDDirectionBaseURL         @"http://maps.google.com/maps/api/directions/xml?sensor=true"


@implementation MTDDirectionsRequestGoogle

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initFrom:(CLLocationCoordinate2D)fromCoordinate
            to:(CLLocationCoordinate2D)toCoordinate
     routeType:(MTDDirectionsRouteType)routeType
    completion:(mtd_direction_block)completion {
    if ((self = [super initFrom:fromCoordinate to:toCoordinate routeType:routeType completion:completion])) {
        NSString *address = [NSString stringWithFormat:@"%@&origin=%f,%f&destination=%f,%f&mode=%@",
                             kMTDDirectionBaseURL, 
                             fromCoordinate.latitude, fromCoordinate.longitude,
                             toCoordinate.latitude, toCoordinate.longitude,
                             MTDDirectionStringForDirectionRouteTypeGoogle(routeType)];
        
        self.parserClass = [MTDDirectionsParserGoogle class];
        self.fetcherAddress = address;
    }
    
    return self;
}


@end
