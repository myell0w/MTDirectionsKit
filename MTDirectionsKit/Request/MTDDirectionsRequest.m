#import "MTDDirectionsRequest.h"
#import "MTDDirectionsRequestMapQuest.h"
#import "MTDDirectionsRequestGoogle.h"
#import "MTDDirectionsParser.h"
#import "MTDDirectionsAPI.h"
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
@property (nonatomic, readonly) NSString *httpAddress;
@property (nonatomic, readonly) Class parserClass;
@property (nonatomic, readonly) BOOL optimizeRoute;
@property (nonatomic, strong) NSMutableDictionary *parameters;

/** Appends all parameters to httpAddress */
@property (nonatomic, readonly) NSString *fullAddress;

@end


@implementation MTDDirectionsRequest

@synthesize from = _from;
@synthesize to = _to;
@synthesize intermediateGoals = _intermediateGoals;
@synthesize completion = _completion;
@synthesize routeType = _routeType;
@synthesize httpRequest = _httpRequest;
@synthesize optimizeRoute = _optimizeRoute;
@synthesize parameters = _parameters;

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
        _optimizeRoute = optimizeRoute;
        _routeType = routeType;
        _completion = [completion copy];
        _parameters = [NSMutableDictionary dictionary];
        
        [self setValueForParameterWithIntermediateGoals:intermediateGoals];
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDDirectionRequest
////////////////////////////////////////////////////////////////////////

- (void)start {
    NSString *address = self.fullAddress;

    self.httpRequest = [[MTDHTTPRequest alloc] initWithAddress:address
                                                callbackTarget:self
                                                        action:@selector(requestFinished:)];
    
    [self.httpRequest start];
}

- (void)cancel {
    [self.httpRequest cancel];
}

- (void)requestFinished:(MTDHTTPRequest *)httpRequest {
    if (httpRequest.failureCode == 0) {
        MTDAssert([self.parserClass isSubclassOfClass:[MTDDirectionsParser class]], @"Parser class must be subclass of MTDDirectionsParser.");
        
        MTDDirectionsParser *parser = [[self.parserClass alloc] initWithFrom:self.from
                                                                          to:self.to
                                                           intermediateGoals:self.intermediateGoals
                                                                   routeType:self.routeType
                                                                        data:httpRequest.data];
        
        dispatch_async(parser_queue(), ^{
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
        [self.parameters setObject:value forKey:parameter];
    }
}

- (void)setArrayValue:(NSArray *)array forParameter:(NSString *)parameter {
    MTDAssert(array.count > 0 && parameter != nil, @"Array and Parameter must be different from nil");

    if (array.count > 0 && parameter != nil) {
        [self.parameters setObject:array forKey:parameter];
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
    MTDAssert(self.httpAddress.length > 0, @"HTTP Address must be set.");

    NSMutableString *address = [NSMutableString stringWithString:self.httpAddress];
    
    if (self.parameters.count > 0) {
        [address appendString:@"?"];
        
        [self.parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, __unused BOOL *stop) {
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
