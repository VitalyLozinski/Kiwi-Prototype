//
//  NetworkManager.h
//  Kiwi
//
//  Created by Georgiy on 5/10/14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

@interface NetworkManager : NSObject

+ (NetworkManager *)sharedManager;
+ (NSString *)baseApiUrl;
+ (NSString *)baseResourceUrl;

- (void)addNetworkRequest:(NSURLRequest *)request withCompletionHandler:(void (^)(NSData *, NSError *))completionHandler;

@end
