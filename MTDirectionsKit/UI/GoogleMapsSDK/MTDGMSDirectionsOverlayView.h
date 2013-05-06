//
//  MTDGMSDirectionsOverlayView.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter on 06.05.13.
//  Copyright (c) 2013 Matthias Tretter (@myell0w). All rights reserved.
//


#import <GoogleMaps/GoogleMaps.h>


@class MTDRoute;


@interface MTDGMSDirectionsOverlayView : GMSPolyline

/**
 The factor MKRoadWidthAtZoomScale gets multiplicated with to compute the width of the overlay.
 The default value is 1.8f, the valid range is between 0.7f and 3.f.
 */
@property (nonatomic, assign) CGFloat overlayLineWidthFactor UI_APPEARANCE_SELECTOR;

- (id)initWithRoute:(MTDRoute *)route;

@end
