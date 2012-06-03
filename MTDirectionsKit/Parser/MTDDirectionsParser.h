//
//  MTDDirectionsParser.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


#import "MTDDirectionsDefines.h"
#import "MTDDirectionsRouteType.h"


@class MTDWaypoint;


/**
 The MTDDirectionsParser protocol defines a set of required methods that instances of
 MTDDirectionsParser need to implement, that want to act as a directions parser.
 */
@protocol MTDDirectionsParser <NSObject>

@required

/******************************************
 @name Directions
 ******************************************/

/** The object used to store the information about the route. */
@property (nonatomic, strong, readonly) id data;
/** The starting waypoint of the route */
@property (nonatomic, strong, readonly) MTDWaypoint *from;
/** The end waypoint of the route */
@property (nonatomic, strong, readonly) MTDWaypoint *to;
/** The type of the route */
@property (nonatomic, assign, readonly) MTDDirectionsRouteType routeType;

/******************************************
 @name Parsing
 ******************************************/

/**
 This method is not implemented in MTDDirectionsParser and must be overwritten by each concrete
 subclass. It parses the data and calls the completion block once finished.
 
 @param completion block that is called, once parsing is finished
 */
- (void)parseWithCompletion:(mtd_parser_block)completion;

@end


/**
 An instance of MTDDirectionsParser is used to parse information about a route from a given fromCoordinate to a given
 toCoordinate. MTDDirectionsParser itself doesn't implement any logic and crashes if you try to parse data with a direct
 instance of MTDDirectionsParser, but is the base class for each concrete parser used in MTDirectionsKit.
 */
@interface MTDDirectionsParser : NSObject <MTDDirectionsParser>

/******************************************
 @name Lifecycle
 ******************************************/

/**
 This method is used to instantiate a concrete MTDDirctionsParser-subclass.
 
 @param from the starting waypoint of the route
 @param to the end waypoint of the route
 @param routeType the type of the route
 @param data the data holding information about the route
 */
- (id)initWithFrom:(MTDWaypoint *)from
                to:(MTDWaypoint *)to
         routeType:(MTDDirectionsRouteType)routeType
              data:(id)data;


@end
