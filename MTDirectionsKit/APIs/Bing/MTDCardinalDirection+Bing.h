//
//  MTDCardinalDirection+Bing.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//

#import "MTDCardinalDirection.h"


NS_INLINE MTDCardinalDirection MTDCardinalDirectionFromBingDescription(NSString *description) {
    if ([description isEqualToString:@"north"]) {
        return MTDCardinalDirectionNorth;
    } else if ([description isEqualToString:@"northeast"]) {
        return MTDCardinalDirectionNorthEast;
    } else if ([description isEqualToString:@"east"]) {
        return MTDCardinalDirectionEast;
    } else if ([description isEqualToString:@"southeast"]) {
        return MTDCardinalDirectionSouthEast;
    } else if ([description isEqualToString:@"south"]) {
        return MTDCardinalDirectionSouth;
    } else if ([description isEqualToString:@"southwest"]) {
        return MTDCardinalDirectionSouthWest;
    } else if ([description isEqualToString:@"west"]) {
        return MTDCardinalDirectionWest;
    } else if ([description isEqualToString:@"northwest"]) {
        return MTDCardinalDirectionNorthWest;
    }

    return MTDCardinalDirectionUnknown;
}
