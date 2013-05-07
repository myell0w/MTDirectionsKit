//
//  MTDWaypoint+MTDDirectionsAPI.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter on 07.05.13.
//  Copyright (c) 2013 Matthias Tretter (@myell0w). All rights reserved.
//


#import <MTDirectionsKit/MTDirectionsKit.h>


/**
 This category adds functionality to MTDWaypoint that is used to perform the various API network requests.
 */
@interface MTDWaypoint (MTDDirectionsAPI)

/******************************************
 @name API
 ******************************************/

/**
 Returns a string representation of this waypoint used for the call to the given API.

 @param api the API we use to retreive the directions
 @return string representation that can be used as part of the URL to call the API
 */

- (NSString *)descriptionForAPI:(MTDDirectionsAPI)api;

@end
