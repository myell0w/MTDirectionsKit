//
//  MTDLocale+Bing.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//

#import "MTDLocale.h"

/**
 This function returns the currently set locale for the Bing Routes API.
 For a list of supported locals see 
 [Bing Supported Culture Codes](http://msdn.microsoft.com/en-us/library/hh441729.aspx "Bing Supported Culture Codes")
 
 @return the currently set locale (= country code)
 */
NS_INLINE NSString* MTDDirectionsGetLocaleBing(void) {
    return MTDDirectionsGetCountryCode();
}

