//
//  MTDDirectionOverlay.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter on 21.01.12.
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


#import "MTDDirectionsRouteType.h"


/**
 An instance of MTDirectionsOverlay implements MKOverlay and represents an overlay used to store information
 about a route with given waypoints.
 */
@interface MTDDirectionsOverlay : NSObject <MKOverlay>

/******************************************
 @name Directions-Route
 ******************************************/

/** all waypoints of the current active direction, including fromCoordinate and toCoordinate */
@property (nonatomic, strong, readonly) NSArray *waypoints;
/** the starting coordinate of the directions */
@property (nonatomic, readonly) CLLocationCoordinate2D fromCoordinate;
/** the end coordinate of the directions */
@property (nonatomic, readonly) CLLocationCoordinate2D toCoordinate;
/** the distance of the directions */
@property (nonatomic, assign, readonly) CLLocationDistance distance;
/** the routeType used to compute the directions */
@property (nonatomic, assign, readonly) MTDDirectionsRouteType routeType;

/** all mapPoints of the polyline */
@property (nonatomic, readonly) MKMapPoint *points;
/** the number of mapPoints of the polyline */
@property (nonatomic, readonly) NSUInteger pointCount;

/** all maneuvers on this route */
@property (nonatomic, strong) NSArray *maneuvers;

/**
 Creates an overlay with the given waypoints, distance and routeType.
 
 @param waypoints the waypoints of the route
 @param distance the total distance from the first to the last waypoint
 @param routeType the type of route computed
 @return an overlay encapsulating the given route-information
 */
+ (MTDDirectionsOverlay *)overlayWithWaypoints:(NSArray *)waypoints 
                                     distance:(CLLocationDistance)distance
                                    routeType:(MTDDirectionsRouteType)routeType;

@end
