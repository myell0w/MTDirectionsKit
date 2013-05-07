#import "MTDWaypoint.h"
#import "MTDAddress.h"
#import "MTDFunctions.h"


@interface MTDWaypoint ()

@property (nonatomic, assign, readwrite) CLLocationCoordinate2D coordinate; // re-defined as read/write

@end


@implementation MTDWaypoint

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

+ (instancetype)waypointWithCoordinate:(CLLocationCoordinate2D)coordinate {
    return [[[self class] alloc] initWithCoordinate:coordinate];
}

+ (instancetype)waypointWithAddress:(MTDAddress *)address {
    return [[[self class] alloc] initWithAddress:address];
}

+ (instancetype)waypointWithAddressString:(NSString *)addressString {
    return [[self class] waypointWithAddress:[MTDAddress addressWithAddressString:addressString]];
}

+ (instancetype)waypointForCurrentLocation {
    __strong static MTDWaypoint *waypointForCurrentLocation = nil;

    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        waypointForCurrentLocation = [MTDWaypoint waypointWithCoordinate:kCLLocationCoordinate2DInvalid];
    });

    return waypointForCurrentLocation;
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
    if ((self = [super init])) {
        _coordinate = coordinate;
    }

    return self;
}

- (id)initWithAddress:(MTDAddress *)address {
    if ((self = [super init])) {
        _address = address;
        _coordinate = kCLLocationCoordinate2DInvalid;
    }

    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - NSCopying
////////////////////////////////////////////////////////////////////////

- (id)copyWithZone:(__unused NSZone *)zone {
    MTDWaypoint *copy = [[[self class] allocWithZone:zone] initWithAddress:self.address];

    copy->_coordinate = self.coordinate;

    return copy;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDWaypoint
////////////////////////////////////////////////////////////////////////

- (BOOL)hasValidCoordinate {
    return CLLocationCoordinate2DIsValid(self.coordinate);
}

- (BOOL)hasValidAddress {
    return self.address.description.length > 0;
}

- (BOOL)isValid {
    return self.hasValidCoordinate || self.hasValidAddress || [self isWaypointForCurrentLocation];
}

- (BOOL)isWaypointForCurrentLocation {
    return self == [MTDWaypoint waypointForCurrentLocation];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject
////////////////////////////////////////////////////////////////////////

- (NSString *)description {
    if ([self isWaypointForCurrentLocation]) {
        return @"<MTDWaypoint currentLocation>";
    }

    NSString *addressDescription = self.address != nil ? [self.address description] : @"Unknown";

    if (CLLocationCoordinate2DIsValid(self.coordinate)) {
        return [NSString stringWithFormat:@"<MTDWaypoint: %@ (Address: %@)>",
                MTDStringFromCLLocationCoordinate2D(self.coordinate),
                addressDescription];
    } else {
        return [NSString stringWithFormat:@"<MTDWaypoint: (Address: %@)>",
                addressDescription];
    }
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[MTDWaypoint class]]) {
        return NO;
    }

    if (object == self) {
        return YES;
    }

    MTDWaypoint *otherWaypoint = (MTDWaypoint *)object;

    if (CLLocationCoordinate2DIsValid(self.coordinate)) {
        double epsilon = 0.0000001;

        return (fabs(self.coordinate.latitude - otherWaypoint.coordinate.latitude) < epsilon &&
                fabs(self.coordinate.longitude - otherWaypoint.coordinate.longitude) < epsilon);
    } else {
        return self.address == otherWaypoint.address || [self.address isEqual:otherWaypoint.address];
    }
}

- (NSUInteger)hash {
    if (CLLocationCoordinate2DIsValid(self.coordinate) || self == [MTDWaypoint waypointForCurrentLocation]) {
        NSNumber *latitudeNumber = @(self.coordinate.latitude);
        NSNumber *longitudeNumber = @(self.coordinate.longitude);

        return latitudeNumber.hash >> 13 ^ longitudeNumber.hash;
    } else {
        return self.address.hash;
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

+ (void)mtd_updateCurrentLocationCoordinate:(CLLocationCoordinate2D)coordinate {
    [MTDWaypoint waypointForCurrentLocation].coordinate = coordinate;
}

@end
