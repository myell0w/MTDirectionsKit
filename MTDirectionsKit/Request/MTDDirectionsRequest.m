#import "MTDDirectionsRequest.h"
#import "MTDDirectionsRequestMapQuest.h"
#import "MTDDirectionsRequestGoogle.h"
#import "MTDDirectionsParser.h"
#import "MTDDirectionsAPI.h"
#import "MTDLogging.h"
#import "MTDFunctions.h"
#import "MTDDirectionsDefines.h"


////////////////////////////////////////////////////////////////////////
#pragma mark - GCD Queue
////////////////////////////////////////////////////////////////////////

static dispatch_queue_t mtd_parser_queue;
NS_INLINE dispatch_queue_t parser_queue(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *queueIdentifier = @"at.myell0w.MTDirectionsKit.parser";
        mtd_parser_queue = dispatch_queue_create([queueIdentifier UTF8String], 0);
    });
    
    return mtd_parser_queue;
}


////////////////////////////////////////////////////////////////////////
#pragma mark - MTDDirectionsParser
////////////////////////////////////////////////////////////////////////

@interface MTDDirectionsRequest ()

@property (nonatomic, strong) MTDHTTPRequest *httpRequest;
@property (nonatomic, copy) NSString *httpAddress;
@property (nonatomic, assign) Class parserClass;

@end


@implementation MTDDirectionsRequest

@synthesize fromCoordinate = _fromCoordinate;
@synthesize toCoordinate = _toCoordinate;
@synthesize fromAddress = _fromAddress;
@synthesize toAddress = _toAddress;
@synthesize completion = _completion;
@synthesize routeType = _routeType;
@synthesize httpRequest = _httpRequest;
@synthesize parserClass = _parserClass;

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

+ (id)requestFrom:(CLLocationCoordinate2D)fromCoordinate
               to:(CLLocationCoordinate2D)toCoordinate
        routeType:(MTDDirectionsRouteType)routeType
       completion:(mtd_parser_block)completion {
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

+ (id)requestFromAddress:(NSString *)fromAddress
               toAddress:(NSString *)toAddress
               routeType:(MTDDirectionsRouteType)routeType
              completion:(mtd_parser_block)completion {
    MTDDirectionsRequest *request = nil;
    
    switch (MTDDirectionsGetActiveAPI()) {
        case MTDDirectionsAPIGoogle:
            request = [[MTDDirectionsRequestGoogle alloc] initFromAddress:fromAddress
                                                                toAddress:toAddress
                                                                routeType:routeType
                                                               completion:completion];
            break;
            
        case MTDDirectionsAPIMapQuest:
        default:
            request = [[MTDDirectionsRequestMapQuest alloc] initFromAddress:fromAddress
                                                                  toAddress:toAddress
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
        _routeType = routeType;
        _completion = [completion copy];
    }
    
    return self;
}

- (id)initFromAddress:(NSString *)fromAddress
            toAddress:(NSString *)toAddress
            routeType:(MTDDirectionsRouteType)routeType
           completion:(mtd_parser_block)completion {
    if ((self = [super init])) {
        _fromCoordinate = MTDInvalidCLLocationCoordinate2D;
        _toCoordinate = MTDInvalidCLLocationCoordinate2D;
        _fromAddress = [fromAddress copy];
        _toAddress = [toAddress copy];
        _routeType = routeType;
        _completion = [completion copy];
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDDirectionRequest
////////////////////////////////////////////////////////////////////////

- (void)setHttpAddress:(NSString *)httpAddress {
    self.httpRequest = [[MTDHTTPRequest alloc] initWithAddress:httpAddress
                                                callbackTarget:self
                                                        action:@selector(requestFinished:)];
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
        dispatch_async(parser_queue(), ^{
            [parser parseWithCompletion:self.completion];
        });
    } else {
        NSError *error = [NSError errorWithDomain:MTDDirectionsKitErrorDomain
                                             code:httpRequest.failureCode
                                         userInfo:nil];
        
        MTDLogError(@"Error occurred requesting directions from %@ to %@: %@", 
                    MTDStringFromCLLocationCoordinate2D(self.fromCoordinate),
                    MTDStringFromCLLocationCoordinate2D(self.toCoordinate),
                    error);
        
        self.completion(nil, error);
    }
}

@end