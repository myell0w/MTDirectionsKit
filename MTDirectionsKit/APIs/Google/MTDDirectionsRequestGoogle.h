//
//  MTDDirectionsRequestGoogle.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


#import "MTDDirectionsRequest.h"


/**
 An instance of MTDDirectionsRequestGoogle is a concrete instance to request data of a route
 from Google Directions API. MTDDirectionsRequestGoogle is a subclass of the abstract MTDDirectionsRequest.
 */
@interface MTDDirectionsRequestGoogle : MTDDirectionsRequest

/**
 When using a Maps API web service in your Maps API for Business application, two parameters are required 
 in addition to the standard parameters: Your client ID as well as a unique signature, generated using your cryptographic key.
 
 You can find detailed information on the Google Maps for Business Site:
 [Google Maps API for Business]( https://developers.google.com/maps/documentation/business/webservices "Google Maps API for Business").
 
 @param clientId Your client ID, this is passed as the value of the client parameter to the service
 @param cryptographicKey The key used to create the unique signature
 @see isBusinessRegistered
 */
 
+ (void)registerBusinessWithClientId:(NSString *)clientId
                    cryptographicKey:(NSString *)cryptographicKey;

/**
 Indicates whether a business was registered to use. Checks if clientId and signature are set.
 
 @return YES if clientId and cryptographicKey are both set, NO otherwise
 @see registerBusinessWithClientId:cryptographicKey:
 */
+ (BOOL)isBusinessRegistered;

@end
