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


/**
 Returns the Class of the DirectionsRequest to use for the given API.
 
 @return a subclass of MTDDirectionsRequest
 */
NS_INLINE Class MTDDirectionsRequestClassForAPI(MTDDirectionsAPI api) {
    switch (api) {
        case MTDDirectionsAPIGoogle:
            return [MTDDirectionsRequestGoogle class];

        case MTDDirectionsAPIMapQuest:
        default:
            return [MTDDirectionsRequestMapQuest class];
    }
}

/**
 Returns the Class of the DirectionsParser to use for the given API.

 @return a subclass of MTDDirectionsParser
 */
NS_INLINE Class MTDDirectionsParserClassForAPI(MTDDirectionsAPI api) {
    switch (api) {
        case MTDDirectionsAPIGoogle:
            return [MTDDirectionsParserGoogle class];

        case MTDDirectionsAPIMapQuest:
        default:
            return [MTDDirectionsParserMapQuest class];
    }
}
