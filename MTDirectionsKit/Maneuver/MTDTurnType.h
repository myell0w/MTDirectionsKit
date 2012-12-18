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
    MTDTurnTypeTakePublicTransport,         // use transit
    MTDTurnTypeTurnRightToStay,             // turn to stay right
    MTDTurnTypeTurnLeftToStay,              // turn to stay left
    MTDTurnTypeRoundabout,                  // enter and exit roundabout
};


/**
 This function return an image representing the given turnType. It can be used
 to display a list of all maneuvers to the user
 
 @param turnType the turn type to represent
 @return an image representing the given turn type
 */
NS_INLINE UIImage* MTDGetImageForTurnType(MTDTurnType turnType) {
    NSString *path = @"MTDirectionsKit.bundle/turnTypes/";
    NSString *imageName = nil;

    switch (turnType) {
        case MTDTurnTypeStraight: {
            imageName = [path stringByAppendingPathComponent:@"straight"];
            break;
        }
            
        case MTDTurnTypeTurn:
        case MTDTurnTypeUTurn: {
            imageName = [path stringByAppendingPathComponent:@"uturn"];
            break;
        }
            
        case MTDTurnTypeBearRight:
        case MTDTurnTypeLeaveRampRight: {
            imageName = [path stringByAppendingPathComponent:@"bear-right"];
            break;
        }
            
        case MTDTurnTypeRight: {
            imageName = [path stringByAppendingPathComponent:@"right"];
            break;
        }
            
        case MTDTurnTypeSharpRight: {
            imageName = [path stringByAppendingPathComponent:@"sharp-right"];
            break;
        }
            
        case MTDTurnTypeBearLeft:
        case MTDTurnTypeLeaveRampLeft: {
            imageName = [path stringByAppendingPathComponent:@"bear-left"];
            break;
        }
            
        case MTDTurnTypeLeft: {
            imageName = [path stringByAppendingPathComponent:@"left"];
            break;
        }
            
        case MTDTurnTypeSharpLeft: {
            imageName = [path stringByAppendingPathComponent:@"sharp-left"];
            break;
        }
            
        case MTDTurnTypeMerge:
        case MTDTurnTypeMergeRight:
        case MTDTurnTypeTurnRightToStay: {
            imageName = [path stringByAppendingPathComponent:@"merge-right"];
            break;
        }
            
        case MTDTurnTypeMergeLeft:
        case MTDTurnTypeTurnLeftToStay: {
            imageName = [path stringByAppendingPathComponent:@"merge-left"];
            break;
        }
            
        case MTDTurnTypeTakeRampLeft: {
            imageName = [path stringByAppendingPathComponent:@"ramp-left"];
            break;
        }

        case MTDTurnTypeTakeRampRight: {
            imageName = [path stringByAppendingPathComponent:@"ramp-right"];
            break;
        }
            
        case MTDTurnTypeDepart: {
            imageName = [path stringByAppendingPathComponent:@"depart"];
            break;
        }

        case MTDTurnTypeArrive: {
            imageName = [path stringByAppendingPathComponent:@"arrive"];
            break;
        }

        case MTDTurnTypeWalk: {
            imageName = [path stringByAppendingPathComponent:@"walk"];
            break;
        }

        case MTDTurnTypeTakePublicTransport: {
            imageName = [path stringByAppendingPathComponent:@"public-transport"];
            break;
        }
            
        case MTDTurnTypeRoundabout: {
            imageName = [path stringByAppendingPathComponent:@"roundabout-righthand"];
            break;
        }

        case MTDTurnTypeUnknown:
        default: {
            // do nothing
            break;
        }
    }

    return [UIImage imageNamed:imageName];
}
