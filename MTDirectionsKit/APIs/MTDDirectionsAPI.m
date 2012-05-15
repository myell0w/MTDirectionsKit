#import "MTDDirectionsAPI.h"


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
    }
}