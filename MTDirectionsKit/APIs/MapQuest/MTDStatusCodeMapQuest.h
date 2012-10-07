//
//  MTDStatusCodeMapQuest.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


/**
 MTDStatusCodeMapQuest is an enum for various status codes that can be returned by
 the [MapQuest Open Directions API](http://open.mapquestapi.com/directions/ "MapQuest Open Directions API").
 
 The currently supported values are:
 
 - MTDStatusCodeMapQuestSuccess            = 0
 - MTDStatusCodeMapQuestIllegalArgument    = 400
 - MTDStatusCodeMapQuestKeyError           = 403
 - MTDStatusCodeMapQuestUnknownError       = 500
 - MTDStatusCodeMapQuestInvalidLocation    = 601
 - MTDStatusCodeMapQuestRouteFailed        = 602
 - MTDStatusCodeMapQuestNoDatasetFound     = 603
 - MTDStatusCodeMapQuestAmbiguitiesFound   = 610
 
 For further information have a look at the 
 [MapQuest Open Directions API Status Codes](http://www.mapquestapi.com/directions/status_codes.html "Status Codes").
 */
typedef NS_ENUM(NSUInteger, MTDStatusCodeMapQuest) {
    MTDStatusCodeMapQuestSuccess            = 0,
    MTDStatusCodeMapQuestIllegalArgument    = 400,
    MTDStatusCodeMapQuestKeyError           = 403,
    MTDStatusCodeMapQuestUnknownError       = 500,
    MTDStatusCodeMapQuestInvalidLocation    = 601,
    MTDStatusCodeMapQuestRouteFailed        = 602,
    MTDStatusCodeMapQuestNoDatasetFound     = 603,
    MTDStatusCodeMapQuestAmbiguitiesFound   = 610
};
