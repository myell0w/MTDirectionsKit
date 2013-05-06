//
//  MTDMapView+MTDirectionsPrivateAPI.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


/**
 This category exposes private API used in MTDirectionsKit to other classes to not generate warnings when using them.
 You should not use the properties and methods exposed here directly in your code.
 */
@interface MTDMapView (MTDirectionsPrivateAPI)

/** 
 Stops the internal CLLocationManager and calls the completion block, if specified.
 
 @param callingCompletion if YES, the completion block of the location manager is called
 */
- (void)mtd_stopUpdatingLocationCallingCompletion:(BOOL)callingCompletion;

/**
 Notifies the delegate of the mapView that loading of directions failed.
 
 @param error the error that is reported to the delegate
 */
- (void)mtd_notifyDelegateDidFailLoadingOverlayWithError:(NSError *)error;

@end
