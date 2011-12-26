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
