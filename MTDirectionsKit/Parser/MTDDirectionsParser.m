#import "MTDDirectionsParser.h"
#import "MTDWaypoint.h"


@interface MTDDirectionsParser ()

// overwrite as read-write
@property (nonatomic, strong, readwrite) id data;
@property (nonatomic, strong, readwrite) MTDWaypoint *from;
@property (nonatomic, strong, readwrite) MTDWaypoint *to;

@end


@implementation MTDDirectionsParser

@synthesize intermediateGoals = _intermediateGoals;
@synthesize routeType = _routeType;

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithFrom:(MTDWaypoint *)from
                to:(MTDWaypoint *)to
 intermediateGoals:(NSArray *)intermediateGoals
         routeType:(MTDDirectionsRouteType)routeType
              data:(id)data {
    if ((self = [super init])) {
        _from = from;
        _to = to;
        _intermediateGoals = [intermediateGoals copy];
        _data = data;
        _routeType = routeType;
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDirectionsParser
////////////////////////////////////////////////////////////////////////

- (void)parseWithCompletion:(mtd_parser_block) __unused completion {
    MTDLogError(@"parseWithCompletion was called on a parser that doesn't override it (Class: %@)", 
                NSStringFromClass([self class]));
    
    [self doesNotRecognizeSelector:_cmd];
}

@end
