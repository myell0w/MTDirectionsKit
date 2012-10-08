//
//  MTDDirectionsDisplayType.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


/** 
 MTDirectionsKit is designed to support different forms of visual display of directions
 on top of an instance of MTDMapView.
 
 Currently there are the following types supported:
 
 - MTDDirectionsDisplayTypeNone: don't display anything
 - MTDDirectionsDisplayTypeOverview: displays a polyline with all Waypoints of the route
 - MTDDirectionsDisplayTypeDetailedManeuvers: displays information about the Maneuvers
 */
typedef NS_ENUM(NSUInteger, MTDDirectionsDisplayType) {
    MTDDirectionsDisplayTypeNone = 0,
    MTDDirectionsDisplayTypeOverview,
    MTDDirectionsDisplayTypeDetailedManeuvers
};
