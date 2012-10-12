//
//  MTDStatusCodeBing.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


/**
 MTDStatusCodeMapBing is an enum for various status codes that can be returned by
 the [Bing Routes API](http://msdn.microsoft.com/en-us/library/ff701705 "Bing Routes API").
 
 The currently supported status codes are:

 - MTDStatusCodeBingSuccess            = 200
 - MTDStatusCodeBingBadRequest         = 400
 - MTDStatusCodeBingUnauthorized       = 401
 - MTDStatusCodeBingForbidden          = 403
 - MTDStatusCodeBingNotFound           = 404
 - MTDStatusCodeBingInternalError      = 500
 - MTDStatusCodeBingServiceUnavailable = 503

 For further information have a look at the
 [Bing API Status Codes](http://msdn.microsoft.com/en-us/library/ff701703.aspx "Status Codes").
 */
typedef NS_ENUM(NSUInteger, MTDStatusCodeBing) {
    MTDStatusCodeBingSuccess            = 200,
    MTDStatusCodeBingBadRequest         = 400,
    MTDStatusCodeBingUnauthorized       = 401,
    MTDStatusCodeBingForbidden          = 403,
    MTDStatusCodeBingNotFound           = 404,
    MTDStatusCodeBingInternalError      = 500,
    MTDStatusCodeBingServiceUnavailable = 503
};
