#import "MTHTTPFetcher.h"

@interface MTHTTPFetcher () {
    NSMutableData *data_;
	id receiver;
	SEL action;
    
	NSURLConnection *connection;
	NSURLAuthenticationChallenge *challenge;
}

@property (nonatomic, strong, readwrite) NSMutableData *data;

@end

@implementation MTHTTPFetcher

@synthesize data = data_;
@synthesize urlRequest = urlRequest_;
@synthesize failureCode = failureCode_;
@synthesize responseHeaderFields = responseHeaderFields_;
@synthesize context = context_;

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithURLRequest:(NSURLRequest *)aURLRequest
                receiver:(id)aReceiver
                  action:(SEL)receiverAction {
    
	if ((self = [super init])) {
		action = receiverAction;
		receiver = aReceiver;
		urlRequest_ = aURLRequest;
		
		connection = [[NSURLConnection alloc] initWithRequest:aURLRequest
                                                     delegate:self
                                             startImmediately:NO];
	}
    
	return self;
}

- (id)initWithURLString:(NSString *)aURLString
               receiver:(id)aReceiver
                 action:(SEL)receiverAction {
	NSURL *url = [NSURL URLWithString:aURLString];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
	return [self initWithURLRequest:request receiver:aReceiver action:receiverAction];
}

- (id)initWithURLString:(NSString *)aURLString
                timeout:(NSTimeInterval)aTimeoutInterval
            cachePolicy:(NSURLCacheStoragePolicy)aCachePolicy
               receiver:(id)aReceiver
                 action:(SEL)receiverAction {
	NSURL *url = [NSURL URLWithString:aURLString];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
	[request setTimeoutInterval:aTimeoutInterval];
	[request setCachePolicy:aCachePolicy];
    
	return [self initWithURLRequest:request receiver:aReceiver action:receiverAction];
}

- (void)dealloc {
	[self cancel];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTHTTPFetcher
////////////////////////////////////////////////////////////////////////

- (void)start {
	[connection start];
}

- (void)close {
	[connection cancel];
	connection = nil;
	challenge = nil;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
	[receiver performSelector:action withObject:self];
#pragma clang diagnostic pop
	receiver = nil;
    
	data_ = nil;
}

- (void)cancel {
	receiver = nil;
	[self close];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - NSURLConnectionDelegate
////////////////////////////////////////////////////////////////////////

- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSHTTPURLResponse *)aResponse {
	responseHeaderFields_ = [aResponse allHeaderFields];
    
	if ([aResponse statusCode] >= 400) {
		[self close];
		return;
	}
	
	NSInteger contentLength = [[responseHeaderFields_ objectForKey:@"Content-Length"] integerValue];
    
	if (contentLength > 0) {
		data_ = [[NSMutableData alloc] initWithCapacity:contentLength];
	} else {
		data_ = [[NSMutableData alloc] init];
	}
}

- (void)connection:(NSURLConnection *)aConnection didReceiveData:(NSData *)newData {
	[data_ appendData:newData];
}

- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)error {
	if ([[error domain] isEqual:NSURLErrorDomain]) {
		failureCode_ = [error code];
	}
    
	[self close];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection {
	[self close];
}

@end
