//
//  MTDDirectionsOverlayView+MTDirectionsPrivateAPI.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


/**
 This category exposes private API used in MTDirectionsKit to other classes to not generate warnings when using them.
 You should not use the properties and methods exposed here directly in your code.
 */
@interface MTDDirectionsOverlayView (MTDirectionsPrivateAPI)

/**
 Since touchesBegan/UIGestureRecognizer on MKOverlayView don't seem to work we add a gesture recognizer
 to the MapView, this method forwards a recognized gesture to the tapped overlayView.
 
 @param point the location of the tap in the overlay view
 */
- (void)mtd_handleTapAtPoint:(CGPoint)point;

@end
