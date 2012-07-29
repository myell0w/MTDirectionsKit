//
//  MTDDirectionsRequestOption.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


typedef enum {
    MTDDirectionsRequestOptionNone                  = 0,
    MTDDirectionsRequestOptionOptimize              = 1,
    MTDDirectionsRequestOptionAlternativeRoutes     = 1 << 1
} MTDDirectionsRequestOption;
