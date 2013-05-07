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

 @see setOverlayColor:forRoute:
 */
@property (nonatomic, strong) UIColor *overlayColor;

/**
 The factor MKRoadWidthAtZoomScale gets multiplicated with to compute the width of the overlay.
 The default value is 1.8f, the valid range is between 0.7f and 3.f.
 */
@property (nonatomic, assign) CGFloat overlayLineWidthFactor;

- (id)initWithDirectionsOverlay:(MTDDirectionsOverlay *)directionsOverlay route:(MTDRoute *)route;

@end
