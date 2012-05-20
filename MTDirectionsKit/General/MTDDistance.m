#import "MTDDistance.h"
#import "MTDMeasurementSystem.h"


#define kMTDKilometerPerMile        1.609344


@interface MTDDistance ()

/** internally the distance is stored in metric measurement system (in km) */
@property (nonatomic, assign) double metricDistance;

@end


@implementation MTDDistance

@synthesize metricDistance = _metricDistance;

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

+ (MTDDistance *)distanceWithValue:(double)value measurementSystem:(MTDMeasurementSystem)measurementSystem {
    return [[MTDDistance alloc] initWithDistanceValue:value measurementSystem:measurementSystem];
}

- (id)initWithDistanceValue:(double)value measurementSystem:(MTDMeasurementSystem)measurementSystem {
    if ((self = [super init])) {
        switch (measurementSystem) {
            case MTDMeasurementSystemUS: {
                _metricDistance = value * kMTDKilometerPerMile;
                break;
            }
                
            case MTDMeasurementSystemMetric: {
            default:
                _metricDistance = value;
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
    return MTDFormattedDistanceInMeasurementSystem(self.distanceInMeter, MTDDirectionsGetMeasurementSystem());
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDDistance
////////////////////////////////////////////////////////////////////////

- (void)addDistance:(MTDDistance *)distance {
    self.metricDistance += distance.metricDistance;
}

- (void)addDistanceWithValue:(double)value measurementSystem:(MTDMeasurementSystem)measurementSystem {
    [self addDistance:[MTDDistance distanceWithValue:value measurementSystem:measurementSystem]];
}

- (void)addDistanceWithMeters:(double)meters {
    [self addDistanceWithValue:meters/1000. measurementSystem:MTDMeasurementSystemMetric];
}

- (double)distanceInMeasurementSystem:(MTDMeasurementSystem)measurementSystem {
    switch (measurementSystem) {
        case MTDMeasurementSystemUS:
            return self.metricDistance / kMTDKilometerPerMile;
            
        case MTDMeasurementSystemMetric:
        default:
            return self.metricDistance;
    }
}

- (double)distanceInCurrentMeasurementSystem {
    return [self distanceInMeasurementSystem:MTDDirectionsGetMeasurementSystem()];
}

- (CLLocationDistance)distanceInMeter {
    return self.metricDistance * 1000.;
}

@end
