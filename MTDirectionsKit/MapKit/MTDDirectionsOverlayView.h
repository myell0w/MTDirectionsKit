//
//  MTDDirectionsOverlayView.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


/**
 An instance of MTDDirectionsOverlayView is a subclass of MKOverlayView and is used
 to draw the directions/route on top your instance of MTDMapView. It draws a path
 including all waypoints stored in the underlying instance of MTDDirectionsOverlay.
 */
@interface MTDDirectionsOverlayView : MKOverlayView

/** The color used to draw the overlay, default is a blue color */
@property (nonatomic, strong) UIColor *overlayColor;

@end
