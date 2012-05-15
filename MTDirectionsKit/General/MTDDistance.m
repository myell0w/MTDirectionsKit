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
        _metricDistance = 0.;
        [self addDistanceWithValue:value measurementSystem:measurementSystem];
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject
////////////////////////////////////////////////////////////////////////

- (NSString *)description {
    return MTDFormattedDistanceInMeasurementSystem(self.metricDistance*1000., MTDDirectionsGetMeasurementSystem());
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDDistance
////////////////////////////////////////////////////////////////////////

- (void)addDistance:(MTDDistance *)distance {
    self.metricDistance += distance.metricDistance;
}

- (void)addDistanceWithValue:(double)value measurementSystem:(MTDMeasurementSystem)measurementSystem {
    switch (measurementSystem) {
        case MTDMeasurementSystemUS: {
            self.metricDistance += value * kMTDKilometerPerMile;
            break;
        }
            
        case MTDMeasurementSystemMetric: {
        default:
            self.metricDistance += value;
            break;
        }
    }
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

@end
