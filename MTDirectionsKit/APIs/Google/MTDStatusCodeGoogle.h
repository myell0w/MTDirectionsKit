//
//  MTDStatusCodeGoogle.h
//  MTDirectionsKit
//
//  Created by Tretter Matthias
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


/**
 MTDStatusCodeGoogle is an enum for various status codes that can be returned by
 the [Google Directions API](https://developers.google.com/maps/documentation/directions/?hl=en-EN "Google Directions API").
 
 The currently supported values are:
 
 - MTDStatusCodeGoogleSuccess
 - MTDStatusCodeGoogleNotFound
 - MTDStatusCodeGoogleZeroResults
 - MTDStatusCodeGoogleMaxWaypointsExceeded
 - MTDStatusCodeGoogleInvalidRequest
 - MTDStatusCodeGoogleOverQueryLimit
 - MTDStatusCodeGoogleRequestDenied
 - MTDStatusCodeGoogleUnknownError
 
 For further information have a look at the 
 [Google Directions API Status Codes](https://developers.google.com/maps/documentation/directions/?hl=en-EN#StatusCodes "Status Codes").
 */
typedef NS_ENUM(NSUInteger, MTDStatusCodeGoogle) {
    MTDStatusCodeGoogleSuccess                  = 0,
    MTDStatusCodeGoogleNotFound                 = 404,
    MTDStatusCodeGoogleZeroResults              = 701,
    MTDStatusCodeGoogleMaxWaypointsExceeded,
    MTDStatusCodeGoogleInvalidRequest,
    MTDStatusCodeGoogleOverQueryLimit,
    MTDStatusCodeGoogleRequestDenied,
    MTDStatusCodeGoogleUnknownError
};


NS_INLINE NSString* MTDStatusCodeGoogleDescription(MTDStatusCodeGoogle statusCode) {
    switch (statusCode) {
        case MTDStatusCodeGoogleSuccess:
            return @"OK";
            
        case MTDStatusCodeGoogleNotFound:
            return @"NOT_FOUND";
            
        case MTDStatusCodeGoogleZeroResults:
            return @"ZERO_RESULTS";
            
        case MTDStatusCodeGoogleMaxWaypointsExceeded:
            return @"MAX_WAYPOINTS_EXCEEDED";
            
        case MTDStatusCodeGoogleInvalidRequest:
            return @"INVALID_REQUEST";
            
        case MTDStatusCodeGoogleOverQueryLimit:
            return @"OVER_QUERY_LIMIT";
            
        case MTDStatusCodeGoogleRequestDenied:
            return @"REQUEST_DENIED";
            
        case MTDStatusCodeGoogleUnknownError:
        default:
            return @"UNKNOWN_ERROR";
    }
}

NS_INLINE MTDStatusCodeGoogle MTDStatusCodeGoogleFromDescription(NSString *statusCodeDescription) {
    if ([statusCodeDescription isEqualToString:@"OK"]) {
        return MTDStatusCodeGoogleSuccess;
    } else if ([statusCodeDescription isEqualToString:@"NOT_FOUND"]) {
        return MTDStatusCodeGoogleNotFound;
    } else if ([statusCodeDescription isEqualToString:@"ZERO_RESULTS"]) {
        return MTDStatusCodeGoogleZeroResults;
    } else if ([statusCodeDescription isEqualToString:@"MAX_WAYPOINTS_EXCEEDED"]) {
        return MTDStatusCodeGoogleMaxWaypointsExceeded;
    } else if ([statusCodeDescription isEqualToString:@"INVALID_REQUEST"]) {
        return MTDStatusCodeGoogleInvalidRequest;
    } else if ([statusCodeDescription isEqualToString:@"OVER_QUERY_LIMIT"]) {
        return MTDStatusCodeGoogleOverQueryLimit;
    } else if ([statusCodeDescription isEqualToString:@"REQUEST_DENIED"]) {
        return MTDStatusCodeGoogleRequestDenied;
    } else if ([statusCodeDescription isEqualToString:@"UNKNOWN_ERROR"]) {
        return MTDStatusCodeGoogleUnknownError;
    } else {
        return MTDStatusCodeGoogleUnknownError;
    }
}
