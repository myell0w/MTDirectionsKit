#import "MTDDistanceTest.h"


#define kMTDAccuracy    0.001


@implementation MTDDistanceTest

- (void)testMetric {
    MTDDistance *distance = [MTDDistance distanceWithValue:3.4 measurementSystem:MTDMeasurementSystemMetric];
    
    STAssertTrue(distance.distanceInMeter == 3400, @"3.4 km should be 3400 m");
}

- (void)testUS {
    MTDDistance *distance = [MTDDistance distanceWithValue:3.4 measurementSystem:MTDMeasurementSystemUS];
    
    STAssertEqualsWithAccuracy(distance.distanceInMeter, 5471.7696, kMTDAccuracy, @"3.4 Miles should be roughly 5471 m");
}

- (void)testAdd {
    MTDDistance *distance = [[MTDDistance alloc] initWithDistanceValue:1 measurementSystem:MTDMeasurementSystemMetric];
    MTDDistance *distance2 = [[MTDDistance alloc] initWithDistanceValue:0.621371192 measurementSystem:MTDMeasurementSystemUS];
    
    [distance addDistanceWithValue:2. measurementSystem:MTDMeasurementSystemMetric];
    [distance addDistance:distance2];
    [distance addDistanceWithMeters:500.];
    
    STAssertEqualsWithAccuracy(distance.distanceInMeter, 4500., kMTDAccuracy, @"Added distances should be roughly 4,5 km");
}

- (void)testMetricGetter {
    MTDDistance *metricDistance = [MTDDistance distanceWithValue:5. measurementSystem:MTDMeasurementSystemMetric];
    
    STAssertEqualsWithAccuracy([metricDistance distanceInMeasurementSystem:MTDMeasurementSystemMetric], 5., kMTDAccuracy, @"5km should be roughly equal to 5km");
    STAssertEqualsWithAccuracy([metricDistance distanceInMeasurementSystem:MTDMeasurementSystemUS], 3.10685596, kMTDAccuracy, @"5km should be roughly equal to 3.10685596 Miles");
}

- (void)testUSGetter {
    MTDDistance *metricDistance = [MTDDistance distanceWithValue:5. measurementSystem:MTDMeasurementSystemUS];
    
    STAssertEqualsWithAccuracy([metricDistance distanceInMeasurementSystem:MTDMeasurementSystemUS], 5., kMTDAccuracy, @"5 Miles should be roughly equal to 5 Miles");
    STAssertEqualsWithAccuracy([metricDistance distanceInMeasurementSystem:MTDMeasurementSystemMetric], 8.04672, kMTDAccuracy, @"5 Miles should be roughly equal to 8.04672 km");
}


@end
