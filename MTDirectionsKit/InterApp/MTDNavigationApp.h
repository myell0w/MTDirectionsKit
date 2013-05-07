//
//  MTDNavigationApp.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter on 18.12.12.
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


#import "MTDDirectionsRouteType.h"


@class MTDWaypoint;


/**
 This abstract class provides the API for opening given directions in another App on your iOS device
 */
@interface MTDNavigationApp : NSObject

/**
 This method indicates whether the given app is installed on the device. Subclasses must override.
 
 @return YES if the app is istalled, NO otherwise
 */
+ (BOOL)isAppInstalled;

/**
 Opens the given app and displays the directions from fromCoordinate to toCoordinate
 with the chosen routeType.

 @param from the starting waypoint of the route
 @param to the end waypoint of the route
 @param routeType the specified form of travelling, e.g. walking, by bike, by car
 @return YES, if the app was opened successfully, NO otherwise
 */
+ (BOOL)openDirectionsFrom:(MTDWaypoint *)from
                        to:(MTDWaypoint *)to
                 routeType:(MTDDirectionsRouteType)routeType;

@end
