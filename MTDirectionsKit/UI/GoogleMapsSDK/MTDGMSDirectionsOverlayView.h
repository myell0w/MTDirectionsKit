//
//  MTDGMSDirectionsOverlayView.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter on 06.05.13.
//  Copyright (c) 2013 Matthias Tretter (@myell0w). All rights reserved.
//


#import <GoogleMaps/GoogleMaps.h>


@class MTDDirectionsOverlay;
@class MTDRoute;


/**
 An instance of MTDGMSDirectionsOverlayView is a subclass of GMSPolyline and is used
 to draw the directions/route on top your instance of MTDGMSMapView (Google Maps SDK).
 It draws a path including all waypoints stored in one route of the underlying instance of MTDDirectionsOverlay.

 Therefore this class behaves different from its analog class in the MapKit version of MTDirectionsKit as it is
 only responsible for drawing one route and not several alternative routes.
 
 Remark: This class currently cannot be customized using UIAppearance.
 */
@interface MTDGMSDirectionsOverlayView : GMSPolyline

/**
 The color used to draw the overlay, default is a blue color.
 This color is used if you don't set a specific color for a route with setOverlayColor:forRoute:
 */
@property (nonatomic, strong) UIColor *overlayColor;

/**
 The factor MKRoadWidthAtZoomScale gets multiplicated with to compute the width of the overlay.
 The default value is 1.8f, the valid range is between 0.7f and 3.f.
 */
@property (nonatomic, assign) CGFloat overlayLineWidthFactor;

/**
 The designated initializer.
 
 @param directionsOverlay a weak reference to the overlay that contains the model data for this overlay view
 @param route the route that is represented/displayed by this overlay view
 */
- (id)initWithDirectionsOverlay:(MTDDirectionsOverlay *)directionsOverlay route:(MTDRoute *)route;

/**
 Returns the shortest distance between a given point and the route. 
 For API compatibility there is a route parameter specified that must match the route
 of the overlay.

 @param point a (touch) point on the overlay view
 @param route must be equal to the route of this overlay view

 @return the shortest distance between the point and the route, or FLT_MAX
 */
- (CGFloat)distanceBetweenPoint:(CGPoint)point route:(MTDRoute *)route;

@end
