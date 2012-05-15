//
//  MTDDistance.h
//  MTDirectionsKit
//
//  Created by Tretter Matthias
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


#import "MTDMeasurementSystem.h"


/**
 MTDDistance is a wrapper around a distance value with a specified measurement system (Metric or U.S.).
 The specified value is either in km, or miles, therefore 0.5 means either 500 m (0.5 km), or 0.5 miles.
 */
@interface MTDDistance : NSObject

+ (MTDDistance *)distanceWithValue:(double)value measurementSystem:(MTDMeasurementSystem)measurementSystem;

- (id)initWithDistanceValue:(double)value measurementSystem:(MTDMeasurementSystem)measurementSystem;

- (void)addDistance:(MTDDistance *)distance;
- (void)addDistanceWithValue:(double)value measurementSystem:(MTDMeasurementSystem)measurementSystem;

- (double)distanceInMeasurementSystem:(MTDMeasurementSystem)measurementSystem;
- (double)distanceInCurrentMeasurementSystem;

@end
