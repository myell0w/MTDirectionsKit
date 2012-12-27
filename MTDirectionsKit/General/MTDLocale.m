#import "MTDLocale.h"


#define kMTDKeyMapQuest         @"MapQuest"
#define kMTDKeyGoogle           @"Google"
#define kMTDKeyBing             @"Bing"


// current set locale
static NSLocale *mtd_locale = nil;
// supported locales to that can be set
static NSDictionary *mtd_supportedLocales = nil;


// Initializes default value
NS_INLINE __attribute__((constructor)) void MTDLoadLocale(void) {
    @autoreleasepool {
        // we first set the locale to English
        mtd_locale = [[NSLocale alloc] initWithLocaleIdentifier:@"de_DE"];
        // and then try to set the current locale, if it is supported
        MTDDirectionsSetLocale([NSLocale currentLocale]);

        mtd_supportedLocales = (@{
                                // Google and Bing have a fallback to English
                                kMTDKeyGoogle : @[@"de_DE"],
                                kMTDKeyBing : @[@"de_DE"],
                                // currently known locales that are supported by MapQuest API
                                // taken from http://developer.mapquest.com/web/products/open/forums/-/message_boards/view_message/390942
                                kMTDKeyMapQuest : @[@"de_DE"]
                                });
    }
}

void MTDDirectionsSetLocale(NSLocale *locale) {
    MTDDirectionsAPI API = MTDDirectionsGetActiveAPI();

    if (MTDDirectionsLocaleIsSupportedByAPI(locale, API)) {
        mtd_locale = locale;
        MTDLogVerbose(@"Locale was set to %@", [locale localeIdentifier]);
    } else {
        MTDLogWarning(@"Locale '%@' isn't supported by API %d and wasn't set.", [locale localeIdentifier], API);
    }
}

NSLocale* MTDDirectionsGetLocale(void) {
    return mtd_locale;
}

NSString* MTDDirectionsGetLanguage(void) {
    return [MTDDirectionsGetLocale() objectForKey:NSLocaleLanguageCode];
}

NSString* MTDDirectionsGetCountryCode(void) {
    return [MTDDirectionsGetLocale() objectForKey:NSLocaleCountryCode];
}

BOOL MTDDirectionsLocaleIsSupportedByAPI(NSLocale *locale, MTDDirectionsAPI API) {
    NSString *identifier = [locale localeIdentifier];

    if (identifier.length == 0) {
        return NO;
    }

    switch (API) {
        case MTDDirectionsAPIGoogle: {
            // not configured (count == 0) means use fallback to English
            NSArray *supportedLocales = [mtd_supportedLocales valueForKey:kMTDKeyGoogle];
            return supportedLocales.count == 0 || [supportedLocales containsObject:identifier];
        }

        case MTDDirectionsAPIBing: {
            // not configured (count == 0) means use fallback to English
            NSArray *supportedLocales = [mtd_supportedLocales valueForKey:kMTDKeyBing];
            return supportedLocales.count == 0 || [supportedLocales containsObject:identifier];
        }

        case MTDDirectionsAPIMapQuest: {
            NSArray *supportedLocales = [mtd_supportedLocales valueForKey:kMTDKeyMapQuest];
            return [supportedLocales containsObject:identifier];
        }

        case MTDDirectionsAPICustom: {
            return YES;
        }

        case MTDDirectionsAPICount:
        default: {
            return NO;
        }
    }
}
