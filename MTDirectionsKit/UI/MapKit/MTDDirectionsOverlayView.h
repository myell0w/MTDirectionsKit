//
//  MTDDirectionsOverlayView.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


#import "MTDCustomization.h"


@class MTDRoute;


/**
 An instance of MTDDirectionsOverlayView is a subclass of MKOverlayView and is used
 to draw the directions/route on top your instance of MTDMapView. It draws a path
 including all waypoints stored in the underlying instance of MTDDirectionsOverlay.
 
 This class can be overridden with a subclass by using MTDOverrideClass.
 */
@interface MTDDirectionsOverlayView : MKOverlayView

/** Current line width at the current zoom level */
@property (nonatomic, readonly) CGFloat fullLineWidth;

/** Flag that indicates whether the maneuver points are drawn, defaults to NO */
@property (nonatomic, assign) BOOL drawManeuvers;

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

/**
 Returns the shortest distance between a given point and a route.
 
 @param point a (touch) point on the overlay view
 @param route one of the routes of the overlay
 
 @return the shortest distance between the point and the route, or FLT_MAX
 */
- (CGFloat)distanceBetweenPoint:(CGPoint)point route:(MTDRoute *)route;

/**
 The color used to draw the route. If you don't set a specific color for a route self.overlayColor is used.
 
 @param overlayColor the color to draw the route with
 @param route the route we set the color of
 @see overlayColor
 */
- (void)setOverlayColor:(UIColor *)overlayColor forRoute:(MTDRoute *)route;

/**
 Returns the color with which the route is drawn.
 
 @param route the route we wan't the color of
 @return the color of the route or self.overlayColor if none was set
 */
- (UIColor *)overlayColorForRoute:(MTDRoute *)route;


/**
 This method draws the given path of the route in the mapRect at the given zoom scale.

 You can override this method in a subclass if you want to customize the drawing in ways that cannot be changed 
 using overlayColor and overlayLineWidthFactor. Be sure to call super in case you want to draw the default route
 and only add your custom drawing to it.
 
 @param path the path ref to draw
 @param route the route that was used to compute the path
 @param activeRoute flag that indicates whether the route is the currently selected one
 @param mapRect the mapRect in which the path is drawn
 @param zoomScale the current zoom scale
 @param context the context used for drawing
 */
- (void)drawPath:(CGPathRef)path
         ofRoute:(MTDRoute *)route
     activeRoute:(BOOL)activeRoute
         mapRect:(MKMapRect)mapRect
       zoomScale:(MKZoomScale)zoomScale
       inContext:(CGContextRef)context;

@end
