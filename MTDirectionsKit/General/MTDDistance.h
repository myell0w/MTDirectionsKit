//
//  MTDDistance.h
//  MTDirectionsKit
//
//  Created by Tretter Matthias
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


#import "MTDMeasurementSystem.h"


/**
 MTDDistance is a wrapper around a distance value in a specified measurement system (Metric or U.S.).
 The specified value is either in kilometer or miles, therefore 0.5 for example either means 500 m (0.5 km), or 0.5 miles,
 depending on the specified measurementSystem.
 
 The measurementSystem can be:
 
 - MTDMeasurementSystemMetric
 - MTDMeasurementSystemUS
 */
@interface MTDDistance : NSObject <NSCopying>

/******************************************
 @name Distance
 ******************************************/

/** The distance value in the currently set measurementSystem, retreived with MTDDirectionsGetMeasurementSystem() */
@property (nonatomic, readonly) double distanceInCurrentMeasurementSystem;
/** The distance in meter */
@property (nonatomic, readonly) CLLocationDistance distanceInMeter;

/******************************************
 @name Lifecycle
 ******************************************/

/**
 Returns an instance of MTDDistance with the given value and measurementSystem.
 
 @param value the value specified in kilometer (if measurementSystem is MTDMeasurementSystemMetric) or miles
 @param measurementSystem the measurement system of this distance, either Metric or U.S.
 */
+ (instancetype)distanceWithValue:(double)value measurementSystem:(MTDMeasurementSystem)measurementSystem;

/**
 Returns an instance of MTDDistance with the given number of meters.
 
 @param meters the number of meters
 */
+ (instancetype)distanceWithMeters:(CLLocationDistance)meters;

/**
 The designated initializer of MTDDistance is used to create an instance with the given value and measurementSystem.
 
 @param value the value specified in kilometer (if measurementSystem is MTDMeasurementSystemMetric) or miles
 @param measurementSystem the measurement system of this distance, either Metric or U.S.
 */
- (id)initWithDistanceValue:(double)value measurementSystem:(MTDMeasurementSystem)measurementSystem;

/******************************************
 @name Distance
 ******************************************/

/**
 Adds the given distance to self.
 
 @param distance a distance object
 */
- (void)addDistance:(MTDDistance *)distance;

/**
 Adds a distance with the given value and measurementSystem to self.
 
 @param value the value specified in kilometer (if measurementSystem is MTDMeasurementSystemMetric) or miles
 @param measurementSystem the measurement system of this distance, either Metric or U.S.
 */
- (void)addDistanceWithValue:(double)value measurementSystem:(MTDMeasurementSystem)measurementSystem;

/**
 Adds a distance with the given value of meters to self
 
 @param meters the value specified in meters
 */
- (void)addDistanceWithMeters:(CLLocationDistance)meters;

/**
 Returns the distance value in the given measurementSystem.
 
  @param measurementSystem the measurement system we want our distance to convert to, either Metric or U.S.
 */
- (double)distanceInMeasurementSystem:(MTDMeasurementSystem)measurementSystem;

@end
