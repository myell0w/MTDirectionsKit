//
//  MTDHTTPRequest.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


/**
 MTDHTTPRequest is a generic wrapper around NSURLConnection to request data from a specified URL.
 */
@interface MTDHTTPRequest : NSObject

/** The data that was requested */
@property (nonatomic, strong, readonly) NSData *data;
/** The NSURLRequest used, exposed to be configurable */
@property (nonatomic, strong, readonly) NSURLRequest *urlRequest;
/** The response header fields of the request */
@property (nonatomic, strong, readonly) NSDictionary *responseHeaderFields;
/** If an error occured, the failure code is set, otherwise it is 0 */
@property (nonatomic, readonly) NSInteger failureCode;

/******************************************
 @name Lifecycle
 ******************************************/

/**
 The designated initializer is used to create an instance of MTDHTTPRequest.
 
 @param address the string-representation of the URL to request
 @param callbackTarget the object that is called back when the request finishes/fails
 @param action the message that is sent to the callbackTarget
 */
- (id)initWithAddress:(NSString *)address callbackTarget:(id)callbackTarget action:(SEL)action;

/******************************************
 @name HTTP Connection
 ******************************************/

/** Starts the request */
- (void)start;

/** Cancels the request, if he is active, does nothing otherwise. */
- (void)cancel;


@end
