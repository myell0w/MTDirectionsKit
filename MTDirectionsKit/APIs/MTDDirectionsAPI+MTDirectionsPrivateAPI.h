//
//  MTDDirectionsAPI+MTDDirectionsPrivateAPI.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


#import "MTDDirectionsAPI.h"
#import "MTDDirectionsRequestGoogle.h"
#import "MTDDirectionsRequestMapQuest.h"
#import "MTDDirectionsParserGoogle.h"
#import "MTDDIrectionsParserMapQuest.h"


NS_INLINE Class MTDDirectionsRequestClassForAPI(MTDDirectionsAPI api) {
    switch (api) {
        case MTDDirectionsAPIGoogle:
            return [MTDDirectionsRequestGoogle class];

        case MTDDirectionsAPIMapQuest:
        default:
            return [MTDDirectionsRequestMapQuest class];
    }
}

NS_INLINE Class MTDDirectionsParserClassForAPI(MTDDirectionsAPI api) {
    switch (api) {
        case MTDDirectionsAPIGoogle:
            return [MTDDirectionsParserGoogle class];

        case MTDDirectionsAPIMapQuest:
        default:
            return [MTDDirectionsParserMapQuest class];
    }
}
