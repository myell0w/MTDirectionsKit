#import "MTDDirectionsParser.h"
#import "MTDLogging.h"


@interface MTDDirectionsParser ()

@property (nonatomic, strong, readwrite) id data;
@property (nonatomic, assign, readwrite) CLLocationCoordinate2D fromCoordinate;
@property (nonatomic, assign, readwrite) CLLocationCoordinate2D toCoordinate;

@end


@implementation MTDDirectionsParser

@synthesize data = _data;
@synthesize fromCoordinate = _fromCoordinate;
@synthesize toCoordinate = _toCoordinate;
@synthesize fromAddress = _fromAddress;
@synthesize toAddress = _toAddress;
@synthesize routeType = _routeType;

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithFromCoordinate:(CLLocationCoordinate2D)fromCoordinate
                toCoordinate:(CLLocationCoordinate2D)toCoordinate
                   routeType:(MTDDirectionsRouteType)routeType
                        data:(id)data {
    if ((self = [super init])) {
        _fromCoordinate = fromCoordinate;
        _toCoordinate = toCoordinate;
        _data = data;
        _routeType = routeType;
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDirectionsParser
////////////////////////////////////////////////////////////////////////

- (void)parseWithCompletion:(mtd_parser_block)completion {
    MTDLogError(@"ParseWithCompletion was called on a parser that doesn't override it (Class: %@)", 
                NSStringFromClass([self class]));
    
    [self doesNotRecognizeSelector:_cmd];
}

@end
