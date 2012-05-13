#import "MTDDirectionsRequest.h"
#import "MTDDirectionsRequestMapQuest.h"
#import "MTDDirectionsParser.h"
#import "MTDDirectionsAPI.h"


@interface MTDDirectionsRequest ()

@property (nonatomic, strong) MTDHTTPRequest *httpRequest;
@property (nonatomic, copy) NSString *httpAddress;
@property (nonatomic, assign) Class parserClass;

@end


@implementation MTDDirectionsRequest

@synthesize fromCoordinate = _fromCoordinate;
@synthesize toCoordinate = _toCoordinate;
@synthesize completion = _completion;
@synthesize routeType = _routeType;
@synthesize httpRequest = _httpRequest;
@synthesize parserClass = _parserClass;

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

+ (id)requestFrom:(CLLocationCoordinate2D)fromCoordinate
               to:(CLLocationCoordinate2D)toCoordinate
       completion:(mtd_parser_block)completion {
    return [self requestFrom:fromCoordinate
                          to:toCoordinate
                   routeType:kMTDDefaultDirectionsRouteType
                  completion:completion];
}

+ (id)requestFrom:(CLLocationCoordinate2D)fromCoordinate
               to:(CLLocationCoordinate2D)toCoordinate
        routeType:(MTDDirectionsRouteType)routeType
       completion:(mtd_parser_block)completion {
    MTDDirectionsRequest *request = nil;
    
    switch (MTDDirectionsGetActiveAPI()) {
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
    completion:(mtd_parser_block)completion {
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

- (void)setHttpAddress:(NSString *)httpAddress {
    self.httpRequest = [[MTDHTTPRequest alloc] initWithAddress:httpAddress callbackTarget:self action:@selector(requestFinished:)];
}

- (NSString *)httpAddress {
    return self.httpRequest.urlRequest.URL.absoluteString;
}

- (void)start {
    [self.httpRequest start];
}

- (void)cancel {
    [self.httpRequest cancel];
}

- (void)requestFinished:(MTDHTTPRequest *)httpRequest {
    if (httpRequest.failureCode == 0) {
        NSAssert([self.parserClass isSubclassOfClass:[MTDDirectionsParser class]], @"Parser class must be subclass of MTDDirectionsParser.");
        
        MTDDirectionsParser *parser = [[self.parserClass alloc] initWithFromCoordinate:self.fromCoordinate
                                                                          toCoordinate:self.toCoordinate
                                                                             routeType:self.routeType
                                                                                  data:httpRequest.data];
        
        [parser parseWithCompletion:self.completion];
    } else {
        NSError *error = [NSError errorWithDomain:MTDDirectionsKitErrorDomain
                                             code:httpRequest.failureCode
                                         userInfo:nil];
        
        self.completion(nil, error);
    }
}

@end
