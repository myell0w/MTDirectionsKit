#import "MTDDirectionsRequest.h"
#import "MTDDirectionsRequestMapQuest.h"
#import "MTDDirectionsRequestGoogle.h"
#import "MTDDirectionsRequestOption.h"
#import "MTDDirectionsParser.h"
#import "MTDDirectionsAPI+MTDirectionsPrivateAPI.h"
#import "MTDFunctions.h"
#import "MTDDirectionsDefines.h"


@interface MTDDirectionsRequest ()

/** Dictionary containing all parameter key-value pairs of the request */
@property (nonatomic, strong, setter = mtd_setParameters:) NSMutableDictionary *mtd_parameters;
/** Appends all parameters to httpAddress */
@property (nonatomic, readonly) NSString *mtd_fullAddress;
/** The class of the parser used for parsing the data */
@property (nonatomic, readonly) Class mtd_parserClass;

// Private API from MTDDirectionsRequest+MTDDirectionsPrivateAPI.h
@property (nonatomic, strong, setter = mtd_setHTTPRequest:) MTDHTTPRequest *mtd_HTTPRequest;
@property (nonatomic, readonly) NSString *mtd_HTTPAddress;
@property (nonatomic, readonly) NSUInteger mtd_options;

@end


@implementation MTDDirectionsRequest

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

+ (id)requestDirectionsAPI:(MTDDirectionsAPI)API
                      from:(MTDWaypoint *)from
                        to:(MTDWaypoint *)to
         intermediateGoals:(NSArray *)intermediateGoals
                 routeType:(MTDDirectionsRouteType)routeType
                   options:(NSUInteger)options
                completion:(mtd_parser_block)completion {
    return [[MTDDirectionsRequestClassForAPI(API) alloc] initWithFrom:from
                                                                   to:to
                                                    intermediateGoals:intermediateGoals
                                                            routeType:routeType
                                                              options:options
                                                           completion:completion];
}

- (id)initWithFrom:(MTDWaypoint *)from
                to:(MTDWaypoint *)to
 intermediateGoals:(NSArray *)intermediateGoals
         routeType:(MTDDirectionsRouteType)routeType
           options:(NSUInteger)options
        completion:(mtd_parser_block)completion {
    if ((self = [super init])) {
        BOOL optimizeRoute = (options & MTDDirectionsRequestOptionOptimize) == MTDDirectionsRequestOptionOptimize;
        BOOL alternativeRoutes = (options & MTDDirectionsRequestOptionAlternativeRoutes) == MTDDirectionsRequestOptionAlternativeRoutes;

        MTDAssert(!(optimizeRoute && alternativeRoutes), @"Option optimize and alternative routes can't be specified at the same time.");

        _from = from;
        _to = to;
        _intermediateGoals = [intermediateGoals copy];
        _routeType = routeType;
        _mtd_options = options;
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

    self.mtd_HTTPRequest = [[MTDHTTPRequest alloc] initWithAddress:address
                                                    callbackTarget:self
                                                            action:@selector(requestFinished:)];

    [self.mtd_HTTPRequest start];
}

- (void)cancel {
    [self.mtd_HTTPRequest cancel];
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
        self.mtd_parameters[parameter] = value;
    }
}

- (void)setArrayValue:(NSArray *)array forParameter:(NSString *)parameter {
    MTDAssert(array.count > 0 && parameter != nil, @"Array and Parameter must be different from nil");

    if (array.count > 0 && parameter != nil) {
        self.mtd_parameters[parameter] = array;
    }
}

- (void)setValueForParameterWithIntermediateGoals:(NSArray *) __unused intermediateGoals {
    MTDLogError(@"setValueForParameterWithIntermediateGoals was called on a request that doesn't override it (Class: %@)",
                NSStringFromClass([self class]));

    [self doesNotRecognizeSelector:_cmd];
}

- (void)removeValueForParameter:(NSString *)parameter {
    MTDAssert(parameter != nil, @"Parameter must be different from nil");

    if (parameter != nil) {
        [self.mtd_parameters removeObjectForKey:parameter];
    }
}

- (NSString *)mtd_HTTPAddress {
    MTDLogError(@"mtd_HTTPAddress was called on a request that doesn't override it (Class: %@)",
                NSStringFromClass([self class]));

    [self doesNotRecognizeSelector:_cmd];

    return nil;
}

- (MTDDirectionsAPI)API {
    MTDLogError(@"API was called on a request that doesn't override it (Class: %@)",
                NSStringFromClass([self class]));

    [self doesNotRecognizeSelector:_cmd];

    return MTDDirectionsAPICount;
}

- (Class)mtd_parserClass {
    return MTDDirectionsParserClassForAPI(self.API);
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

- (NSString *)mtd_fullAddress {
    MTDAssert(self.mtd_HTTPAddress.length > 0, @"HTTP Address must be set.");

    NSMutableString *address = [NSMutableString stringWithString:self.mtd_HTTPAddress];

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
