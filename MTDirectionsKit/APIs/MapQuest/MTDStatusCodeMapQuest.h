//
//  MTDStatusCodeMapQuest.h
//  MTDirectionsKit
//
//  Created by Tretter Matthias on 13.05.12.
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//
// http://www.mapquestapi.com/directions/status_codes.html

typedef enum {
    MTDStatusCodeMapQuestSuccess            = 0,
    MTDStatusCodeMapQuestIllegalArgument    = 400,
    MTDStatusCodeMapQuestKeyError           = 403,
    MTDStatusCodeMapQuestUnknownError       = 500,
    MTDStatusCodeMapQuestInvalidLocation    = 601,
    MTDStatusCodeMapQuestRouteFailed        = 602,
    MTDStatusCodeMapQuestNoDatasetFound     = 603,
    MTDStatusCodeMapQuestAmbiguitiesFound   = 610,
} MTDStatusCodeMapQuest;
