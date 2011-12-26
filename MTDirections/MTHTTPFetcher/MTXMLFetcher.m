//
//  XMLFetcher.m
//  CocoaWithLove
//
//  Created by Matt Gallagher on 2011/05/20.
//  Copyright 2011 Matt Gallagher. All rights reserved.
//
//  This software is provided 'as-is', without any express or implied
//  warranty. In no event will the authors be held liable for any damages
//  arising from the use of this software. Permission is granted to anyone to
//  use this software for any purpose, including commercial applications, and to
//  alter it and redistribute it freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software
//     in a product, an acknowledgment in the product documentation would be
//     appreciated but is not required.
//  2. Altered source versions must be plainly marked as such, and must not be
//     misrepresented as being the original software.
//  3. This notice may not be removed or altered from any source
//     distribution.
//

#import "MTXMLFetcher.h"
#import "MTXPathResultNode.h"

@implementation MTXMLFetcher

@synthesize xPathQuery = xPathQuery_;
@synthesize results = results_;

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithURLString:(NSString *)aURLString
             xPathQuery:(NSString *)query
               receiver:(id)aReceiver
                 action:(SEL)receiverAction {
	if ((self = [super initWithURLString:aURLString receiver:aReceiver action:receiverAction])) {
		xPathQuery_ = [query copy];
	}
    
	return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTHTTPFetcher
////////////////////////////////////////////////////////////////////////

- (void)close {
	[super close];
	results_ = nil;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - NSURLConnectionDelegate
////////////////////////////////////////////////////////////////////////

- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection {
	results_ = [MTXPathResultNode nodesForXPathQuery:xPathQuery_ onXML:self.data];

	[super connectionDidFinishLoading:aConnection];
}

@end
