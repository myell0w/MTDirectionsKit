//
//  MTDLocale.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


#import "MTDDirectionsAPI.h"


/**
 This function sets the currently used locale for direction requests. This locale influences
 the language of the maneuver instructions returned by the used API. The default value is
 [NSLocale currentLocale]. Google Directions API as well as Bing Routes API return maneuvers in
 English, if the set locale isn't supported by the API, MapQuest does return an error-message.
 Therefore we check against a known list of supported locales when MapQuest is set as the API.
 
 You can configure the list of Locales you want to support by adding MTDirectionsKit.bundle to
 your project and changing SupportedLocales.plist.
 
 @param locale the new locale to use when requesting directions
 */
void MTDDirectionsSetLocale(NSLocale* locale);

/**
 Returns the currently set locale that is used for direction requests.
 
 @return the current active locale
 */
NSLocale* MTDDirectionsGetLocale(void);

/**
 Returns the language of the currently set locale that is used for direction requests.
 
 @return language code of the current active locale
 */
NSString* MTDDirectionsGetLanguage(void);

/**
 Returns the country code of the currently set locale that is used for direction requests.

 @return country code of the current active locale
 */
NSString* MTDDirectionsGetCountryCode(void);

/**
 This function returns a flag, whether the given locale can be used to request directions from
 the given API. It doesn't mean that the API can return instructions in the given locale, but 
 rather if the API does return instructions at all when this locale is used (Google and Bing
 always return instructions in English, if the locale is not supported - MapQuest returns an
 error message).
 
 @param locale the locale we want to check
 @param API the API we want to know if the locale is supported by
 @return YES in case the given API returns instructions when the locale is set, NO otherwise
 */
BOOL MTDDirectionsLocaleIsSupportedByAPI(NSLocale *locale, MTDDirectionsAPI API);
