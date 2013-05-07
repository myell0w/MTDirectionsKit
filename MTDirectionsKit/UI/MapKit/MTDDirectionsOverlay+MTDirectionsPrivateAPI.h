//
//  MTDDirectionsOverlay+MTDirectionsPrivateAPI.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


@class MTDRoute;


/**
 This category exposes private API used in MTDirectionsKit to other classes to not generate warnings when using them.
 You should not use the properties and methods exposed here directly in your code.
 */
@interface MTDDirectionsOverlay (MTDirectionsPrivateAPI)

/**
 This method sets the activeRoute property of MTDDiretionsOverlay.
 
 @param route the new active route
 */
- (void)mtd_activateRoute:(MTDRoute *)route;

@end
