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

- (void)mtd_stopUpdatingLocationCallingCompletion:(BOOL)callingCompletion;
- (void)mtd_notifyDelegateDidFailLoadingOverlayWithError:(NSError *)error;

@end
