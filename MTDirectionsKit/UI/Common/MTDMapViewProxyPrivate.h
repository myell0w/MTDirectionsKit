//
//  MTDMapView+MTDirectionsPrivateAPI.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


#import "MTDMapViewProtocol.h"


/**
 This protocol exposes private API used in MTDirectionsKit to other classes to not generate warnings when using them.
 You should not use the properties and methods exposed here directly in your code.
 */

@protocol MTDMapViewProxyPrivate <MTDMapView>

/** 
 Stops the internal CLLocationManager and calls the completion block, if specified.
 
 @param callingCompletion if YES, the completion block of the location manager is called
 */
- (void)mtd_stopUpdatingLocationCallingCompletion:(BOOL)callingCompletion;

@end
