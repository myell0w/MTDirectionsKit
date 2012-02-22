#import "MTDirectionsRequestMapQuest.h"
#import "MTDirectionsRequest+MTDirectionsPrivateAPI.h"
#import "MTDirectionsRouteType+MapQuest.h"
#import "MTDirectionsParserMapQuest.h"

#define kMTDirectionBaseURL         @"http://open.mapquestapi.com/directions/v0/route?outFormat=xml&unit=k&narrativeType=none&shapeFormat=raw&generalize=50"


@implementation MTDirectionsRequestMapQuest

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initFrom:(CLLocationCoordinate2D)fromCoordinate
            to:(CLLocationCoordinate2D)toCoordinate
     routeType:(MTDirectionsRouteType)routeType
    completion:(mt_direction_block)completion {
    if ((self = [super initFrom:fromCoordinate to:toCoordinate routeType:routeType completion:completion])) {
        NSString *address = [NSString stringWithFormat:@"%@&from=%f,%f&to=%f,%f&routeType=%@",
                             kMTDirectionBaseURL, 
                             fromCoordinate.latitude, fromCoordinate.longitude,
                             toCoordinate.latitude, toCoordinate.longitude,
                             MTDirectionStringForDirectionRouteTypeMapQuest(routeType)];
        
        self.parserClass = [MTDirectionsParserMapQuest class];
        self.fetcherAddress = address;
    }
    
    return self;
}

@end
