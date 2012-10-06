#import "MTDManeuver.h"
#import "MTDWaypoint.h"


@implementation MTDManeuver

@synthesize waypoint = _waypoint;
@synthesize distance = _distance;
@synthesize time = _time;

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

+ (MTDManeuver *)maneuverWithWaypoint:(MTDWaypoint *)waypoint
                            distance:(CLLocationDistance)distance
                                time:(NSTimeInterval)time
                         instructions:(NSString *)instructions {
    return [[MTDManeuver alloc] initWithWaypoint:waypoint
                                        distance:distance
                                            time:time
                                    instructions:instructions];
}

- (id)initWithWaypoint:(MTDWaypoint *)waypoint
              distance:(CLLocationDistance)distance
                  time:(NSTimeInterval)time
          instructions:(NSString *)instructions {
    if ((self = [super init])) {
        _waypoint = waypoint;
        _distance = distance;
        _time = time;
        _instructions = [instructions copy];
        _cardinalDirection = MTDCardinalDirectionUnknown;
        _turnType = MTDTurnTypeUnknown;
    }
    
    return self;
}

- (id)init {
    return [self initWithWaypoint:nil distance:0. time:0. instructions:nil];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDManeuver
////////////////////////////////////////////////////////////////////////

- (CLLocationCoordinate2D)coordinate {
    return self.waypoint.coordinate;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject
////////////////////////////////////////////////////////////////////////

- (NSString *)description {
    return [NSString stringWithFormat:@"<MTDManeuver (Lat: %f, Lng: %f, Distance: %f, Time: %f, Direction: %d): %@>",
            self.coordinate.latitude,
            self.coordinate.longitude,
            self.distance,
            self.time,
            self.cardinalDirection,
            self.instructions];
}

@end
