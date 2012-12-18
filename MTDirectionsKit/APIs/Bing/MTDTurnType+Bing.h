//
//  MTDTurnType+Bing.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//

#import "MTDTurnType.h"

NS_INLINE MTDTurnType MTDTurnTypeFromBingDescription(NSString *description) {
    // exact matching
    if ([description isEqualToString:@"Continue"]) {
        return MTDTurnTypeStraight;
    } else if ([description isEqualToString:@"TakeRampLeft"] || [description isEqualToString:@"RampThenHighwayLeft"]) {
        return MTDTurnTypeTakeRampLeft;
    } else if ([description isEqualToString:@"RampThenHighwayRight"]) {
        return MTDTurnTypeTakeRampRight;
    } else if ([description isEqualToString:@"TakeRampRight"]) {
        return MTDTurnTypeLeaveRampRight;
    } else if ([description isEqualToString:@"TakeRampLeft"]) {
        return MTDTurnTypeLeaveRampLeft;
    } else if ([description isEqualToString:@"UTurn"] || [description isEqualToString:@"TurnBack"]) {
        return MTDTurnTypeUTurn;
    } else if ([description isEqualToString:@"Unknown"]) {
        return MTDTurnTypeUnknown;
    } else if ([description isEqualToString:@"Walk"]) {
        return MTDTurnTypeWalk;
    } else if ([description isEqualToString:@"Merge"]) {
        return MTDTurnTypeMerge;
    } else if ([description isEqualToString:@"TakeRampStraight"] || [description isEqualToString:@"KeepStraight"] ||
               [description isEqualToString:@"KeepOnRampStraight"] || [description isEqualToString:@"KeepToStayStraight"] ||
               [description isEqualToString:@"RampThenHighwayStraight"] || [description isEqualToString:@"RampToHighwayStraight"]) {
        return MTDTurnTypeStraight;
    } else if ([description isEqualToString:@"TurnToStayRight"]) {
		return MTDTurnTypeTurnRightToStay;
	} else if ([description isEqualToString:@"TurnToStayLeft"]) {
		return MTDTurnTypeTurnLeftToStay;
	} else if ([description isEqualToString:@"EnterThenExitRoundabout"]) {
		return MTDTurnTypeRoundabout;
	}

    // Groups of turnTypes
    else if ([description hasPrefix:@"Arrive"]) {
        return MTDTurnTypeArrive;
    } else if ([description hasPrefix:@"BearLeft"] || [description isEqualToString:@"KeepLeft"] ||
               [description isEqualToString:@"KeepToStayLeft"] || [description isEqualToString:@"KeepOnRampLeft"]) {
        return MTDTurnTypeBearLeft;
    } else if ([description hasPrefix:@"BearRight"] || [description isEqualToString:@"KeepRight"] ||
               [description isEqualToString:@"KeepToStayRight"] || [description isEqualToString:@"KeepOnRampRight"]) {
        return MTDTurnTypeBearRight;
    } else if ([description rangeOfString:@"Transit"].location != NSNotFound ||
               [description isEqualToString:@"Transfer"] || [description isEqualToString:@"Wait"]) {
        return MTDTurnTypeTakePublicTransport;
    } else if ([description hasPrefix:@"TurnLeft"]) {
        return MTDTurnTypeLeft;
    } else if ([description hasPrefix:@"TurnRight"]) {
        return MTDTurnTypeRight;
    } else if ([description hasPrefix:@"Depart"]) {
        return MTDTurnTypeDepart;
    } else if ([description hasPrefix:@"Turn"]) {
        return MTDTurnTypeTurn;
    }

    return MTDTurnTypeUnknown;
}
