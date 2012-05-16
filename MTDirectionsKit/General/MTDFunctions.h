//
//  MTDFunction.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


#import "MTDDirectionsRouteType.h"


/**
 Opens the built-in Maps.app and displays the directions from fromCoordinate to toCoordinate
 with the chosen routeType. Since the built-in Maps application only supports travelling per pedes,
 by public transport or by car, MTDDirectionsRouteTypePedestrian is used in case MTDDirectionsRouteTypeBicycle
 was specified.
 
 @param fromCoordinate the start coordinate of the route
 @param toCoordinate the end coordinate of the route
 @param routeType the specified form of travelling, e.g. walking, by bike, by car
 */
void MTDDirectionsOpenInMapsApp(CLLocationCoordinate2D fromCoordinate, CLLocationCoordinate2D toCoordinate, MTDDirectionsRouteType routeType);

/**
 Creates a percent-escaped version of the given string.
 
 @param string a string to escape
 @return an escaped string that can be passed as part of an URL
 */
NSString* MTDURLEncodedString(NSString *string);

NSString* MTDGetFormattedTime(NSTimeInterval time);