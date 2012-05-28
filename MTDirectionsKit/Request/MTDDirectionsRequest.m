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
@property (nonatomic, strong) NSMutableDictionary *parameters;

@property (nonatomic, readonly) NSString *fullAddress;

@end


@implementation MTDDirectionsRequest

@synthesize fromCoordinate = _fromCoordinate;
@synthesize toCoordinate = _toCoordinate;
@synthesize fromAddress = _fromAddress;
@synthesize toAddress = _toAddress;
@synthesize completion = _completion;
@synthesize routeType = _routeType;
@synthesize httpRequest = _httpRequest;
@synthesize httpAddress = _httpAddress;
@synthesize parserClass = _parserClass;
@synthesize parameters = _parameters;

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
        _parameters = [NSMutableDictionary dictionary];
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
        _parameters = [NSMutableDictionary dictionary];
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDDirectionRequest
////////////////////////////////////////////////////////////////////////

- (void)start {
    self.httpRequest = [[MTDHTTPRequest alloc] initWithAddress:self.fullAddress
                                                callbackTarget:self
                                                        action:@selector(requestFinished:)];
    
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
        // can be nil
        parser.fromAddress = self.fromAddress;
        parser.toAddress = self.toAddress;
        
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

- (void)setValue:(NSString *)value forParameter:(NSString *)parameter {
    [self.parameters setValue:value forKey:parameter];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

- (NSString *)fullAddress {
    NSMutableString *address = [NSMutableString stringWithString:self.httpAddress];
    
    if (self.parameters.count > 0) {
        [address appendString:@"?"];
        
        [self.parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [address appendFormat:@"%@=%@&", key,obj];
        }];
        
        // remove last "&"
        [address deleteCharactersInRange:NSMakeRange(address.length-1, 1)];
    }
    
    return [address copy];
}

@end
