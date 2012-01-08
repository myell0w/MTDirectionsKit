#import "MTDirectionsRequestGoogle.h"
#import "MTHTTPFetcher.h"
#import "MTDirectionsRouteType+Google.h"
#import "MTDirectionsParserGoogle.h"


#define kMTDirectionBaseURL         @"http://maps.google.com/maps/api/directions/xml?sensor=true"

@interface MTDirectionsRequestGoogle ()

@property (nonatomic, strong) MTHTTPFetcher *fetcher;
@property (nonatomic, assign) MTDirectionsRouteType routeType;

- (void)requestFinished:(MTHTTPFetcher *)fetcher;

@end

@implementation MTDirectionsRequestGoogle

@synthesize fetcher = fetcher_;
@synthesize routeType = routeType_;

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
        
        routeType_ = routeType;
        fetcher_ = [[MTHTTPFetcher alloc] initWithURLString:address
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

- (void)requestFinished:(MTHTTPFetcher *)fetcher {
    MTDirectionsParser *parser = [[MTDirectionsParserGoogle alloc] initWithFromCoordinate:self.fromCoordinate
                                                                             toCoordinate:self.toCoordinate
                                                                                routeType:self.routeType
                                                                                     data:fetcher.data];
    
    [parser parseWithCompletion:self.completion];
}


@end
