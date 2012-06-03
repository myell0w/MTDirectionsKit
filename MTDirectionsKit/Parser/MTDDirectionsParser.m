#import "MTDDirectionsParser.h"
#import "MTDLogging.h"
#import "MTDWaypoint.h"


@interface MTDDirectionsParser ()

@property (nonatomic, strong, readwrite) id data;
@property (nonatomic, strong, readwrite) MTDWaypoint *from;
@property (nonatomic, strong, readwrite) MTDWaypoint *to;

@end


@implementation MTDDirectionsParser

@synthesize data = _data;
@synthesize from = _from;
@synthesize to = _to;
@synthesize routeType = _routeType;

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithFrom:(MTDWaypoint *)from
                to:(MTDWaypoint *)to
         routeType:(MTDDirectionsRouteType)routeType
              data:(id)data {
    if ((self = [super init])) {
        _from = from;
        _to = to;
        _data = data;
        _routeType = routeType;
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDirectionsParser
////////////////////////////////////////////////////////////////////////

- (void)parseWithCompletion:(mtd_parser_block)completion {
    MTDLogError(@"parseWithCompletion was called on a parser that doesn't override it (Class: %@)", 
                NSStringFromClass([self class]));
    
    [self doesNotRecognizeSelector:_cmd];
}

@end
