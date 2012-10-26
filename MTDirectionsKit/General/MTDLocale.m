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
        mtd_locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        // and then try to set the current locale, if it is supported
        MTDDirectionsSetLocale([NSLocale currentLocale]);

        // the user can configure the supported locales by changing MTDirectionsKit.bundle/SupportedLocales.plist
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"MTDirectionsKit.bundle/SupportedLocales" ofType:@"plist"];
        mtd_supportedLocales = [NSDictionary dictionaryWithContentsOfFile:plistPath];

        // If we can't find the plist in the bundle create a default one
        if (mtd_supportedLocales == nil) {
            MTDLogWarning(@"MTDirectionsKit.bundle is missing, make sure to add it to your bundle resources!");

            mtd_supportedLocales = (@{
                                    // Google and Bing have a fallback to English
                                    kMTDKeyGoogle : @[],
                                    kMTDKeyBing : @[],
                                    // currently known locales that are supported by MapQuest API
                                    // taken from http://developer.mapquest.com/web/products/open/forums/-/message_boards/view_message/390942
                                    kMTDKeyMapQuest : (@[
                                                       @"da_DK",
                                                       @"de_DE",
                                                       @"en_GB",
                                                       @"en_US",
                                                       @"en_CA",
                                                       @"es_ES",
                                                       @"es_XL",
                                                       @"fr_CA",
                                                       @"fr_FR",
                                                       @"it_IT",
                                                       @"nb_NO",
                                                       @"nl_NL",
                                                       @"pt_PT",
                                                       @"sv_SE",
                                                       @"zh_TW",
                                                       @"zh_CN",
                                                       @"nl_BE",
                                                       @"ja_JP",
                                                       @"hi_IN",
                                                       @"zh_HK",
                                                       @"el_GR",
                                                       @"ga_IE",
                                                       @"hu_HU",
                                                       @"id_ID",
                                                       @"ru_RU",
                                                       @"uk_UA",
                                                       @"vi_VN",
                                                       @"he_IL"
                                                       ])

                                    });
        }
    }
}

void MTDDirectionsSetLocale(NSLocale* locale) {
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
