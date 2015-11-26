//
//  NetworkManager.m
//  Kiwi
//
//  Created by Georgiy on 5/10/14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

#import "NetworkManager.h"

#define HTTPResponseStatusError 400

@implementation NetworkManager
{
	NSOperationQueue *_operationQueue;
}

- (id)init
{
	if ((self = [super init])) {
		_operationQueue = [NSOperationQueue new];
		_operationQueue.maxConcurrentOperationCount = 5;
	}

	return self;
}

#pragma mark - NetworkManager interface

+ (NetworkManager *)sharedManager
{
	static NetworkManager *sNetworkManager;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
	    sNetworkManager = [NetworkManager new];
	});

	return sNetworkManager;
}

+ (NSString *)baseApiUrl
{
	static NSString *sURLString = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken,
    ^{
        sURLString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"BaseApiUrl"];
    });
    
	return sURLString;
}

+ (NSString *)baseResourceUrl
{
	static NSString *sURLString = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken,
    ^{
        sURLString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"BaseResourceUrl"];
    });
    
	return sURLString;
}

- (void)addNetworkRequest:(NSURLRequest *)request withCompletionHandler:(void (^)(NSData *, NSError *))completionHandler
{
	[NSURLConnection sendAsynchronousRequest:request queue:_operationQueue completionHandler: ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
	    NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
	    if (!connectionError && statusCode >= HTTPResponseStatusError) {
	        connectionError = [NSError errorWithDomain:NSURLErrorDomain code:statusCode userInfo:nil];
		}
	    completionHandler(data, connectionError);
	}];
}

@end
