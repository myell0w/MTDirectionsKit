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
    MTDTurnTypeReverse,
    MTDTurnTypeBearRight,
    MTDTurnTypeRight,
    MTDTurnTypeSharpRight,
    MTDTurnTypeBearLeft,
    MTDTurnTypeLeft,
    MTDTurnTypeSharpLeft,
    MTDTurnTypeUTurn,
    MTDTurnTypeMergeRight,
    MTDTurnTypeMergeLeft,
    MTDTurnTypeTakeRampLeft,
    MTDTurnTypeTakeRampRight,
    MTDTurnTypeLeaveRampLeft,
    MTDTurnTypeLeaveRampRight,
} MTDTurnType;


NS_INLINE UIImage* MTDGetImageForTurnType(MTDTurnType turnType) {
    NSString *imageName = [NSString stringWithFormat:@"MTDirectionsKit.bundle/turnType_%d", turnType];

    return [UIImage imageNamed:imageName];
}
