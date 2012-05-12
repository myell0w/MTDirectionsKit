//
//  MTDDirectionsDisplayType.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter on 22.02.12.
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


/** 
 Specifies how we want to display the direcitons.
 We can either show an overview of the directions or detailed maneuvers 
 */
typedef enum {
    MTDDirectionsDisplayTypeNone = 0,
    MTDDirectionsDisplayTypeOverview,
    MTDDirectionsDisplayTypeDetailedManeuvers
} MTDDirectionsDisplayType;