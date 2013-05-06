//
//  GMSServices.h
//  Google Maps SDK for iOS
//
//  Copyright 2012 Google Inc.
//
//  Usage of this SDK is subject to the Google Maps/Google Earth APIs Terms of
//  Service: https://developers.google.com/maps/terms
//

/** Service class for the Google Maps SDK for iOS. May not be instantiated. */
@interface GMSServices : NSObject

/**
 * Provides your API key to the Google Maps SDK for iOS.  This key is generated
 * for your application via the Google APIs Console, and is paired with your
 * application's bundle ID to identify it.  This should be called exactly once
 * by your application, e.g., in application: didFinishLaunchingWithOptions:.
 *
 * @return YES if the APIKey was successfully provided
 */
+ (BOOL)provideAPIKey:(NSString *)APIKey;

/**
 * Returns the open source software license information for Google Maps SDK for
 * iOS.  This information must be made available within your application.
 */
+ (NSString *)openSourceLicenseInfo;

/**
 * Returns the current version of the Google Maps SDK for iOS.
 */
+ (NSString *)SDKVersion;

@end
