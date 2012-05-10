#import "MTDDirectionsRequestMapQuest.h"
#import "MTDDirectionsRequest+MTDirectionsPrivateAPI.h"
#import "MTDDirectionsRouteType+MapQuest.h"
#import "MTDDirectionsParserMapQuest.h"

#define kMTDDirectionBaseURL         @"http://open.mapquestapi.com/directions/v0/route?outFormat=xml&unit=k&narrativeType=none&shapeFormat=raw&generalize=50"


@implementation MTDDirectionsRequestMapQuest

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initFrom:(CLLocationCoordinate2D)fromCoordinate
            to:(CLLocationCoordinate2D)toCoordinate
     routeType:(MTDDirectionsRouteType)routeType
    completion:(mtd_direction_block)completion {
    if ((self = [super initFrom:fromCoordinate to:toCoordinate routeType:routeType completion:completion])) {
        NSString *address = [NSString stringWithFormat:@"%@&from=%f,%f&to=%f,%f&routeType=%@",
                             kMTDDirectionBaseURL, 
                             fromCoordinate.latitude, fromCoordinate.longitude,
                             toCoordinate.latitude, toCoordinate.longitude,
                             MTDDirectionStringForDirectionRouteTypeMapQuest(routeType)];
        
        self.parserClass = [MTDDirectionsParserMapQuest class];
        self.fetcherAddress = address;
    }
    
    return self;
}

@end
