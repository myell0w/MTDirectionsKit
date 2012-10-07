#import "MTDLocale.h"


static NSLocale *mtd_locale = nil;


NS_INLINE __attribute__((constructor)) void MTDLoadLocale(void) {
    @autoreleasepool {
        mtd_locale = [NSLocale currentLocale];
    }
}

void MTDDirectionsSetLocale(NSLocale* locale) {
    mtd_locale = locale;

    MTDLogVerbose(@"Locale was set to %@",[locale localeIdentifier]);
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
