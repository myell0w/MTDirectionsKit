//
//  MTDDirectionsOverlayView.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter on 21.01.12.
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


/**
 An instance of MTDDirectionsOverlayView is a subclass of MKOverlayView that is used to
 draw a route on top of MKMapView.
 */
@interface MTDDirectionsOverlayView : MKOverlayView

/** Flag that indicates whether the maneuver points are drawn */
@property (nonatomic, assign) BOOL drawManeuvers;

@end
