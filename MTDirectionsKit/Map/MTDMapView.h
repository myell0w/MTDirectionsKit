//
//  MTDMapView.h
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
#import "MTDDirectionsDisplayType.h"


@class MTDDirectionsOverlay;
@class MTDDirectionsOverlayView;


/**
 An MTDMapView instance provides functionality to show directions directly on top of the MapView inside your App.
 MTDMapView is a subclass of MKMapView and therefore uses Google Maps as the data source for the map, which we all
 know and love.
 
    MTDMapView *mapView = [[MTDMapView alloc] initWithFrame:self.view.bounds];
    mapView.delegate = self;
 
    [mapView loadDirectionsFrom:CLLocationCoordinate2DMake(51.38713, -1.0316)
                             to:CLLocationCoordinate2DMake(51.4554, -0.9742)
                      routeType:MTDDirectionsRouteTypeFastestDriving
           zoomToShowDirections:YES];
 
 */
@interface MTDMapView : MKMapView

/******************************************
 @name Directions
 ******************************************/

/** 
 The current active direction overlay. Setting the directions overlay automatically removes
 the previous directionsOverlay (if existing) and adds the new directionsOverlay as an overlay
 to the underlying MKMapView.
 */
@property (nonatomic, strong) MTDDirectionsOverlay *directionsOverlay;

/** 
 The current active direction overlay view. This property is only set, if there is a current
 active directionsOverlay.
 */
@property (nonatomic, strong, readonly) MTDDirectionsOverlayView *directionsOverlayView;

/** 
 The current display type of the directions overlay. Currently the overlay can either be hidden
 or shown, depending on this property.
 */
@property (nonatomic, assign) MTDDirectionsDisplayType directionsDisplayType;


/**
 Starts a request and loads the directions between the specified coordinates.
 When the request is finished the directionOverlay gets set on the MapView and
 the region gets set to show the overlay, if the flag zoomToShowDirections is set.
 
 @param fromCoordinate the start point of the direction
 @param toCoordinate the end point of the direction
 @param routeType the type of the route request, e.g. pedestrian, cycling, fastest driving
 @param zoomToShowDirections flag whether the mapView gets zoomed to show the overlay (gets zoomed animated)
 @see cancelLoadOfDirections
 */
- (void)loadDirectionsFrom:(CLLocationCoordinate2D)fromCoordinate
                        to:(CLLocationCoordinate2D)toCoordinate
                 routeType:(MTDDirectionsRouteType)routeType
      zoomToShowDirections:(BOOL)zoomToShowDirections;

/**
 Cancels a possible ongoing request for loading directions.
 Does nothing if there is no request ongoing.
 
  @see loadDirectionsFrom:to:routeType:zoomToShowDirections:
 */
- (void)cancelLoadOfDirections;

/**
 Removes the currenty displayed directionsOverlay view from the MapView, if there exists one.
 Does nothing, if there doesn't exist a directionsOverlay.
 */
- (void)removeDirectionsOverlay;

/******************************************
 @name Region
 ******************************************/

/**
 Sets the region of the MapView to show the whole directionsOverlay at once.
 
 @param animated flag whether the region gets set animated or not
 */
- (void)setRegionToShowDirectionsAnimated:(BOOL)animated;


@end
