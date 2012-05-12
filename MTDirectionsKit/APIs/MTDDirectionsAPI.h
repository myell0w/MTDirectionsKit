//
//  MTDDirectionAPI.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter on 21.01.12.
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


#import "MTDDirectionsRouteType+MapQuest.h"

/**
 All supported APIs for Direction Retreival
 */
typedef enum {
    MTDDirectionsAPIMapQuest,
    MTDDirectionsAPICount
} MTDDirectionsAPI;

/** Retreive the current use API for directions */
MTDDirectionsAPI MTDDirectionsGetActiveAPI(void);

/** Set the current use API for directions */
void MTDDirectionsSetActiveAPI(MTDDirectionsAPI activeAPI);