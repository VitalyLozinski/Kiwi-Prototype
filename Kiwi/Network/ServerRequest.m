//
//  ServerRequest.h
//  Kiwi
//
//  Created by Georgiy on 5/10/14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

#import "ServerRequest.h"

#import "NetworkManager.h"

@implementation ServerRequest
{
	void (^_requestCompletionHandler)(id result, NSError *error);
}

- (void)startRequest:(NSURLRequest *)request withCompletionHandler:(void (^)(NSDictionary *, NSError *))completionHandler
{
	_requestCompletionHandler = completionHandler;

	[[NetworkManager sharedManager] addNetworkRequest:request withCompletionHandler: ^(NSData *responseData, NSError *responseError) {
	    id jsonObject = nil;
        NSError *parseError = nil;
        if (responseData)
        {
            jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&parseError];
            
            Trace(@"Request:\n%@\n%@\nResponse:\n%@",
                  request.URL.absoluteString,
                  [[NSString alloc]initWithData:request.HTTPBody encoding:NSUTF8StringEncoding],
                  jsonObject);
        }
        if (!responseError)
        {
            if ([jsonObject isKindOfClass:[NSDictionary class]]) {
                NSMutableDictionary *responseObject = [jsonObject[@"response"] mutableCopy];
                NSDictionary *status = responseObject[@"status"];
                NSInteger code = [status[@"code"] integerValue];
                NSString *errorStr = status[@"message"];
                if (code == 1) {
                    [responseObject removeObjectForKey:@"status"];
                    jsonObject = [responseObject allValues][0];
                } else {
                    jsonObject = nil;
                    parseError = [NSError errorWithDomain:NSURLErrorDomain code:code userInfo:@{NSLocalizedDescriptionKey: errorStr}];
                }
            }
            self->_requestCompletionHandler(jsonObject, parseError);
        }
        else
        {
            self->_requestCompletionHandler(@{}, responseError);
        }
	}];
}

@end
