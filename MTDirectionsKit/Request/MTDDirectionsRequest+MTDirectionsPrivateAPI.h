//
//  MTDDirectionsRequest+MTDirectionsPrivateAPI.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter on 21.01.12.
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


#import "MTDDirectionsRequest.h"


/** 
 This category exposes private API used in MTDirectionsKit to other classes to not generate warnings when using them. 
 You should not use the properties and methods exposed here directly in your code.
 */
@interface MTDDirectionsRequest (MTDPrivateAPI)

/** object used to perform a HTTP request */
@property (nonatomic, strong) MTDHTTPRequest *httpRequest;
/** the address of the the request to perform */
@property (nonatomic, copy) NSString *httpAddress;
/** the class of the parser used to parse the obtained data */
@property (nonatomic, assign) Class parserClass;

/** 
 This method is called once the request is finished.
 
 @param httpRequest the object used to perform the request
 */
- (void)requestFinished:(MTDHTTPRequest *)httpRequest;

@end