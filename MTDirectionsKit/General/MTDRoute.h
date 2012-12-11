//
//  MTDRoute.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//

#import "MTDDirectionsRouteType.h"

@class MTDWaypoint;
@class MTDDistance;


// Keys used in the additionalInfo dictionary
#define MTDAdditionalInfoCopyrightsKey      @"copyrights"
#define MTDAdditionalInfoWarningsKey        @"warnings"


/**
 An instance of MTDRoute represents one way of travelling from a starting point to an end point.
 When requesting directions alternative routes can be provided, each of whom is represented by
 an instance of MTDRoute.
 */
@interface MTDRoute : NSObject

/******************************************
 @name Route
 ******************************************/

/** a unique name of the route, can be changed */
@property (nonatomic, copy) NSString *name;
/** all waypoints of the route/directions, including from and to */
@property (nonatomic, copy, readonly) NSArray *waypoints;
/** all maneuvers on this route */
@property (nonatomic, copy, readonly) NSArray *maneuvers;
/** the starting point of the directions */
@property (nonatomic, readonly) MTDWaypoint *from;
/** the end point of the directions */
@property (nonatomic, readonly) MTDWaypoint *to;

/** the total distance between fromCoordinate and toCoordinate, when travelled along the given waypoints */
@property (nonatomic, strong, readonly) MTDDistance *distance;
/** the total estimated time for this route */
@property (nonatomic, assign, readonly) NSTimeInterval timeInSeconds;
/** the estimated time as formatted string */
@property (nonatomic, readonly) NSString *formattedTime;
/** the type of travelling used to compute the directions, e.g. walking, by bike etc. */
@property (nonatomic) MTDDirectionsRouteType routeType;
/** 
 Dictionary containing additional information retreived, e.g. warnings and copyrights when 
 using the Google Directions API. You have to handle this information on your own and stick
 to the terms of usage of the API you use.
 */
@property (nonatomic, copy, readonly) NSDictionary *additionalInfo;

/******************************************
 @name MapKit interface
 ******************************************/

/** all mapPoints of the underlying polyline */
@property (nonatomic, readonly) MKMapPoint *points;
/** the number of mapPoints of the polyline */
@property (nonatomic, readonly) NSUInteger pointCount;

/******************************************
 @name Lifecycle
 ******************************************/

/**
 Creates a route with the given waypoints, distance, duration and additional information.
 
 @param waypoints the waypoints of the route
 @param maneuvers the maneuvers along the route
 @param distance the total distance from the first to the last waypoint
 @param timeInSeconds the estimated total duration needed for traversing the waypoints in the given routeType
 @param name the name of the route
 @param routeType the travel type of the route
 @param additionalInfo dictionary with additional information provided by the API, e.g. copyrights
 @return a route object encapsulating the given route-information
 */
- (id)initWithWaypoints:(NSArray *)waypoints
              maneuvers:(NSArray *)maneuvers
               distance:(MTDDistance *)distance
          timeInSeconds:(NSTimeInterval)timeInSeconds
                   name:(NSString *)name
              routeType:(MTDDirectionsRouteType)routeType
         additionalInfo:(NSDictionary *)additionalInfo;


/******************************************
 @name Route
 ******************************************/

/**
 The estimated time as formatted string with a specified time format.
 
 @param format the format of the time, e.g. H:mm:ss
 @return a string-representation of the estimated time with the given format
 */
- (NSString *)formattedTimeWithFormat:(NSString *)format;

@end
