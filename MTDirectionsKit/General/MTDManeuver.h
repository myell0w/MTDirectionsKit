//
//  MTDManeuver.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


#import "MTDCardinalDirection.h"


@class MTDWaypoint;


@interface MTDManeuver : NSObject

@property (nonatomic, strong, readonly) MTDWaypoint *waypoint;
@property (nonatomic, assign, readonly) CLLocationDistance distance;
@property (nonatomic, assign, readonly) NSTimeInterval time;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy, readonly) NSString *instructions;
@property (nonatomic, assign, readonly) MTDCardinalDirection cardinalDirection;

+ (MTDManeuver *)maneuverWithWaypoint:(MTDWaypoint *)waypoint
                             distance:(CLLocationDistance)distance
                                 time:(NSTimeInterval)time
                         instructions:(NSString *)instructions
                    cardinalDirection:(MTDCardinalDirection)cardinalDirection;


- (id)initWithWaypoint:(MTDWaypoint *)waypoint
              distance:(CLLocationDistance)distance
                  time:(NSTimeInterval)time
          instructions:(NSString *)instructions
     cardinalDirection:(MTDCardinalDirection)cardinalDirection;

@end
