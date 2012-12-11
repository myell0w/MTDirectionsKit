//
//  MTDWaypoint.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


#import <CoreLocation/CoreLocation.h>
#import "MTDDirectionsAPI.h"


@class MTDAddress;


/**
 An instance of MTDWaypoint is a lightweight object wrapper for either a CLLocationCoordinate2D 
 coordinate or an address string representing a location (or both).
 
 It is used in MTDDirectionsKit to store coordinates in collections like NSArray.
 */
@interface MTDWaypoint : NSObject <NSCopying>

/******************************************
 @name Location
 ******************************************/

/** the coordinate wrapped, may be invalid */
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
/** the address wrapped, may be nil */
@property (nonatomic, retain) MTDAddress *address;

/** has this waypoint a valid coordinate */
@property (nonatomic, readonly) BOOL hasValidCoordinate;
/** has this waypoint a valid address */
@property (nonatomic, readonly) BOOL hasValidAddress;
/** is this waypoint valid (valid coordinate or set address) */
@property (nonatomic, readonly, getter = isValid) BOOL valid;

/******************************************
 @name Lifecycle
 ******************************************/

/**
 This method is used to create an instance of MTDWaypoint with a given coordinate.
 
 @param coordinate the coordinate to save
 @return the wrapper object created to store the coordinate
 
 @see initWithCoordinate:
 */
+ (instancetype)waypointWithCoordinate:(CLLocationCoordinate2D)coordinate;

/**
 This method is used to create an instance of MTDWaypoint with a given address object.
 
 @param address the address of the waypoint
 @return the wrapper object created to store the address
 
 @see initWithAddress:
 @see waypointWithAddressString:
 */
+ (instancetype)waypointWithAddress:(MTDAddress *)address;

/**
 This method is used to create an instance of MTDWaypoint with a given address string.

 @param addressString the string-representation of the address of the waypoint
 @return the wrapper object created to store the address

 @see initWithAddress:
 @see waypointWithAddress:
 */
+ (instancetype)waypointWithAddressString:(NSString *)addressString;

/**
 Creates and returns a singleton waypoint object representing the device’s current location.
 
 @return An MTDWaypoint object representing the current location.
 */
+ (instancetype)waypointForCurrentLocation;

/**
 The initializer used to create an instance of MTDWaypoint that wraps a given coordinate.
 
 @param coordinate the coordinate to save
 @return the wrapper object created to store the coordinate
 */
- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

/**
 The initializer used to create an instance of MTDWaypoint that wraps a given address.
 
 @param address the address to save
 @return the wrapper object created to store the address
 */
- (id)initWithAddress:(MTDAddress *)address;


/******************************************
 @name API
 ******************************************/

/**
 Returns a string representation of this waypoint used for the call to the given API.
 
 @param api the API we use to retreive the directions
 @return string representation that can be used as part of the URL to call the API
 */
- (NSString *)descriptionForAPI:(MTDDirectionsAPI)api;

@end
