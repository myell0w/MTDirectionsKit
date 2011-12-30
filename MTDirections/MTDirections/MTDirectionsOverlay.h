//
//  MTDirectionOverlay.h
//  MTDirections
//
//  Created by Matthias Tretter on 21.01.11.
//  Copyright (c) 2009-2012  Matthias Tretter, @myell0w. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "MTDirectionsRouteType.h"

@interface MTDirectionsOverlay : NSObject <MKOverlay>

/** 
 Internally using a MKPolyline to represent the overlay since MKPolyline cannot be subclassed
 and we don't want to reinvent the wheel here
 */
@property (nonatomic, strong) MKPolyline *polyline;

/** all waypoints of the current active direction */
@property (nonatomic, strong) NSArray *waypoints;
/** the distance of the directions */
@property (nonatomic, assign, readonly) CLLocationDistance distance;
/** the routeType used to compute the directions */
@property (nonatomic, assign, readonly) MTDirectionsRouteType routeType;

+ (MTDirectionsOverlay *)overlayWithWaypoints:(NSArray *)waypoints 
                                     distance:(CLLocationDistance)distance
                                    routeType:(MTDirectionsRouteType)routeType;

@end
