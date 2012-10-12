//
//  MTDDirectionsRequestBing.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//

#import <MTDirectionsKit/MTDirectionsKit.h>


/**
 An instance of MTDDirectionsRequestBing is a concrete instance to request directions data of a route
 from the [Bing Routes API](http://msdn.microsoft.com/en-us/library/ff701705 "Bing Routes API").
 */
@interface MTDDirectionsRequestBing : MTDDirectionsRequest

/**
 Set your Bing Maps API Key to be used, this key is mandatory.
 
 @param APIKey your Bing Maps API Key to use for making requests
 */
+ (void)registerAPIKey:(NSString *)APIKey;

/**
 This method indicates whether an API Key was set or not. It delivers no information
 whether the set API Key is valid or not.
 
 @return YES if an API Key was set, NO otherwise
 */
+ (BOOL)isAPIKeyRegistered;

@end
