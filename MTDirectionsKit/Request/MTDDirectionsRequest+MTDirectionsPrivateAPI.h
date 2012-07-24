//
//  MTDDirectionsRequest+MTDirectionsPrivateAPI.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


#import "MTDDirectionsRequest.h"


/** 
 This category exposes private API used in MTDirectionsKit to other classes to not generate warnings when using them. 
 You should not use the properties and methods exposed here directly in your code.
 */
@interface MTDDirectionsRequest (MTDPrivateAPI)

/** object used to perform a HTTP request */
@property (nonatomic, strong, setter = mtd_setHttpRequest:) MTDHTTPRequest *mtd_HTTPRequest;
/** the address of the the request to perform */
@property (nonatomic, readonly) NSString *mtd_HTTPAddress;
/** the class of the directions-parser used to parse the obtained data */
@property (nonatomic, readonly) Class mtd_parserClass;
/** flag whether the route gets optimized when there are intermediate goals */
@property (nonatomic, readonly) BOOL mtd_optimizeRoute;

/** 
 This method is called once the request is finished.
 
 @param httpRequest the object used to perform the request
 */
- (void)mtd_requestFinished:(MTDHTTPRequest *)httpRequest;

@end
