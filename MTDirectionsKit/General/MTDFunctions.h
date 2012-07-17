//
//  MTDFunction.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


#import "MTDDirectionsRouteType.h"


extern NSInteger _mtd_wm_;


/**
 Opens the built-in Maps.app and displays the directions from fromCoordinate to toCoordinate
 with the chosen routeType. Since the built-in Maps application only supports travelling per pedes,
 by public transport or by car, MTDDirectionsRouteTypePedestrian is used in case MTDDirectionsRouteTypeBicycle
 was specified.
 
 @param fromCoordinate the start coordinate of the route
 @param toCoordinate the end coordinate of the route
 @param routeType the specified form of travelling, e.g. walking, by bike, by car
 @return YES, if the Maps App was opened successfully, NO otherwise
 */
BOOL MTDDirectionsOpenInMapsApp(CLLocationCoordinate2D fromCoordinate, CLLocationCoordinate2D toCoordinate, MTDDirectionsRouteType routeType);

/**
 Creates a percent-escaped version of the given string.
 
 @param string a string to escape
 @return an escaped string that can be passed as part of an URL
 */
NSString* MTDURLEncodedString(NSString *string);

/**
 Returns a formatted string description of a time-interval in seconds. 
 When the time interval is below 1 Hour, the format "mm:ss" is used, otherwise "H:mm:ss".
 
 @param interval the number of seconds
 @return a formatted time string, e.g. 2:04:14 (= 2 h, 4 min, 14 sec)
 */
NSString* MTDGetFormattedTime(NSTimeInterval interval);

/**
 Returns a formatted string description of a time-interval in seconds.
 
 @param interval the number of seconds
 @param format the date format used for formatting
 @return a formatted time string
 */
NSString* MTDGetFormattedTimeWithFormat(NSTimeInterval interval, NSString *format);

/**
 Returns a string description of a CLLocationCoordinate2D struct.
 
 @return a string description of a coordinate if it is valid, @"Invalid CLLocationCoordinate2D" otherwise
 */
NSString* MTDStringFromCLLocationCoordinate2D(CLLocationCoordinate2D coordinate);

/**
 Returns a darkened color by the given difference.
 
 @return a color with the alpha components of the original color subtracted by difference
 */
UIColor* MTDDarkenedColor(UIColor *color, CGFloat difference);

/**
 Checks whether the line between the two given points intersects the given mapRect.
 
 @param p0 the starting point of the line
 @param p1 the end point of the line
 @param rect the rect to test intersection with
 */
BOOL MTDDirectionLineIntersectsRect(MKMapPoint p0, MKMapPoint p1, MKMapRect rect);
