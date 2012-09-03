//
//  MTDBase64.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


/**
 Decodes the given base64-encoded string.
 
 @param string a base64-encoded string
 @return the data represented by the string
 */
NSData* MTDDataWithBase64EncodedString(NSString *string);

/**
 Encodes the given data with Base64.
 
 @param data the data to encode
 @return a base64-encoded string
 */
NSString* MTDBase64EncodedStringFromData(NSData *data);
