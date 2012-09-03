//
//  MTDDirectionAPI.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


/**
 MTDirectionsKit is designed to easily support different APIs as sources for the directions it parses and displays.
 Once integrated, the used API can be switched at runtime by calling MTDDirectionsSetActiveAPI.
 
 The currently supported APIs are:
 
 - MTDDirectionsAPIMapQuest
 - MTDDirectionsAPIGoogle
 - MTDDirectionsAPIBing
 - MTDDirectionsAPICustom: Implement your own data source/parser
 */
typedef enum {
    MTDDirectionsAPIMapQuest,
    MTDDirectionsAPIGoogle,
    MTDDirectionsAPIBing,
    MTDDirectionsAPICustom,
    MTDDirectionsAPICount
} MTDDirectionsAPI;


/** 
 This function returns the current used API for direction retreival.
 
 @return the current active API used for retreiving directions
 */
MTDDirectionsAPI MTDDirectionsGetActiveAPI(void);

/**
 This functions sets the current used API for direction retreival.
 
 @param activeAPI the new active API to set
 */
void MTDDirectionsSetActiveAPI(MTDDirectionsAPI activeAPI);


//void MTDDirectionsAPIRegisterCustomRequestClass(Class requestClass);
//void MTDDirectionsAPIRegisterCustomParserClass(Class parserClass);
