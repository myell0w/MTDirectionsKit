//
//  MTDDirectionsRequestOption.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


/**
 These options can be specified as a bitmask when starting a MTDDirectionsRequest.
 Be careful to not specify MTDDirectionsRequestOptionOptimize and MTDDirectionsRequestOptionAlternativeRoutes
 at the same time since this is not supported.
 */
typedef NS_ENUM(NSUInteger, MTDDirectionsRequestOption) {
    MTDDirectionsRequestOptionNone                  = 0,
    MTDDirectionsRequestOptionOptimize              = 1,
    MTDDirectionsRequestOptionAlternativeRoutes     = 1 << 1
};


typedef NSUInteger MTDDirectionsRequestOptions;
