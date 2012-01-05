#import "MTManeuver.h"


@implementation MTManeuver

@synthesize waypoint = waypoint_;
@synthesize distance = distance_;
@synthesize time = time_;

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

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

@end
