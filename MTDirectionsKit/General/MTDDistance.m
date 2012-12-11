#import "MTDDistance.h"
#import "MTDMeasurementSystem.h"


#define kMTDKilometerPerMile        1.609344


@interface MTDDistance ()

/** internally the distance is stored in metric measurement system (in km) */
@property (nonatomic, assign, setter = mtd_setMetricDistance:) double mtd_metricDistance;

@end


@implementation MTDDistance

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

+ (instancetype)distanceWithValue:(double)value measurementSystem:(MTDMeasurementSystem)measurementSystem {
    return [[MTDDistance alloc] initWithDistanceValue:value measurementSystem:measurementSystem];
}

+ (instancetype)distanceWithMeters:(CLLocationDistance)meters {
    return [[MTDDistance alloc] initWithDistanceValue:meters/1000. measurementSystem:MTDMeasurementSystemMetric];
}

- (id)initWithDistanceValue:(double)value measurementSystem:(MTDMeasurementSystem)measurementSystem {
    if ((self = [super init])) {
        switch (measurementSystem) {
            case MTDMeasurementSystemUS: {
                _mtd_metricDistance = value * kMTDKilometerPerMile;
                break;
            }
                
            case MTDMeasurementSystemMetric: {
            default:
                _mtd_metricDistance = value;
                break;
            }
        }
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject
////////////////////////////////////////////////////////////////////////

- (NSString *)description {
    return MTDGetFormattedDistanceInMeasurementSystem(self.distanceInMeter, MTDDirectionsGetMeasurementSystem());
}

////////////////////////////////////////////////////////////////////////
#pragma mark - NSCopying
////////////////////////////////////////////////////////////////////////

- (id)copyWithZone:(__unused NSZone *)zone {
    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDDistance
////////////////////////////////////////////////////////////////////////

- (void)addDistance:(MTDDistance *)distance {
    self.mtd_metricDistance += distance.mtd_metricDistance;
}

- (void)addDistanceWithValue:(double)value measurementSystem:(MTDMeasurementSystem)measurementSystem {
    [self addDistance:[MTDDistance distanceWithValue:value measurementSystem:measurementSystem]];
}

- (void)addDistanceWithMeters:(CLLocationDistance)meters {
    [self addDistanceWithValue:meters/1000. measurementSystem:MTDMeasurementSystemMetric];
}

- (double)distanceInMeasurementSystem:(MTDMeasurementSystem)measurementSystem {
    switch (measurementSystem) {
        case MTDMeasurementSystemUS:
            return self.mtd_metricDistance / kMTDKilometerPerMile;
            
        case MTDMeasurementSystemMetric:
        default:
            return self.mtd_metricDistance;
    }
}

- (double)distanceInCurrentMeasurementSystem {
    return [self distanceInMeasurementSystem:MTDDirectionsGetMeasurementSystem()];
}

- (CLLocationDistance)distanceInMeter {
    return self.mtd_metricDistance * 1000.;
}

@end
