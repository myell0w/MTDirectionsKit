//
//  MTDDirectionOverlay.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter on 21.01.12.
//  Copyright (c) 2009-2012  Matthias Tretter, @myell0w. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
