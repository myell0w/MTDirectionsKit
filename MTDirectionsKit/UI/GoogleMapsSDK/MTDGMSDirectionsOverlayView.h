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

- (id)initWithRoute:(MTDRoute *)route;

@end
