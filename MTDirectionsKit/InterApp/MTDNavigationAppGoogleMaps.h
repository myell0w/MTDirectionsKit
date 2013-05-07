//
//  MTDNavigationAppGoogleMaps.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


#import "MTDNavigationApp.h"


/**
 A specific subclass of MTDNavigationApp that represents the Google Maps App released in the App Store
 (not the built-in Google Maps app up to iOS 5).
 */
@interface MTDNavigationAppGoogleMaps : MTDNavigationApp

/**
 Opens the directions and displays them on http://maps.google.com in Safari.
 
 @param from the starting waypoint of the route
 @param to the end waypoint of the route
 @param routeType the specified form of travelling, e.g. walking, by bike, by car
 @return YES, if the app was opened successfully, NO otherwise
 */
+ (BOOL)openWebsiteDirectionsFrom:(MTDWaypoint *)from to:(MTDWaypoint *)to routeType:(MTDDirectionsRouteType)routeType;

@end
