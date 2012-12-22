//
//  MTDWaypoint+MTDirectionsPrivateAPI.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


#import "MTDWaypoint.h"


@interface MTDWaypoint (MTDirectionsPrivateAPI)

@property (nonatomic, assign, readwrite) CLLocationCoordinate2D coordinate;

/**
 Update the coordinate of [MTDWaypoint waypointForCurrentLocation] with the given coordinate.
 
 @param coordinate the coordinate of the user location
 */
+ (void)mtd_updateCurrentLocationCoordinate:(CLLocationCoordinate2D)coordinate;

@end
