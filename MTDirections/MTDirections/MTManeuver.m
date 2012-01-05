#import "MTManeuver.h"
#import "MTWaypoint.h"

@implementation MTManeuver

@synthesize waypoint = waypoint_;
@synthesize distance = distance_;
@synthesize time = time_;

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

+ (MTManeuver *)maneuverWithWaypoint:(MTWaypoint *)waypoint
                            distance:(CLLocationDistance)distance
                                time:(NSTimeInterval)time {
    return [[MTManeuver alloc] initWithWaypoint:waypoint distance:distance time:time];
}

- (id)init {
    return [self initWithWaypoint:nil distance:0. time:0.];
}

- (id)initWithWaypoint:(MTWaypoint *)waypoint
              distance:(CLLocationDistance)distance
                  time:(NSTimeInterval)time {
    if ((self = [super init])) {
        waypoint_ = waypoint;
        distance_ = distance;
        time_ = time;
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject
////////////////////////////////////////////////////////////////////////

- (NSString *)description {
    return [NSString stringWithFormat:@"<MTManeuver: (Lat: %f, Lng: %f, Distance: %f, Time: %f)>", 
            self.waypoint.coordinate.latitude,
            self.waypoint.coordinate.longitude,
            self.distance,
            self.time];
}

@end
