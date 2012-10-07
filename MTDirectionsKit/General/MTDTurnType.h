//
//  MTDTurnType.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//

typedef enum {
    MTDTurnTypeUnknown = -1,
    MTDTurnTypeStraight,
    MTDTurnTypeTurn,
    MTDTurnTypeBearRight,
    MTDTurnTypeRight,
    MTDTurnTypeSharpRight,
    MTDTurnTypeBearLeft,
    MTDTurnTypeLeft,
    MTDTurnTypeSharpLeft,
    MTDTurnTypeUTurn,
    MTDTurnTypeMerge,
    MTDTurnTypeMergeRight,
    MTDTurnTypeMergeLeft,
    MTDTurnTypeTakeRampLeft,
    MTDTurnTypeTakeRampRight,
    MTDTurnTypeLeaveRampLeft,
    MTDTurnTypeLeaveRampRight,
    MTDTurnTypeDepart,
    MTDTurnTypeArrive,
    MTDTurnTypeWalk,
    MTDTurnTypeTakeTransit
} MTDTurnType;


NS_INLINE UIImage* MTDGetImageForTurnType(MTDTurnType turnType) {
    NSString *imageName = [NSString stringWithFormat:@"MTDirectionsKit.bundle/turnType_%d", turnType];

    return [UIImage imageNamed:imageName];
}
