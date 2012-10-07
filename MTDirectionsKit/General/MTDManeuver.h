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
 the cardinal direction and the direction in which to turn. The language of the instructions is influenced 
 by the locale that was set using MTDDirectionsSetLocale().
 */
@interface MTDManeuver : NSObject

/** the startPoint of the maneuver */
@property (nonatomic, strong, readonly) MTDWaypoint *waypoint;
/** the distance between the startPoint of this maneuver and the next maneuver */
@property (nonatomic, strong, readonly) MTDDistance *distance;
/** the approximate duration of this maneuver */
@property (nonatomic, assign, readonly) NSTimeInterval timeInSeconds;
/** textual instructions for the user, language is influenced by MTDDirectionsSetLocale()  */
@property (nonatomic, copy, readonly) NSString *instructions;

/** the cardinal direction of this maneuver, can be undefined */
@property (nonatomic, assign) MTDCardinalDirection cardinalDirection;
/** the turn type of this maneuver, can be undefined */
@property (nonatomic, assign) MTDTurnType turnType;

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

@end
