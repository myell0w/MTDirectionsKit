#import "MTDDirectionsAPI.h"


#define kMTDDirectionsDefaultAPI              MTDDirectionsAPIMapQuest


/** the current active API used */
static MTDDirectionsAPI mt_activeAPI = kMTDDirectionsDefaultAPI;

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDDirectionsAPI
////////////////////////////////////////////////////////////////////////

MTDDirectionsAPI MTDDirectionsGetActiveAPI(void) {
    return mt_activeAPI;
}

void MTDDirectionsSetActiveAPI(MTDDirectionsAPI activeAPI) {
    if (activeAPI < MTDDirectionsAPICount) {
        mt_activeAPI = activeAPI;
    }
}