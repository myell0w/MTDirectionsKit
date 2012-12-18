#import "MTDNavigationApp.h"


@implementation MTDNavigationApp

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDNavigationApp
////////////////////////////////////////////////////////////////////////

+ (BOOL)isAppInstalled {
    MTDAssert(NO, @"This method is only implemented in subclasses.");

    return NO;
}

+ (BOOL)openDirectionsFrom:(__unused MTDWaypoint *)from
                        to:(__unused MTDWaypoint *)to
                 routeType:(__unused MTDDirectionsRouteType)routeType {
    MTDAssert(NO, @"This method is only implemented in subclasses.");

    return NO;
}

@end
