#import "MTDHTTPRequest.h"

@interface MTDHTTPRequest () <NSURLConnectionDelegate>  {
    NSMutableData *_data;
	SEL _action;
}

// We hold a strong reference to the callbackTarget, which temporary can lead to a retain cycle.
// We break the cycle when the connection fails or finishes.
@property (nonatomic, strong) id callbackTarget;
@property (nonatomic, strong) NSURLConnection *connection;

/** Callbacks the callbackTarget and closes the connection afterwards */
- (void)close;

// Isn't in NSURLConnectionDelegate protocol, so we provide the method header to suppress warnings
- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection;

@end

@implementation MTDHTTPRequest

@synthesize data = _data;
@synthesize urlRequest = _urlRequest;
@synthesize failureCode = _failureCode;
@synthesize responseHeaderFields = _responseHeaderFields;
@synthesize callbackTarget = _callbackTarget;
@synthesize connection = _connection;

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithAddress:(NSString *)address callbackTarget:(id)callbackTarget action:(SEL)action {
    if ((self = [super init])) {
        NSURL *url = [NSURL URLWithString:address];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        
        _action = action;
		_callbackTarget = callbackTarget;
		_urlRequest = request;
		
		_connection = [[NSURLConnection alloc] initWithRequest:request
                                                     delegate:self
                                             startImmediately:NO];
    }
    
    return self;
	
}

- (void)dealloc {
	[self cancel];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - HTTP Connection
////////////////////////////////////////////////////////////////////////

- (void)start {
    _failureCode = 0;
	[self.connection start];
}

- (void)close {
	[self.connection cancel];
	self.connection = nil;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
	[self.callbackTarget performSelector:_action withObject:self];
#pragma clang diagnostic pop

	self.callbackTarget = nil;
    _data = nil;
}

- (void)cancel {
    // first set callbackTarget to nil to not call it in case of cancel
	self.callbackTarget = nil;
	[self close];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - NSURLConnectionDelegate
////////////////////////////////////////////////////////////////////////

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {
	_responseHeaderFields = [response allHeaderFields];
    
	if (response.statusCode >= 400) {
		[self close];
		return;
	}
	
	NSInteger contentLength = [[_responseHeaderFields objectForKey:@"Content-Length"] integerValue];
    
	if (contentLength > 0) {
		_data = [[NSMutableData alloc] initWithCapacity:contentLength];
	} else {
		_data = [[NSMutableData alloc] init];
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[_data appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	if ([[error domain] isEqual:NSURLErrorDomain]) {
		_failureCode = error.code;
	}
    
	[self close];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[self close];
}

@end
