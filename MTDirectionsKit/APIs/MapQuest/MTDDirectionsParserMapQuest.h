//
//  MTDDirectionsParserMapQuest.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


#import "MTDDirectionsParser.h"

/**
 An instance of MTDDirectionsParserMapQuest is a concrete instance used to parse direction data obtained
 from the [MapQuest Open Directions API](http://open.mapquestapi.com/directions/ "MapQuest Open Directions API").
 
 It checks the provided status code and in the case of a success the waypoints along the route and the
 total distance are parsed and an instance of MTDirectionsOverlay is created and passed into the completion block.
 In case of an error an NSError is created holding information about the error by setting the retreived status code.
 */
@interface MTDDirectionsParserMapQuest : MTDDirectionsParser

@end
