//
//  MTDLocale+MapQuest.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//

#import "MTDLocale.h"


NS_INLINE NSString* MTDDirectionsGetLocaleMapQuest(void) {
    return [MTDDirectionsGetLocale() localeIdentifier];
}

