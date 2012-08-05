//
//  MTDRoute+MTDirectionsPrivateAPI.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


#import "MTDRoute.h"


/** 
 This category exposes private API used in MTDirectionsKit to other classes to not
 generate warnings when using them. You should not use the properties and methods 
 exposed here directly in your code.
 */
@interface MTDRoute (MTDirectionsPrivateAPI)

/** Internally we use a MKPolyline in MTDRoute to represent the overlay. */
@property (nonatomic, readonly) MKPolyline *mtd_polyline;

@end
