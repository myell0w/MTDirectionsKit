//
//  MTDManeuver.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


#import "MTDCardinalDirection.h"
#import "MTDTurnType.h"


@class MTDWaypoint;
@class MTDDistance;


@interface MTDManeuver : NSObject

@property (nonatomic, strong, readonly) MTDWaypoint *waypoint;
@property (nonatomic, strong, readonly) MTDDistance *distance;
@property (nonatomic, assign, readonly) NSTimeInterval timeInSeconds;
@property (nonatomic, copy, readonly) NSString *instructions;

@property (nonatomic, assign) MTDCardinalDirection cardinalDirection;
@property (nonatomic, assign) MTDTurnType turnType;

+ (MTDManeuver *)maneuverWithWaypoint:(MTDWaypoint *)waypoint
                             distance:(MTDDistance *)distance
                        timeInSeconds:(NSTimeInterval)timeInSeconds
                         instructions:(NSString *)instructions;

- (id)initWithWaypoint:(MTDWaypoint *)waypoint
              distance:(MTDDistance *)distance
         timeInSeconds:(NSTimeInterval)timeInSeconds
          instructions:(NSString *)instructions;

@end
