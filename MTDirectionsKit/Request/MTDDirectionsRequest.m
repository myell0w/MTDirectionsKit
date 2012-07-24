#import "MTDDirectionsRequest.h"
#import "MTDDirectionsRequestMapQuest.h"
#import "MTDDirectionsRequestGoogle.h"
#import "MTDDirectionsParser.h"
#import "MTDDirectionsAPI.h"
#import "MTDFunctions.h"
#import "MTDDirectionsDefines.h"


////////////////////////////////////////////////////////////////////////
#pragma mark - MTDDirectionsParser
////////////////////////////////////////////////////////////////////////

@interface MTDDirectionsRequest ()

/** Dictionary containing all parameter key-value pairs of the request */
@property (nonatomic, strong, setter = mtd_setParameters:) NSMutableDictionary *mtd_parameters;
/** Appends all parameters to httpAddress */
@property (nonatomic, readonly) NSString *mtd_fullAddress;

// Private API from MTDDirectionsRequest+MTDDirectionsPrivateAPI.h
@property (nonatomic, strong, setter = mtd_setHttpRequest:) MTDHTTPRequest *mtd_httpRequest;
@property (nonatomic, readonly) NSString *mtd_httpAddress;
@property (nonatomic, readonly) Class mtd_parserClass;
@property (nonatomic, readonly) BOOL mtd_optimizeRoute;

@end


@implementation MTDDirectionsRequest

@synthesize from = _from;
@synthesize to = _to;
@synthesize intermediateGoals = _intermediateGoals;
@synthesize completion = _completion;
@synthesize routeType = _routeType;
@synthesize mtd_httpRequest = _mtd_httpRequest;
@synthesize mtd_optimizeRoute = _mtd_optimizeRoute;
@synthesize mtd_parameters = _mtd_parameters;

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

+ (id)requestFrom:(MTDWaypoint *)from
               to:(MTDWaypoint *)to
intermediateGoals:(NSArray *)intermediateGoals
    optimizeRoute:(BOOL)optimizeRoute
        routeType:(MTDDirectionsRouteType)routeType
       completion:(mtd_parser_block)completion {
    MTDDirectionsRequest *request = nil;
    
    switch (MTDDirectionsGetActiveAPI()) {
        case MTDDirectionsAPIGoogle:
            request = [[MTDDirectionsRequestGoogle alloc] initWithFrom:from
                                                                    to:to
                                                     intermediateGoals:intermediateGoals
                                                         optimizeRoute:optimizeRoute
                                                             routeType:routeType
                                                            completion:completion];
            break;
            
        case MTDDirectionsAPIMapQuest:
        default:
            request = [[MTDDirectionsRequestMapQuest alloc] initWithFrom:from
                                                                      to:to
                                                       intermediateGoals:intermediateGoals
                                                           optimizeRoute:optimizeRoute
                                                               routeType:routeType
                                                              completion:completion];
            break;
            
    }
    
    return request;
}

- (id)initWithFrom:(MTDWaypoint *)from
                to:(MTDWaypoint *)to
 intermediateGoals:(NSArray *)intermediateGoals
     optimizeRoute:(BOOL)optimizeRoute
         routeType:(MTDDirectionsRouteType)routeType
        completion:(mtd_parser_block)completion {
    if ((self = [super init])) {
        _from = from;
        _to = to;
        _intermediateGoals = [intermediateGoals copy];
        _mtd_optimizeRoute = optimizeRoute;
        _routeType = routeType;
        _completion = [completion copy];
        _mtd_parameters = [NSMutableDictionary dictionary];
        
        [self setValueForParameterWithIntermediateGoals:intermediateGoals];
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDDirectionRequest
////////////////////////////////////////////////////////////////////////

- (void)start {
    NSString *address = self.mtd_fullAddress;

    self.mtd_httpRequest = [[MTDHTTPRequest alloc] initWithAddress:address
                                                callbackTarget:self
                                                        action:@selector(requestFinished:)];
    
    [self.mtd_httpRequest start];
}

- (void)cancel {
    [self.mtd_httpRequest cancel];
}

- (void)requestFinished:(MTDHTTPRequest *)httpRequest {
    if (httpRequest.failureCode == 0) {
        MTDAssert([self.mtd_parserClass isSubclassOfClass:[MTDDirectionsParser class]], @"Parser class must be subclass of MTDDirectionsParser.");
        
        MTDDirectionsParser *parser = [[self.mtd_parserClass alloc] initWithFrom:self.from
                                                                          to:self.to
                                                           intermediateGoals:self.intermediateGoals
                                                                   routeType:self.routeType
                                                                        data:httpRequest.data];

        dispatch_queue_t parserQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0L);
        dispatch_async(parserQueue, ^{
            [parser parseWithCompletion:self.completion];
        });
    } else {
        NSError *error = [NSError errorWithDomain:MTDDirectionsKitErrorDomain
                                             code:httpRequest.failureCode
                                         userInfo:nil];
        
        MTDLogError(@"Error occurred requesting directions from %@ to %@: %@", self.from, self.to, error);
        
        self.completion(nil, error);
    }
}

- (void)setValue:(NSString *)value forParameter:(NSString *)parameter {
    MTDAssert(value != nil && parameter != nil, @"Value and Parameter must be different from nil");

    if (value != nil && parameter != nil) {
        [self.mtd_parameters setObject:value forKey:parameter];
    }
}

- (void)setArrayValue:(NSArray *)array forParameter:(NSString *)parameter {
    MTDAssert(array.count > 0 && parameter != nil, @"Array and Parameter must be different from nil");

    if (array.count > 0 && parameter != nil) {
        [self.mtd_parameters setObject:array forKey:parameter];
    }
}

- (void)setValueForParameterWithIntermediateGoals:(NSArray *) __unused intermediateGoals {
    MTDLogError(@"setValueForParameterWithIntermediateGoals was called on a request that doesn't override it (Class: %@)", 
                NSStringFromClass([self class]));
    
    [self doesNotRecognizeSelector:_cmd];
}

- (NSString *)httpAddress {
    MTDLogError(@"httpAddress was called on a request that doesn't override it (Class: %@)", 
                NSStringFromClass([self class]));
    
    [self doesNotRecognizeSelector:_cmd];
    
    return nil;
}

- (Class)parserClass {
    MTDLogError(@"parserClass was called on a request that doesn't override it (Class: %@)", 
                NSStringFromClass([self class]));
    
    [self doesNotRecognizeSelector:_cmd];
    
    return nil;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

- (NSString *)fullAddress {
    MTDAssert(self.mtd_httpAddress.length > 0, @"HTTP Address must be set.");

    NSMutableString *address = [NSMutableString stringWithString:self.mtd_httpAddress];
    
    if (self.mtd_parameters.count > 0) {
        [address appendString:@"?"];
        
        [self.mtd_parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, __unused BOOL *stop) {
            if ([obj isKindOfClass:[NSArray class]]) {
                for (id value in obj) {
                    [address appendFormat:@"%@=%@&", key, MTDURLEncodedString([value description])];
                }
            } else {
                [address appendFormat:@"%@=%@&", key, MTDURLEncodedString([obj description])];
            }
        }];
        
        // remove last "&"
        NSRange lastCharacterRange = NSMakeRange(address.length-1, 1);
        [address deleteCharactersInRange:lastCharacterRange];
    }
    
    return [address copy];
}

@end
