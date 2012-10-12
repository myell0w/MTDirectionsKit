#import "MTDDirectionsAPI.h"
#import "MTDFunctions.h"
#import "MTDLogging.h"
#import "MTDDirectionsRequest.h"
#import "MTDDirectionsParser.h"
#import "MTDDirectionsRequestGoogle.h"
#import "MTDDirectionsRequestMapQuest.h"
#import "MTDDirectionsRequestBing.h"
#import "MTDDirectionsParserGoogle.h"
#import "MTDDIrectionsParserMapQuest.h"
#import "MTDDirectionsParserBing.h"
#import "MTDLocale.h"


#define kMTDDirectionsDefaultAPI              MTDDirectionsAPIMapQuest


// the current active API used
static MTDDirectionsAPI mtd_activeAPI = kMTDDirectionsDefaultAPI;
// the custom request class
static Class mtd_requestClass = nil;
// the custom parser class
static Class mtd_parserClass = nil;


////////////////////////////////////////////////////////////////////////
#pragma mark - MTDDirectionsAPI
////////////////////////////////////////////////////////////////////////

MTDDirectionsAPI MTDDirectionsGetActiveAPI(void) {
    return mtd_activeAPI;
}

void MTDDirectionsSetActiveAPI(MTDDirectionsAPI activeAPI) {
    if (activeAPI < MTDDirectionsAPICount) {
        mtd_activeAPI = activeAPI;
        
        // Google Directions API Terms allow the usage only in combination with Google Maps data
        if (activeAPI == MTDDirectionsAPIGoogle && MTDDirectionsSupportsAppleMaps()) {
            MTDLogAlways(@"The Google Directions API Terms forbid using MTDDirectionsAPIGoogle to display directions"
                         @"on top of Apple Maps. You should switch the active API by calling MTDDirectionsSetActiveAPI().");
        }

        // Re-check if the current locale is supported, if not set to English
        NSLocale *locale = MTDDirectionsGetLocale();
        
        if (!MTDDirectionsLocaleIsSupportedByAPI(locale, activeAPI)) {
            MTDDirectionsSetLocale([[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]);
            MTDLogWarning(@"Currently set locale '%@' isn't supported by API %d, locale was reset to en_US.", locale, activeAPI);
        }
    }
}

void MTDDirectionsAPIRegisterCustomRequestClass(Class requestClass) {
    MTDAssert([requestClass isSubclassOfClass:[MTDDirectionsRequest class]],
              @"Your custom request class must be a subclass of MTDDirectionsRequest");

    if ([requestClass isSubclassOfClass:[MTDDirectionsRequest class]]) {
        mtd_requestClass = requestClass;
    }
}

void MTDDirectionsAPIRegisterCustomParserClass(Class parserClass) {
    MTDAssert([parserClass conformsToProtocol:@protocol(MTDDirectionsParser)],
              @"Your custom parser class must conform to the protocol MTDDirectionsParser");
    
    if ([parserClass conformsToProtocol:@protocol(MTDDirectionsParser)]) {
        mtd_parserClass = parserClass;
    }
}

Class MTDDirectionsRequestClassForAPI(MTDDirectionsAPI api) {
    switch (api) {
        case MTDDirectionsAPIMapQuest:
            return [MTDDirectionsRequestMapQuest class];

        case MTDDirectionsAPIGoogle:
            return [MTDDirectionsRequestGoogle class];

        case MTDDirectionsAPIBing:
            return [MTDDirectionsRequestBing class];

        case MTDDirectionsAPICustom:
            return mtd_requestClass;

        case MTDDirectionsAPICount:
        default:
            return nil;
    }
}

Class MTDDirectionsParserClassForAPI(MTDDirectionsAPI api) {
    switch (api) {
        case MTDDirectionsAPIMapQuest:
            return [MTDDirectionsParserMapQuest class];

        case MTDDirectionsAPIGoogle:
            return [MTDDirectionsParserGoogle class];

        case MTDDirectionsAPIBing:
            return [MTDDirectionsParserBing class];

        case MTDDirectionsAPICustom:
            return mtd_parserClass;

        case MTDDirectionsAPICount:
        default:
            return nil;
    }
}
