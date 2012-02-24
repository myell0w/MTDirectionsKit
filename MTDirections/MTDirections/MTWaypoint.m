#import "MTWaypoint.h"

@implementation MTWaypoint

@synthesize coordinate = _coordinate;

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

+ (MTWaypoint *)waypointWithCoordinate:(CLLocationCoordinate2D)coordinate {
    return [[[self class] alloc] initWithCoordinate:coordinate];
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
    if ((self = [super init])) {
        _coordinate = coordinate;
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject
////////////////////////////////////////////////////////////////////////

- (NSString *)description {
    return [NSString stringWithFormat:@"<MTWaypoint: (Lat: %f, Lng: %f)>",
            self.coordinate.latitude,
            self.coordinate.longitude];
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[MTWaypoint class]]) {
        return NO;
    }
    
    MTWaypoint *otherWaypoint = (MTWaypoint *)object;
    
    return (self.coordinate.latitude == otherWaypoint.coordinate.latitude &&
            self.coordinate.longitude == otherWaypoint.coordinate.longitude);
}

@end
