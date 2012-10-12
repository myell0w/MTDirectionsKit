//
//  MTDLocale+Google.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


#import "MTDLocale.h"

/**
 This function returns the currently set locale for the Google Directions API.
 For a list of supported locals see
 [Google Directions Supported Language Codes](https://spreadsheets.google.com/pub?key=p9pdwsai2hDMsLkXsoM05KQ&gid=1 "Google Directions Supported Language Codes")

 @return the currently set locale (= language code)
 */
NS_INLINE NSString* MTDDirectionsGetLocaleGoogle(void) {
    return MTDDirectionsGetLanguage();
}

