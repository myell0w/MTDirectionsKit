#import "MTDManeuver.h"
#import "MTDWaypoint.h"
#import "MTDDistance.h"
#import "MTDFunctions.h"


@implementation MTDManeuver

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithWaypoint:(MTDWaypoint *)waypoint
              distance:(MTDDistance *)distance
         timeInSeconds:(NSTimeInterval)timeInSeconds
          instructions:(NSString *)instructions {
    if ((self = [super init])) {
        _waypoint = waypoint;
        _distance = distance;
        _timeInSeconds = timeInSeconds;
        _instructions = [instructions copy];
        _cardinalDirection = MTDCardinalDirectionUnknown;
        _turnType = MTDTurnTypeUnknown;
    }

    return self;
}

- (id)init {
    return [self initWithWaypoint:nil distance:nil timeInSeconds:0. instructions:nil];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDManeuver
////////////////////////////////////////////////////////////////////////

- (CLLocationCoordinate2D)coordinate {
    return self.waypoint.coordinate;
}

- (NSString *)formattedTime {
    return [self formattedTimeWithFormat:nil];
}

- (NSString *)formattedTimeWithFormat:(NSString *)format {
    if (format != nil) {
        return MTDGetFormattedTimeWithFormat(self.timeInSeconds, format);
    } else {
        return MTDGetFormattedTime(self.timeInSeconds);
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject
////////////////////////////////////////////////////////////////////////

- (NSString *)description {
    return [NSString stringWithFormat:@"<MTDManeuver (Lat: %f, Lng: %f, Distance: %@, Time: %f, Direction: %d): %@>",
            self.coordinate.latitude,
            self.coordinate.longitude,
            self.distance,
            self.timeInSeconds,
            self.cardinalDirection,
            self.instructions];
}

- (BOOL)isEqual:(id)object {
	if (![object isMemberOfClass:[MTDManeuver class]]) {
		return NO;
	}

    MTDManeuver *maneuver = (MTDManeuver *)object;

	return ((self.waypoint == maneuver.waypoint || [self.waypoint isEqual:maneuver.waypoint]) &&
            self.distance.distanceInMeter == maneuver.distance.distanceInMeter &&
            self.timeInSeconds == maneuver.timeInSeconds &&
            [self.instructions isEqualToString:maneuver.instructions] &&
            self.cardinalDirection == maneuver.cardinalDirection &&
            self.turnType == maneuver.turnType &&
            (self.name == maneuver.name || [self.name isEqualToString:maneuver.name]));
}
@end
