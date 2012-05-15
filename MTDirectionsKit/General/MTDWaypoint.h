//
//  MTDWaypoint.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


#import <CoreLocation/CoreLocation.h>


/**
 An instance of MTDWaypoint is a lightweight immutable object wrapper for a CLLocationCoordinate2D coordinate.
 It is used in MTDDirectionsKit to store coordinates in collections like NSArray.
 */
@interface MTDWaypoint : NSObject

/******************************************
 @name Location
 ******************************************/

/** the coordinate wrapped */
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

/******************************************
 @name Lifecycle
 ******************************************/

/**
 This method is used to create an instance of MTDWaypoint with a given coordinate.
 
 @param coordinate the coordinate to save
 @return the wrapper object created to store the coordinate
 
 @see initWithCoordinate:
 */
+ (MTDWaypoint *)waypointWithCoordinate:(CLLocationCoordinate2D)coordinate;

/**
 The designated initializer of MTDWaypoint, used to create an instance of MTDWaypoint that wraps
 a given coordinate.
 
 @param coordinate the coordinate to save
 @return the wrapper object created to store the coordinate
 */
- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end
