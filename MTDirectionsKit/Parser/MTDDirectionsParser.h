//
//  MTDDirectionsParser.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter on 21.01.12.
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


#import "MTDDirectionsDefines.h"
#import "MTDDirectionsRouteType.h"


/**
 An instance of MTDDirectionsParser is used to parse information about a route from a given fromCoordinate to a given
 toCoordinate. MTDDirectionsParser itself doesn't implement any logic but is the base class for each concrete parser
 used in MTDirectionsKit.
 */
@interface MTDDirectionsParser : NSObject

/******************************************
 @name Directions
 ******************************************/

/** The object used to store the information about the route. */
@property (nonatomic, strong, readonly) id data;
/** The starting coordinate of the route */
@property (nonatomic, assign, readonly) CLLocationCoordinate2D fromCoordinate;
/** The end coordinate of the route */
@property (nonatomic, assign, readonly) CLLocationCoordinate2D toCoordinate;
/** The type of the route */
@property (nonatomic, assign, readonly) MTDDirectionsRouteType routeType;

/******************************************
 @name Lifecycle
 ******************************************/

/**
 This method is used to instantiate a concrete MTDDirctionsParser-subclass.
 
 @param fromCoordinate the start coordinate of the route
 @param toCoordinate the end coordinate of the route
 @param routeType the type of the route
 @param data the data holding information about the route
 */
- (id)initWithFromCoordinate:(CLLocationCoordinate2D)fromCoordinate
                toCoordinate:(CLLocationCoordinate2D)toCoordinate
                   routeType:(MTDDirectionsRouteType)routeType
                        data:(id)data;

/******************************************
 @name Parsing
 ******************************************/

/**
 This method is not implemented in MTDDirectionsParser and must be overwritten by each concrete
 subclass. It parses the data and calls the completion block once finished.
 
 @param completion block that is called, once parsing is finished
 */
- (void)parseWithCompletion:(mtd_direction_block)completion;

@end
