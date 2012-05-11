//
//  MTDWaypoint.h
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


/**
 An instance of MTDWaypoint is a lightweight immutable object wrapper for a CLLocationCoordinate2D coordinate.
 It is used internally in MTDDirectionsKit to save coordinates in collections like NSArray.
 */
@interface MTDWaypoint : NSObject

/******************************************
 @name Location
 ******************************************/

/** the coordinate wrapped */
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

/******************************************
 @name Lifecycle
 ******************************************/

/**
 This method is used to create an instance of MTDWaypoint with a given coordinate.
 
 @param coordinate the coordinate to save
 @return the wrapper object created to store the coordinate
 
 @see initWithCoordinate:
 */
+ (MTDWaypoint *)waypointWithCoordinate:(CLLocationCoordinate2D)coordinate;

/**
 The designated initializer of MTDWaypoint, used to create an instance of MTDWaypoint that wraps
 a given coordinate.
 
 @param coordinate the coordinate to save
 @return the wrapper object created to store the coordinate
 */
- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end
