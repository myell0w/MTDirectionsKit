#import "MTDLocale.h"


static NSLocale *mtd_locale = nil;
static NSArray *mtd_mapQuestLocales = nil;


// Initializes default value
NS_INLINE __attribute__((constructor)) void MTDLoadLocale(void) {
    @autoreleasepool {
        // we first set the locale to English
        mtd_locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        // and then try to set the current locale, if it is supported
        MTDDirectionsSetLocale([NSLocale currentLocale]);

        // currently known locales that are supported by MapQuest API
        mtd_mapQuestLocales = (@[
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
                               ]);
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
    switch (API) {
        case MTDDirectionsAPIGoogle:
        case MTDDirectionsAPIBing:
        case MTDDirectionsAPICustom: {
            return YES;
        }

        case MTDDirectionsAPIMapQuest: {
            NSString *identifier = [locale localeIdentifier];

            return [mtd_mapQuestLocales containsObject:identifier];
        }

        case MTDDirectionsAPICount:
        default: {
            return NO;
        }
    }
}
