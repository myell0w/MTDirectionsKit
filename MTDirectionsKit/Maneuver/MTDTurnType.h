//
//  MTDTurnType.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//

/**
 This enum represents a possible turn type of an instance of MTDManeuver.
 It is an indication whether the user has to turn left, right etc. and 
 can be used to display information about the turn type. Not all turnType
 values are supported by all APIs.
 */
typedef NS_ENUM(NSInteger, MTDTurnType) {
    MTDTurnTypeUnknown = -1,                // no information
    MTDTurnTypeStraight,                    // continue straight
    MTDTurnTypeTurn,                        // turn into the opposite direction
    MTDTurnTypeBearRight,                   // keep right
    MTDTurnTypeRight,                       // turn right
    MTDTurnTypeSharpRight,                  // turn sharp right
    MTDTurnTypeBearLeft,                    // keep left
    MTDTurnTypeLeft,                        // turn left
    MTDTurnTypeSharpLeft,                   // turn sharp left
    MTDTurnTypeUTurn,                       // make a U-Turn
    MTDTurnTypeMerge,                       // merge, direction unknown
    MTDTurnTypeMergeRight,                  // merge to the right
    MTDTurnTypeMergeLeft,                   // merge to the left
    MTDTurnTypeTakeRampLeft,                // take ramp left
    MTDTurnTypeTakeRampRight,               // take ramp right
    MTDTurnTypeLeaveRampLeft,               // leave ramp left
    MTDTurnTypeLeaveRampRight,              // leave ramp right
    MTDTurnTypeDepart,                      // depart your journey/from an intermediate goal
    MTDTurnTypeArrive,                      // arrive at the destination
    MTDTurnTypeWalk,                        // walk
    MTDTurnTypeTakePublicTransport          // use transit
};


/**
 This function return an image representing the given turnType. It can be used
 to display a list of all maneuvers to the user
 
 @param turnType the turn type to represent
 @return an image representing the given turn type
 */
NS_INLINE UIImage* MTDGetImageForTurnType(MTDTurnType turnType) {
    NSString *imageName = [NSString stringWithFormat:@"MTDirectionsKit.bundle/turnType_%d", turnType];

    return [UIImage imageNamed:imageName];
}
