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
                                time:(NSTimeInterval)time {
    return [[MTDManeuver alloc] initWithWaypoint:waypoint distance:distance time:time];
}

- (id)initWithWaypoint:(MTDWaypoint *)waypoint
              distance:(CLLocationDistance)distance
                  time:(NSTimeInterval)time {
    if ((self = [super init])) {
        _waypoint = waypoint;
        _distance = distance;
        _time = time;
    }
    
    return self;
}

- (id)init {
    return [self initWithWaypoint:nil distance:0. time:0.];
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
    return [NSString stringWithFormat:@"<MTDManeuver: (Lat: %f, Lng: %f, Distance: %f, Time: %f)>", 
            self.coordinate.latitude,
            self.coordinate.longitude,
            self.distance,
            self.time];
}

@end
