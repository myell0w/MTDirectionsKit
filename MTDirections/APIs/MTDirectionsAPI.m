#import "MTDirectionsAPI.h"

#define kMTDirectionsDefaultAPI              MTDirectionsAPIMapQuest

/** the current active API used */
static MTDirectionsAPI mt_activeAPI = kMTDirectionsDefaultAPI;

MTDirectionsAPI MTDirectionsGetActiveAPI(void) {
    return mt_activeAPI;
}

void MTDirectionsSetActiveAPI(MTDirectionsAPI activeAPI) {
    if (activeAPI < MTDirectionsAPICount) {
        mt_activeAPI = activeAPI;
    }
}