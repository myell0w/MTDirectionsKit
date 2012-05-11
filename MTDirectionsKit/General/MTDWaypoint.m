#import "MTDWaypoint.h"

@implementation MTDWaypoint

@synthesize coordinate = _coordinate;

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

+ (MTDWaypoint *)waypointWithCoordinate:(CLLocationCoordinate2D)coordinate {
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
    return [NSString stringWithFormat:@"<MTDWaypoint: (Lat: %f, Lng: %f)>",
            self.coordinate.latitude,
            self.coordinate.longitude];
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[MTDWaypoint class]]) {
        return NO;
    }
    
    MTDWaypoint *otherWaypoint = (MTDWaypoint *)object;
    double epsilon = 0.0000001;
    
    return (fabs(self.coordinate.latitude - otherWaypoint.coordinate.latitude) < epsilon &&
            fabs(self.coordinate.longitude - otherWaypoint.coordinate.longitude) < epsilon);
}

- (NSUInteger)hash {
    NSNumber *latitudeNumber = [NSNumber numberWithDouble:self.coordinate.latitude];
    NSNumber *longitudeNumber = [NSNumber numberWithDouble:self.coordinate.longitude];
    
    return latitudeNumber.hash >> 13 ^ longitudeNumber.hash;
}

@end
