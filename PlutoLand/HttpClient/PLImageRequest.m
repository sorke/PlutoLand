//
//  PLImageRequest.m
//  PlutoLand
//
//  Created by xu xhan on 7/15/10.
//  Copyright 2010 xu han. All rights reserved.
//

#import "PLCore.h"
#import "PLImageRequest.h"





@implementation PLImageRequest

@synthesize url = _url;
@synthesize didFailSelector = _didFailSelector;
@synthesize didFinishSelector = _didFinishSelector;
@synthesize delegate = _delegate;
@synthesize response = _response;
@synthesize isCancelled , isFinished , isStarted;
@dynamic imageData;

static const int timeOutSec = 30;

#pragma mark -
#pragma mark NSObject

- (id)init
{
	if (self = [super init]) {
		_receivedData = [[NSMutableData alloc] init];
		_delegate = nil;
		isStarted =	isFinished = isCancelled = NO;	
		_didFailSelector = @selector(imageRequestFailed:withError:);
		_didFinishSelector = @selector(imageRequestSucceeded:);		
	}
	return self;
}

- (id)initWithURL:(NSString*)urlStr
{
	if (self = [self init]) {
		[self requestGet:urlStr];		
	}
	return self;
}

- (void)requestGet:(NSString*)urlStr
{
	_url = [[NSURL URLWithString:urlStr] retain];
	NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:_url];
	[request setTimeoutInterval:timeOutSec];
	_connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
	[request release];	
}

- (void)dealloc {
    PLSafeRelease(_receivedData);
	[_url release], _url = nil;
	[_response release], _response = nil;
	[_connection release], _connection =nil;
	[super dealloc];
}


#pragma mark -
#pragma mark Public

- (void)start
{
	[_connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[_connection start];
	isStarted = YES;
}

- (void)cancel;
{
	[_connection cancel];
    PLSafeRelease(_receivedData);
	self.isCancelled = YES;
    PLOG(@"canceled task %@",self.url);
}

- (NSData*)imageData
{
	
	//!isFinished || remove check isFinished bcz after delegate (succeeded load)method the value
	// will be set to true. and mostly we need get this data at the delegate method
	// TODO: shall i add new property as taskFinished to work with HttpQueue ?
	if ( [_receivedData length] == 0) {
		return nil;
	}
	return _receivedData;
}


#pragma mark -
#pragma mark Delegate for NSURLRequest

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {

	if ([self.delegate respondsToSelector:self.didFailSelector] ) {
		[self.delegate performSelector:self.didFailSelector withObject:self withObject:error];
	}
	//PLLOG_STR(@"failed",nil);
	self.isFinished = YES;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	
	//PLLOG_STR(@"finished",nil);
//	printf("image load finished\n");
	if (statusCode != 200) {
		NSError* error = [NSError errorWithDomain:@"PLImageFetchError" code:statusCode userInfo:nil];
		if ([self.delegate respondsToSelector:self.didFailSelector] ) {
			[self.delegate performSelector:self.didFailSelector withObject:self withObject:error];
		}		
	}else {
		if ([self.delegate respondsToSelector:self.didFinishSelector] ) {
			[self.delegate performSelector:self.didFinishSelector withObject:self];
		}		
	}

	self.isFinished = YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)aresponse {
	self.response = (NSHTTPURLResponse*)aresponse;
	statusCode = (int)self.response.statusCode;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[_receivedData appendData:data];
}

@end








