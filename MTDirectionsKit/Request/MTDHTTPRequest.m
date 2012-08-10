#import "MTDHTTPRequest.h"


@interface MTDHTTPRequest () <NSURLConnectionDelegate>  {
    NSMutableURLRequest *_urlRequest;
    NSMutableData *_data;
	SEL _action;
}

// We hold a strong reference to the callbackTarget, which temporary can lead to a retain cycle.
// We break the cycle when the connection fails or finishes.
@property (nonatomic, strong, setter = mtd_setCallbackTarget:) id mtd_callbackTarget;
@property (nonatomic, strong, setter = mtd_setConnection:) NSURLConnection *mtd_connection;

@end


@implementation MTDHTTPRequest

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithAddress:(NSString *)address callbackTarget:(id)callbackTarget action:(SEL)action {
    if ((self = [super init])) {
        NSURL *url = [NSURL URLWithString:address];
        
        _urlRequest = [NSMutableURLRequest requestWithURL:url];
        _action = action;
		_mtd_callbackTarget = callbackTarget;
		
		
		_mtd_connection = [[NSURLConnection alloc] initWithRequest:_urlRequest
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
	[self.mtd_connection start];
}

- (void)cancel {
    // first set callbackTarget to nil to not call it in case of cancel
	self.mtd_callbackTarget = nil;
	[self mtd_close];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - HTTP specific parameter
////////////////////////////////////////////////////////////////////////

- (void)setHTTPBody:(NSData *)bodyData {
    [_urlRequest setHTTPBody:bodyData];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - NSURLConnectionDelegate
////////////////////////////////////////////////////////////////////////

- (void)connection:(NSURLConnection *) __unused connection didReceiveResponse:(NSHTTPURLResponse *)response {
	_responseHeaderFields = [response allHeaderFields];
    
	if (response.statusCode >= 400) {
		[self mtd_close];
		return;
	}
	
	NSInteger contentLength = [_responseHeaderFields[@"Content-Length"] integerValue];
    
	if (contentLength > 0) {
		_data = [[NSMutableData alloc] initWithCapacity:(NSUInteger)contentLength];
	} else {
		_data = [NSMutableData new];
	}
}

- (void)connection:(NSURLConnection *) __unused connection didReceiveData:(NSData *)data {
	[_data appendData:data];
}

- (void)connection:(NSURLConnection *) __unused connection didFailWithError:(NSError *)error {
	if ([[error domain] isEqual:NSURLErrorDomain]) {
		_failureCode = error.code;
	}
    
	[self mtd_close];
}

- (void)connectionDidFinishLoading:(NSURLConnection *) __unused connection {
	[self mtd_close];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

- (void)mtd_close {
	[self.mtd_connection cancel];
	self.mtd_connection = nil;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
	[self.mtd_callbackTarget performSelector:_action withObject:self];
#pragma clang diagnostic pop
    
	self.mtd_callbackTarget = nil;
    _data = nil;
}

@end
