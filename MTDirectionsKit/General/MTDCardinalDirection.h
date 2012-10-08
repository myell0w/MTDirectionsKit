//
//  MTDCardinalDirection.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


/**
 This enum represents all cardinal directions that can be returned by an API.
 The cardinal direction may be part of an instance of MTDManeuver.
 */
typedef NS_ENUM(NSUInteger, MTDCardinalDirection) {
    MTDCardinalDirectionUnknown = 0,
    MTDCardinalDirectionNorth,
    MTDCardinalDirectionNorthNorthEast,
    MTDCardinalDirectionNorthEast,
    MTDCardinalDirectionEastNorthEast,
    MTDCardinalDirectionEast,
    MTDCardinalDirectionEastSouthEast,
    MTDCardinalDirectionSouthEast,
    MTDCardinalDirectionSouthSouthEast,
    MTDCardinalDirectionSouth,
    MTDCardinalDirectionSouthSouthWest,
    MTDCardinalDirectionSouthWest,
    MTDCardinalDirectionWestSouthWest,
    MTDCardinalDirectionWest,
    MTDCardinalDirectionWestNorthWest,
    MTDCardinalDirectionNorthWest,
    MTDCardinalDirectionNorthNorthWest
};
