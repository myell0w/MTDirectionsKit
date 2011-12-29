#import "MTDirectionsRequestMapQuest.h"
#import "MTXMLFetcher.h"
#import "MTDirectionsRouteType+MapQuest.h"
#import "MTDirectionsParserMapQuest.h"

#define kMTDirectionBaseURL         @"http://open.mapquestapi.com/directions/v0/route?outFormat=xml&unit=k&narrativeType=none&shapeFormat=raw&generalize=50"
#define kMTDirectionXPathQuery      @"//shapePoints"

@interface MTDirectionsRequestMapQuest ()

@property (nonatomic, strong) MTXMLFetcher *fetcher;

- (void)requestFinished:(MTXMLFetcher *)fetcher;

@end

@implementation MTDirectionsRequestMapQuest

@synthesize fetcher = fetcher_;

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
        
        fetcher_ = [[MTXMLFetcher alloc] initWithURLString:address
                                                xPathQuery:kMTDirectionXPathQuery
                                                  receiver:self
                                                    action:@selector(requestFinished:)];
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDirectionRequest
////////////////////////////////////////////////////////////////////////

- (void)start {
    [self.fetcher start];
}

- (void)cancel {
    [self.fetcher cancel];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

- (void)requestFinished:(MTXMLFetcher *)fetcher {
    MTDirectionsParser *parser = [[MTDirectionsParserMapQuest alloc] initWithFromCoordinate:self.fromCoordinate
                                                                               toCoordinate:self.toCoordinate
                                                                                       data:fetcher.results];
    
    [parser parseWithCompletion:self.completion];
}


@end
