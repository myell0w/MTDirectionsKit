//
//  MTDFunction.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


#import "MTDDirectionsRouteType.h"


@class MTDWaypoint;


// Safer method for KVO
#define MTDKey(_SEL)               (NSStringFromSelector(@selector(_SEL)))


/**
 Opens the built-in Maps.app and displays the directions from fromCoordinate to toCoordinate
 with the chosen routeType. Since the built-in Maps application only supports travelling per pedes,
 by public transport or by car, MTDDirectionsRouteTypePedestrian is used in case MTDDirectionsRouteTypeBicycle
 was specified.
 
 @param from the starting waypoint of the route
 @param to the end waypoint of the route
 @param routeType the specified form of travelling, e.g. walking, by bike, by car
 @return YES, if the Maps App was opened successfully, NO otherwise
 */
BOOL MTDDirectionsOpenInMapsApp(MTDWaypoint *from, MTDWaypoint *to, MTDDirectionsRouteType routeType);

/**
 Creates a percent-escaped version of the given string.
 
 @param string a string to escape
 @return an escaped string that can be passed as part of an URL
 */
NSString* MTDURLEncodedString(NSString *string);

/**
 Creates a string representation where all XML/HTML tags are stripped.
 
 @param string a string containing xml entities
 @return a string without xml entities, keeping all content
 */
NSString* MTDStringByStrippingXMLTags(NSString *string);

/**
 Creates a string by squashing all whitespace s.t. no 2 whitespace characters occur right after each other.
 
 @param string the string to squash the whitespace of
 @return a string with no more than one whitespace character in between other characters
 */
NSString* MTDStringByStrippingUnnecessaryWhitespace(NSString *string);

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

/**
 Orders an array according to the indexes contained in sequence. E.g. if array = [A,B,C] and sequence=[3,2,1]
 the resulting array will be [C,B,A]. The number of elements in array and sequence must match.
 
 @param array the array to order
 @param sequence the array with the new index order
 @return a newly ordered array 
 */
NSArray *MTDOrderedArrayWithSequence(NSArray *array, NSArray *sequence);

/**
 This function returns a flag that indicates whether we are running on iOS 6 or up and Apple Maps
 are used as map source instead of Google Maps.

 @return YES, if we are on iOS6 or up, NO otherwise
 */
BOOL MTDDirectionsSupportsAppleMaps(void);

/**
 This function returns an image with the given size and color.
 
 @param size the size of the image
 @param color the color of the image
 @return a solid image with the given parameters
 */
UIImage *MTDColoredImage(CGSize size, UIColor *color);

/**
 If there exists an element in the array with the given index, this function returns it.
 If not, the function returns nil.
 
 @param array the array to search
 @param index the index of the object to search form
 @return the element at the given index or nil
 */
NS_INLINE id MTDObjectAtIndexOfArray(NSArray *array, NSUInteger index) {
    if (index < array.count) {
        return [array objectAtIndex:index];
    }
    
    return nil;
}

/**
 If there are elements in the array this function returns the first element, otherwise nil.
 
 @param array an array that can contain elements or not
 @return the first element of the array if there are some, nil otherwise
 */
NS_INLINE id MTDFirstObjectOfArray(NSArray *array) {
    return MTDObjectAtIndexOfArray(array, 0);
}

/**
 This function returns a version string of the current MTDirectionsKit version.
 
 @return MTDirectionsKit version string
 */
NS_INLINE NSString* MTDDirectionsKitGetVersionString() {
    return @"1.6.0";
}
