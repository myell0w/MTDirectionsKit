//
//  MTDGTMStringEncoding.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//
//
//  MTDGTMStringEncoding is a stripped-down version of GTMStringEncoding from the Google Toolbox
//  with the following license:
// 
//  GTMStringEncoding.h
//
//  Copyright 2010 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not
//  use this file except in compliance with the License.  You may obtain a copy
//  of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
//  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
//  License for the specific language governing permissions and limitations under
//  the License.
//

/**
 MTDGTMStringEncoding is used to convert from and to a websafe base64 encoding.
 */
@interface MTDGTMStringEncoding : NSObject

/**
 Creates an instance of MTDGTMStringEncoding
 
 @return an instance to perform websafe base64 encoding and decoding
 */
+ (instancetype)rfc4648Base64WebsafeStringEncoding;

/**
 Decodes the given string into the corresponding data.
 
 @param string a bas64-encoded string
 @return the decoded data
 */
- (NSData *)decode:(NSString *)string;

/**
 Encodes the given data into a websafe base64-format.
 
 @param data the data to encode
 @return a base64-encoded string
 */
- (NSString *)encode:(NSData *)data;

@end
