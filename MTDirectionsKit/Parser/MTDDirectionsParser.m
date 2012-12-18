#import "MTDDirectionsParser.h"
#import "MTDWaypoint.h"
#import "MTDRoute.h"
#import "MTDManeuver.h"
#import "MTDDistance.h"


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
#pragma mark - MTDDirectionsParser Class
////////////////////////////////////////////////////////////////////////

- (void)updateRouteNamesFromLongestDistanceManeuver:(NSArray *)routes forceUpdate:(BOOL)forceUpdate {
    for (MTDRoute *route in routes) {
        if (!forceUpdate && route.name.length > 0) {
            continue;
        }

        NSString *name = nil;
        CLLocationDistance longestDistance = 0.;
        NSMutableArray *otherRoutes = [routes mutableCopy];

        [otherRoutes removeObject:route];

        for (MTDManeuver *maneuver in route.maneuvers) {
            if (!maneuver.name) {
                continue;
            }

            if (maneuver.distance.distanceInMeter > longestDistance) {
                BOOL otherNameFound = NO;

                for (MTDRoute *otherRoute in otherRoutes) {
                    for (MTDManeuver *otherManeuver in otherRoute.maneuvers) {
                        if ([maneuver isEqual:otherManeuver]) {
                            otherNameFound = YES;
                            break;
                        }
                    }

                    if (otherNameFound) {
                        break;
                    }
                }

                if (!otherNameFound) {
                    name = maneuver.name;
                    longestDistance = maneuver.distance.distanceInMeter;
                }
            }
        }

        if (name != nil) {
            route.name = name;
        }
    }
}

- (void)callCompletion:(mtd_parser_block)completion overlay:(MTDDirectionsOverlay *)overlay error:(NSError *)error {
    if (completion != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(overlay, error);
        });
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDirectionsParser Protocol
////////////////////////////////////////////////////////////////////////

- (void)parseWithCompletion:(mtd_parser_block) __unused completion {
    MTDLogError(@"parseWithCompletion was called on a parser that doesn't override it (Class: %@)",
                NSStringFromClass([self class]));

    [self doesNotRecognizeSelector:_cmd];
}

@end
