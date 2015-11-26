//
//  ServerRequest.h
//  Kiwi
//
//  Created by Georgiy on 5/10/14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//
//  Server request wrapper declaration

@class HTTPOperation;

@interface ServerRequest : NSObject

@property (nonatomic, readonly) NSOperation *httpOperation;

- (void)startRequest:(NSURLRequest *)request withCompletionHandler:(void (^)(NSDictionary *, NSError *))completionHandler;

@end
