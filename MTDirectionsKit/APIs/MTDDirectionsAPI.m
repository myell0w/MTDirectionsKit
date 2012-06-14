#import "MTDDirectionsAPI.h"
#import "MTDFunctions.h"
#import "MTDLogging.h"


#define kMTDDirectionsDefaultAPI              MTDDirectionsAPIMapQuest


/** the current active API used */
static MTDDirectionsAPI mtd_activeAPI = kMTDDirectionsDefaultAPI;

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
        if (MTDDirectionsSupportsAppleMaps() && activeAPI == MTDDirectionsAPIGoogle) {
            MTDLogAlways(@"The Google Directions API Terms forbid using MTDDirectionsAPIGoogle to display directions on top of Apple Maps.");
        }
    }
}
