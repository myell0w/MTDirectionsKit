//
//  MTDManeuver.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


#import "MTDCardinalDirection.h"
#import "MTDTurnType.h"


@class MTDWaypoint;
@class MTDDistance;


/**
 MTDManeuver represents a single step along a route. It contains the startPoint of the maneuver,
 the distance and time in seconds as well as textual instructions of the maneuver and information about
 the cardinal direction and the direction of the next turn. 
 
 The language of the instructions is influenced by the locale that was set using MTDDirectionsSetLocale().
 */
@interface MTDManeuver : NSObject

/******************************************
 @name Maneuver
 ******************************************/

/** the startPoint of the maneuver */
@property (nonatomic, strong, readonly) MTDWaypoint *waypoint;
/** the coordinate of the startPoint of the maneuver */
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
/** the distance between the startPoint of this maneuver and the next maneuver */
@property (nonatomic, strong, readonly) MTDDistance *distance;
/** the approximate duration of this maneuver */
@property (nonatomic, assign, readonly) NSTimeInterval timeInSeconds;
/** the estimated time as formatted string */
@property (nonatomic, readonly) NSString *formattedTime;
/** textual instructions for the user, language is influenced by MTDDirectionsSetLocale()  */
@property (nonatomic, copy, readonly) NSString *instructions;

/** the cardinal direction of this maneuver, can be undefined */
@property (nonatomic, assign) MTDCardinalDirection cardinalDirection;
/** the turn type of this maneuver, can be undefined */
@property (nonatomic, assign) MTDTurnType turnType;
/** the name of the maneuver */
@property (nonatomic, copy) NSString *name;

/******************************************
 @name Lifecycle
 ******************************************/

/**
 The designated initializer, creates a maneuver.
 
 @param waypoint the startPoint of the maneuver
 @param distance the distance between the startPoint of this maneuver and the next maneuver
 @param timeInSeconds the approximate duration of this maneuver
 @param instructions textual instructions for the user, language is influenced by MTDDirectionsSetLocale()
 @return an instance of MTDManeuver
 */
- (id)initWithWaypoint:(MTDWaypoint *)waypoint
              distance:(MTDDistance *)distance
         timeInSeconds:(NSTimeInterval)timeInSeconds
          instructions:(NSString *)instructions;


/******************************************
 @name Maneuver
 ******************************************/

/**
 The estimated time as formatted string with a specified time format.

 @param format the format of the time, e.g. H:mm:ss
 @return a string-representation of the estimated time with the given format
 */
- (NSString *)formattedTimeWithFormat:(NSString *)format;

@end
