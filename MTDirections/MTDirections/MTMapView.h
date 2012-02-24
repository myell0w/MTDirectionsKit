//
//  MKMapView+MTDirections.h
//  MTDirections
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

#import "MTDirectionsRouteType.h"
#import "MTDirectionsDisplayType.h"

@class MTDirectionsOverlay;
@class MTDirectionsOverlayView;

@interface MTMapView : MKMapView

/** the current active direction overlay */
@property (nonatomic, strong) MTDirectionsOverlay *directionsOverlay;
/** the current active direction overlay view */
@property (nonatomic, strong) MTDirectionsOverlayView *directionsOverlayView;
/** the display type of the current direction */
@property (nonatomic, assign) MTDirectionsDisplayType directionsDisplayType;

/**
 Starts a request and loads the directions between the specified coordinates.
 When the request is finished the directionOverlay gets set on the MapView and
 the region gets set to show the overlay, if the flag zoomToShowDirections is set.
 
 @param fromCoordinate the start point of the direction
 @param toCoordinate the end point of the direction
 @param routeType the type of the route request, e.g. pedestrian, cycling, fastest driving
 @param zoomToShowDirections flag whether the mapView gets zoomed to show the overlay (gets zoomed animated)
 */
- (void)loadDirectionsFrom:(CLLocationCoordinate2D)fromCoordinate
                        to:(CLLocationCoordinate2D)toCoordinate
                 routeType:(MTDirectionsRouteType)routeType
      zoomToShowDirections:(BOOL)zoomToShowDirections;

/**
 Cancels a possible ongoing request for loading directions
 */
- (void)cancelLoadOfDirections;

/**
 Sets the region of the MapView to show the whole directionOverlay at once.
 
 @param animated flag whether the region gets set animated
 */
- (void)setRegionToShowDirectionsAnimated:(BOOL)animated;

/**
 When the MapView is in the mode to show Maneuvers this method shows the next maneuver in detail (if possible).
 
 @return YES if there is a next maneuver to show, NO otherwise
 */
- (BOOL)showNextManeuver;

/**
 When the MapView is in the mode to show Maneuvers this method shows the previous maneuver in detail (if possible).
 
 @return YES if there is a previous maneuver to show, NO otherwise
 */
- (BOOL)showPreviousManeuver;


@end
