#import "MTDDirectionsRequest.h"
#import "MTDDirectionsRequestMapQuest.h"
#import "MTDDirectionsRequestGoogle.h"
#import "MTDDirectionsParser.h"
#import "MTDDirectionsAPI.h"


@interface MTDDirectionsRequest ()

@property (nonatomic, strong) MTHTTPFetcher *fetcher;
@property (nonatomic, copy) NSString *fetcherAddress;
@property (nonatomic, assign) Class parserClass;

@end


@implementation MTDDirectionsRequest

@synthesize fromCoordinate = _fromCoordinate;
@synthesize toCoordinate = _toCoordinate;
@synthesize completion = _completion;
@synthesize routeType = _routeType;
@synthesize fetcher = _fetcher;
@synthesize parserClass = _parserClass;

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

+ (id)requestFrom:(CLLocationCoordinate2D)fromCoordinate
               to:(CLLocationCoordinate2D)toCoordinate
       completion:(mtd_direction_block)completion {
    return [self requestFrom:fromCoordinate
                          to:toCoordinate
                   routeType:kMTDDefaultDirectionsRouteType
                  completion:completion];
}

+ (id)requestFrom:(CLLocationCoordinate2D)fromCoordinate
               to:(CLLocationCoordinate2D)toCoordinate
        routeType:(MTDDirectionsRouteType)routeType
       completion:(mtd_direction_block)completion {
    MTDDirectionsRequest *request = nil;
    
    switch (MTDDirectionsGetActiveAPI()) {
        case MTDDirectionsAPIGoogle:
            request = [[MTDDirectionsRequestGoogle alloc] initFrom:fromCoordinate
                                                               to:toCoordinate
                                                        routeType:routeType
                                                       completion:completion];
            break;
            
        case MTDDirectionsAPIMapQuest:
        default:
            request = [[MTDDirectionsRequestMapQuest alloc] initFrom:fromCoordinate
                                                                 to:toCoordinate
                                                          routeType:routeType
                                                         completion:completion];
            break;
            
    }
    
    return request;
}

- (id)initFrom:(CLLocationCoordinate2D)fromCoordinate
            to:(CLLocationCoordinate2D)toCoordinate
     routeType:(MTDDirectionsRouteType)routeType
    completion:(mtd_direction_block)completion {
    if ((self = [super init])) {
        _fromCoordinate = fromCoordinate;
        _toCoordinate = toCoordinate;
        _completion = completion;
        _routeType = routeType;
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDDirectionRequest
////////////////////////////////////////////////////////////////////////

- (void)setFetcherAddress:(NSString *)fetcherAddress {
    self.fetcher = [[MTHTTPFetcher alloc] initWithURLString:fetcherAddress
                                                   receiver:self
                                                     action:@selector(requestFinished:)];
}

- (NSString *)fetcherAddress {
    return self.fetcher.urlRequest.URL.absoluteString;
}

- (void)start {
    [self.fetcher start];
}

- (void)cancel {
    [self.fetcher cancel];
}

- (void)requestFinished:(MTHTTPFetcher *)fetcher {
    NSAssert([self.parserClass isSubclassOfClass:[MTDDirectionsParser class]], @"Parser class must be subclass of MTDDirectionsParser.");
    
    MTDDirectionsParser *parser = [[self.parserClass alloc] initWithFromCoordinate:self.fromCoordinate
                                                                     toCoordinate:self.toCoordinate
                                                                        routeType:self.routeType
                                                                             data:fetcher.data];
    
    [parser parseWithCompletion:self.completion];
}

@end
