//
//  MTDCardinalDirection+MapQuest.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


#import "MTDCardinalDirection.h"


NS_INLINE MTDCardinalDirection MTDCardinalDirectionFromMapQuestDescription(NSString *description) {
    NSInteger value = [description integerValue];

    switch (value) {
        case 1:
            return MTDCardinalDirectionNorth;

        case 2:
            return MTDCardinalDirectionNorthWest;

        case 3:
            return MTDCardinalDirectionNorthEast;

        case 4:
            return MTDCardinalDirectionSouth;

        case 5:
            return MTDCardinalDirectionSouthEast;

        case 6:
            return MTDCardinalDirectionSouthWest;

        case 7:
            return MTDCardinalDirectionWest;

        case 8:
            return MTDCardinalDirectionEast;

        case 0:
        default:
            return MTDCardinalDirectionUnknown;
    }
}
