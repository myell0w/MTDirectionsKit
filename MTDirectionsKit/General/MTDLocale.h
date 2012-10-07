//
//  MTDLocale.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


/**
 This function sets the currently used locale for directions request. This locale influences
 the language of the maneuver instructions returned by the used API. The default value is
 [NSLocale currentLocale]. Google Directions API as well as Bing Routes API return maneuvers in
 English, if the set locale isn't supported by the API, MapQuest does return an error-message.
 
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
