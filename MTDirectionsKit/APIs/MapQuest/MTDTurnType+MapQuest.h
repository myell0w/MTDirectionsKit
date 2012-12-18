//
//  MTDTurnType+MapQuest.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


#import "MTDTurnType.h"


NS_INLINE MTDTurnType MTDTurnTypeFromMapQuestDescription(NSString *description) {
    NSInteger value = [description integerValue];

    switch (value) {
        case 0: // straight
            return MTDTurnTypeStraight;

        case 1: // slight right
            return MTDTurnTypeBearRight;

        case 2: // right
            return MTDTurnTypeRight;

        case 3: // sharp right
            return MTDTurnTypeSharpRight;

        case 4: // reverse
            return MTDTurnTypeTurn;

        case 5: // sharp left
            return MTDTurnTypeSharpLeft;

        case 6: // left
            return MTDTurnTypeLeft;

        case 7: // slight left
            return MTDTurnTypeBearLeft;

        case 8: // right u-turn
        case 9: // left u-turn
            return MTDTurnTypeUTurn;

        case 10: // right merge
            return MTDTurnTypeMergeRight;

        case 11: // left merge
            return MTDTurnTypeMergeLeft;

        case 12: // right on ramp
            return MTDTurnTypeTakeRampRight;

        case 13: // left on ramp
            return MTDTurnTypeTakeRampLeft;

        case 14: // right off ramp
            return MTDTurnTypeLeaveRampRight;

        case 15: // left off ramp
            return MTDTurnTypeLeaveRampLeft;

        case 16: // right fork
            return MTDTurnTypeBearRight;

        case 17: // left fork
            return MTDTurnTypeBearLeft;

        case 18: // straight fork
            return MTDTurnTypeStraight;

        default:
            return MTDTurnTypeUnknown;
    }
}
