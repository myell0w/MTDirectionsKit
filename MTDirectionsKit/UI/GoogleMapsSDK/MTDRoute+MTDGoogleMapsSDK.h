//
//  MTDRoute+MTDGoogleMapsSDK.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter on 06.05.13.
//  Copyright (c) 2013 Matthias Tretter (@myell0w). All rights reserved.
//


#import <MTDirectionsKit/MTDirectionsKit.h>


@class GMSPath;


/**
 This category is an extension of MTDRoute with functionality used for the integration with the Google Maps SDK.
 */
@interface MTDRoute (MTDGoogleMapsSDK)

/**
 The path of CLLocationCoordinate2D coordinates used in the Google Maps SDK
 */
@property (nonatomic, readonly) GMSPath *path;

@end
