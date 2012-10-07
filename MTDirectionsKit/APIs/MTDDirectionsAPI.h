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

 Remark: 
 The Google Directions API Terms of Usage explicitely state the Google Directions is only allowed to be used
 when directions are displayed on a Google Map. MTDirectionsKit doesn't force you to do that, but it prints
 a warning to the console if you are trying to do otherwise.
 */
typedef NS_ENUM(NSUInteger, MTDDirectionsAPI) {
    MTDDirectionsAPIMapQuest = 0,
    MTDDirectionsAPIGoogle,
    MTDDirectionsAPIBing,
    MTDDirectionsAPICustom,
    MTDDirectionsAPICount
};


/** 
 This function returns the current used API for direction retreival.
 The default value is MTDDirectionsAPIMapQuest.
 
 @return the current active API used for retreiving directions
 */
MTDDirectionsAPI MTDDirectionsGetActiveAPI(void);

/**
 This functions sets the current used API for direction retreival.
 
 @param activeAPI the new active API to set
 */
void MTDDirectionsSetActiveAPI(MTDDirectionsAPI activeAPI);

/**
 This function registers the given class as the custom request class.
 To fully use a custom API provider you have to set the parser class as well with
 MTDDirectionsAPIRegisterCustomParserClass() and set the active API to MTDDirectionsAPICustom.
 
 @param requestClass the class of the custom request, must be a subclass of MTDDirectionsRequest
 */
void MTDDirectionsAPIRegisterCustomRequestClass(Class requestClass);

/**
 This function registers the given class as the custom parser class.
 To fully use a custom API provider you have to set the request class as well with
 MTDDirectionsAPIRegisterCustomRequestClass() and set the active API to MTDDirectionsAPICustom.

 @param parserClass the class of the custom parser, must conform to the protocol MTDDirectionsParser
 */
void MTDDirectionsAPIRegisterCustomParserClass(Class parserClass);

/**
 Returns the Class of the DirectionsRequest to use for the given API.

 @return a subclass of MTDDirectionsRequest
 */
Class MTDDirectionsRequestClassForAPI(MTDDirectionsAPI api);

/**
 Returns the Class of the DirectionsParser to use for the given API.

 @return a subclass of MTDDirectionsParser
 */
Class MTDDirectionsParserClassForAPI(MTDDirectionsAPI api);
