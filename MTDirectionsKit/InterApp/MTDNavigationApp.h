//
//  MTDNavigationApp.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter on 18.12.12.
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


#import "MTDDirectionsRouteType.h"


@class MTDWaypoint;


@interface MTDNavigationApp : NSObject

+ (BOOL)isAppInstalled;

/*
 Opens the built-in Maps.app and displays the directions from fromCoordinate to toCoordinate
 with the chosen routeType. Since the built-in Maps application only supports travelling per pedes,
 by public transport or by car, MTDDirectionsRouteTypePedestrian is used in case MTDDirectionsRouteTypeBicycle
 was specified.

 @param from the starting waypoint of the route
 @param to the end waypoint of the route
 @param routeType the specified form of travelling, e.g. walking, by bike, by car
 @return YES, if the Maps App was opened successfully, NO otherwise
 */
+ (BOOL)openDirectionsFrom:(MTDWaypoint *)from
                        to:(MTDWaypoint *)to
                 routeType:(MTDDirectionsRouteType)routeType;

@end
