//
//  MTDFunction.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


// Safer method for KVO
#define MTDKey(_SEL)               (NSStringFromSelector(@selector(_SEL)))


extern NSInteger _mtd_wm_;


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
 This function returns an image with the given size and color.
 
 @param size the size of the image
 @param color the color of the image
 @return a solid image with the given parameters
 */
UIImage *MTDColoredImage(CGSize size, UIColor *color);

/**
 This function returns a flag that indicates whether we are running on iOS 6 or up and Apple Maps
 are used as map source instead of Google Maps.

 @return YES, if we are on iOS6 or up, NO otherwise
 */
BOOL MTDDirectionsUsesAppleMaps(void);

/**
 This function returns a flag that indicates whether the Google Maps SDK is used.

 @return YES, if the Google Maps SDK is used, NO otherwise
 */
BOOL MTDDirectionsUsesGoogleMapsSDK(void);

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
 Returns a localized string found in UIKit.
 
 @param string the string to localize
 @return a localized string in case one is found, string otherwise
 */
NS_INLINE NSString* MTDLocalizedStringFromUIKit(NSString *string) {
    // derived from https://github.com/0xced/XCDFormInputAccessoryView/blob/master/XCDFormInputAccessoryView/XCDFormInputAccessoryView.m
	NSBundle *UIKitBundle = [NSBundle bundleForClass:[UIApplication class]];

	return [UIKitBundle localizedStringForKey:string value:string table:nil] ?: string;
}

/**
 This function returns a version string of the current MTDirectionsKit version.
 
 @return MTDirectionsKit version string
 */
NS_INLINE NSString* MTDDirectionsKitGetVersionString() {
    return @"1.7";
}

// Helper functions for calculating the distance to each line segment
// Taken from http://stackoverflow.com/a/12185597/235297

NS_INLINE CGFloat MTDSqr(CGFloat x) {
	return x*x;
}

NS_INLINE CGFloat MTDDist2(CGPoint v, CGPoint w) {
	return MTDSqr(v.x - w.x) + MTDSqr(v.y - w.y);
}

NS_INLINE CGFloat MTDDistanceToSegmentSquared(CGPoint p, CGPoint v, CGPoint w) {
    CGFloat l2 = MTDDist2(v, w);

    if (l2 == 0.f) {
        return MTDDist2(p, v);
    }

    CGFloat t = ((p.x - v.x) * (w.x - v.x) + (p.y - v.y) * (w.y - v.y)) / l2;

    if (t < 0.f) {
        return MTDDist2(p, v);
    }

    if (t > 1.f) {
        return MTDDist2(p, w);
    }

    return MTDDist2(p, CGPointMake(v.x + t * (w.x - v.x), v.y + t * (w.y - v.y)));
}

NS_INLINE CGFloat MTDDistanceToSegment(CGPoint point, CGPoint segmentPointV, CGPoint segmentPointW) {
    return sqrtf(MTDDistanceToSegmentSquared(point, segmentPointV, segmentPointW));
}
