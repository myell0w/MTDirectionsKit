#import "MTDirectionsRequestGoogle.h"
#import "MTDirectionsRequest+MTDirectionsPrivateAPI.h"
#import "MTDirectionsRouteType+Google.h"
#import "MTDirectionsParserGoogle.h"


#define kMTDirectionBaseURL         @"http://maps.google.com/maps/api/directions/xml?sensor=true"


@implementation MTDirectionsRequestGoogle

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initFrom:(CLLocationCoordinate2D)fromCoordinate
            to:(CLLocationCoordinate2D)toCoordinate
     routeType:(MTDirectionsRouteType)routeType
    completion:(mt_direction_block)completion {
    if ((self = [super initFrom:fromCoordinate to:toCoordinate routeType:routeType completion:completion])) {
        NSString *address = [NSString stringWithFormat:@"%@&origin=%f,%f&destination=%f,%f&mode=%@",
                             kMTDirectionBaseURL, 
                             fromCoordinate.latitude, fromCoordinate.longitude,
                             toCoordinate.latitude, toCoordinate.longitude,
                             MTDirectionStringForDirectionRouteTypeGoogle(routeType)];
        
        self.parserClass = [MTDirectionsParserGoogle class];
        self.fetcherAddress = address;
    }
    
    return self;
}


@end
