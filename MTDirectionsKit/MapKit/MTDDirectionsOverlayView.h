//
//  MTDDirectionsOverlayView.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//

@class MTDRoute;
/**
 An instance of MTDDirectionsOverlayView is a subclass of MKOverlayView and is used
 to draw the directions/route on top your instance of MTDMapView. It draws a path
 including all waypoints stored in the underlying instance of MTDDirectionsOverlay.
 */
@interface MTDDirectionsOverlayView : MKOverlayView

/** Flag that indicates whether the maneuver points are drawn, defaults to NO */
@property (nonatomic, assign) BOOL drawManeuvers;

/** The color used to draw the overlay, default is a blue color */
@property (nonatomic, strong) UIColor *overlayColor UI_APPEARANCE_SELECTOR;

/**
 The factor MKRoadWidthAtZoomScale gets multiplicated with to compute the width of the overlay.
 The default value is 1.8f, the valid range is between 0.7f and 3.f.
 */
@property (nonatomic, assign) CGFloat overlayLineWidthFactor UI_APPEARANCE_SELECTOR;

/** Current line width at the current zoom level */
@property (nonatomic, readonly) CGFloat fullLineWidth;

- (CGFloat)mtd_distanceOfTouchAtPoint:(CGPoint)point toRoute:(MTDRoute *)route;

@end
