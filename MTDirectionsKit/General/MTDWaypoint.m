#import "MTDWaypoint.h"
#import "MTDFunctions.h"
#import "MTDDirectionsDefines.h"


@implementation MTDWaypoint

@synthesize coordinate = _coordinate;
@synthesize address = _address;

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

+ (MTDWaypoint *)waypointWithCoordinate:(CLLocationCoordinate2D)coordinate {
    return [[[self class] alloc] initWithCoordinate:coordinate];
}

+ (MTDWaypoint *)waypointWithAddress:(NSString *)address {
    return [[[self class] alloc] initWithAddress:address];
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
    if ((self = [super init])) {
        _coordinate = coordinate;
    }
    
    return self;
}

- (id)initWithAddress:(NSString *)address {
    if ((self = [super init])) {
        _address = [address stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        _coordinate = MTDInvalidCLLocationCoordinate2D;
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDWaypoint
////////////////////////////////////////////////////////////////////////

- (BOOL)hasValidCoordinate {
    return CLLocationCoordinate2DIsValid(self.coordinate);
}

- (BOOL)hasValidAddress {
    return self.address.length > 0;
}

- (BOOL)isValid {
    return self.hasValidCoordinate || self.hasValidAddress;
}

// Would love to put this in a category, but then we need to specify -ObjC
// for "Other Linker Flags" which complicates setup, that's why it's here
- (NSString *)descriptionForAPI:(MTDDirectionsAPI)api {
    switch (api) {
            // Currently there's no difference between MapQuest and Google APIs here
        case MTDDirectionsAPIMapQuest:
        case MTDDirectionsAPIGoogle: {
            if (CLLocationCoordinate2DIsValid(self.coordinate)) {
                return [NSString stringWithFormat:@"%f,%f",self.coordinate.latitude, self.coordinate.longitude];
            } else {
                return self.address;
            }
        }
            
        default: {
            return @"";
        }
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject
////////////////////////////////////////////////////////////////////////

- (NSString *)description {
    if (CLLocationCoordinate2DIsValid(self.coordinate)) {
        return [NSString stringWithFormat:@"<MTDWaypoint: %@>",
                MTDStringFromCLLocationCoordinate2D(self.coordinate)];
    } else {
        return [NSString stringWithFormat:@"<MTDWaypoint: (Address: %@)>",
                self.address != nil ? self.address : @"Unknown"];
    }
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[MTDWaypoint class]]) {
        return NO;
    }
    
    MTDWaypoint *otherWaypoint = (MTDWaypoint *)object;
    
    if (CLLocationCoordinate2DIsValid(self.coordinate)) {
        double epsilon = 0.0000001;
        
        return (fabs(self.coordinate.latitude - otherWaypoint.coordinate.latitude) < epsilon &&
                fabs(self.coordinate.longitude - otherWaypoint.coordinate.longitude) < epsilon);
    } else {
        return [self.address isEqualToString:otherWaypoint.address];
    }
}

- (NSUInteger)hash {
    if (CLLocationCoordinate2DIsValid(self.coordinate)) {
        NSNumber *latitudeNumber = [NSNumber numberWithDouble:self.coordinate.latitude];
        NSNumber *longitudeNumber = [NSNumber numberWithDouble:self.coordinate.longitude];
        
        return latitudeNumber.hash >> 13 ^ longitudeNumber.hash;
    } else {
        return self.address.hash;
    }
}

@end
