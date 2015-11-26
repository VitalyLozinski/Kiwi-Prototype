//
//  ServerRequestQueue.h
//  Kiwi
//
//  Created by Georgiy on 5/10/14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

#import "ServerRequestQueue.h"
#import "ServerRequest.h"
#import "NetworkManager.h"

typedef enum {
	ServerRequestMethodGet,
	ServerRequestMethodPut,
	ServerRequestMethodPost,
	ServerRequestMethodDelete,
} ServerRequestMethod;

typedef enum {
    ServerRequestPathNone,
    ServerRequestPathRegister,
    ServerRequestPathLogin,
    ServerRequestPathGetProfile,
    ServerRequestPathSaveProfile,
    ServerRequestPathChangePassword,
    ServerRequestPathProfilePicture,
    ServerRequestPathEventsList,
    ServerRequestPathEventDetails,
    ServerRequestPathEventCancel,
    ServerRequestPathTrainersList,
    ServerRequestPathMyClasses,
    ServerRequestPathCardSaveCard,
    ServerRequestPathCardUseCard,
    ServerRequestPathEventSaveRating,
    ServerRequestPathPromosList,
} ServerRequestPath;

@interface ServerRequestQueue ()

- (NSMutableURLRequest *)requestForServerLink:(ServerLink)serverLink withDictionary:(NSDictionary *)dictionary;

- (void)preprocessResponse:(NSDictionary *)dictionary forLink:(ServerLink)link error:(NSError **)error;
- (void)removeRequest:(ServerRequest *)request;

@end

@implementation ServerRequest (QueueExtension)

- (void)cancel
{
	[self.httpOperation cancel];
	[[ServerRequestQueue defaultQueue] removeRequest:self];
}

@end

@implementation ServerRequestQueue {
    NSString *_sessionKey;
	NSMutableSet * _activeRequests;
}

#pragma mark - ServerRequestQueue interface

+ (instancetype)defaultQueue
{
	static ServerRequestQueue *sDefaultQueue;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
	    sDefaultQueue = [ServerRequestQueue new];
	});
	return sDefaultQueue;
}

- (ServerRequest *)addServerRequestForLink:(ServerLink)link withBodyDict:(NSDictionary *)updateDict completionHandler:(void (^)(id result, NSError *error))requestCompletionHandler
{
	NSMutableURLRequest *request = [self requestForServerLink:link withDictionary:updateDict];

	ServerRequest *serverRequest = [ServerRequest new];
	if (!_activeRequests) {
		_activeRequests = [NSMutableSet new];
	}
	[_activeRequests addObject:serverRequest];
	__weak typeof(self) weakSelf = self;

	[serverRequest startRequest:request withCompletionHandler: ^(id result, NSError *error) {
	    __strong typeof(weakSelf) strongSelf = weakSelf;
	    [strongSelf preprocessResponse:result forLink:link error:&error];
	    requestCompletionHandler(result, error);
	    [strongSelf removeRequest:serverRequest];
	}];
	return serverRequest;
}

#pragma mark - Private interface

- (NSMutableURLRequest *)requestForServerLink:(ServerLink)serverLink withDictionary:(NSDictionary *)dictionary
{
	static NSDictionary *sRequestDictionary;
	static NSDictionary *sMethodStrings;
	static NSDictionary *sPathStrings;
	static NSDictionary *sRequestPathParams;

	if (!sRequestDictionary) {
		sRequestDictionary = @{ @(ServerLinkRegister): @[@(ServerRequestPathRegister)],
                                @(ServerLinkLogin): @[@(ServerRequestPathLogin)],
                                @(ServerLinkGetProfile): @[@(ServerRequestPathGetProfile)],
                                @(ServerLinkSaveProfile): @[@(ServerRequestPathSaveProfile)],
                                @(ServerLinkChangePassword): @[@(ServerRequestPathChangePassword)],
                                @(ServerLinkUploadProfilePicture): @[@(ServerRequestPathProfilePicture)],
                                @(ServerLinkEventsList): @[@(ServerRequestPathEventsList)],
                                @(ServerLinkEventDetails): @[@(ServerRequestPathEventDetails)],
                                @(ServerLinkEventCancel): @[@(ServerRequestPathEventCancel)],
                                @(ServerLinkTrainersList): @[@(ServerRequestPathTrainersList)],
                                @(ServerLinkMyClasses): @[@(ServerRequestPathMyClasses)],
                                @(ServerLinkCardSaveCard): @[@(ServerRequestPathCardSaveCard)],
                                @(ServerLinkCardUseCard): @[@(ServerRequestPathCardUseCard)],
                                @(ServerLinkEventSaveRating): @[@(ServerRequestPathEventSaveRating)],
                                @(ServerLinkPromosList): @[@(ServerRequestPathPromosList)]
                                };

		sRequestPathParams = @{};

		sMethodStrings = @{ @(ServerRequestMethodGet): @"GET",
			                @(ServerRequestMethodPut): @"PUT",
			                @(ServerRequestMethodPost): @"POST",
			                @(ServerRequestMethodDelete): @"DELETE" };

		sPathStrings = @{ @(ServerRequestPathRegister): @"%@/registration/",
                          @(ServerRequestPathLogin): @"%@/login",
                          @(ServerRequestPathGetProfile): @"%@/profile",
                          @(ServerRequestPathSaveProfile): @"%@/profile/edit",
                          @(ServerRequestPathChangePassword): @"%@/profile/changepass",
                          @(ServerRequestPathProfilePicture): @"%@/profile/photoup",
                          @(ServerRequestPathEventsList): @"%@/event",
                          @(ServerRequestPathEventDetails): @"%@/event/detail",
                          @(ServerRequestPathEventCancel): @"%@/event/cancel",
                          @(ServerRequestPathTrainersList): @"%@/event/trainers",
                          @(ServerRequestPathMyClasses): @"%@/event/myclasses",
                          @(ServerRequestPathCardSaveCard): @"%@/card/savecard",
                          @(ServerRequestPathCardUseCard): @"%@/card/usecard",
                          @(ServerRequestPathEventSaveRating) : @"%@/event/saverating",
                          @(ServerRequestPathPromosList) : @"%@/event/promo"
                          };
	}
    
	NSMutableDictionary *localUpdateDict = [dictionary mutableCopy];
    if (_sessionKey)
    {
        [localUpdateDict setObject:_sessionKey forKey:@"sessionKey"];
    }
    
	NSArray *requestData = [sRequestDictionary objectForKey:@(serverLink)];
	ServerRequestPath requestPath = (ServerRequestPath)[[requestData objectAtIndex:0] integerValue];
	ServerRequestMethod requestMethod = ServerRequestMethodPost;
	NSString *requestPathString = [NSString stringWithFormat:[sPathStrings objectForKey:@(requestPath)], [NetworkManager baseApiUrl]];
    
	if ([sRequestPathParams objectForKey:@(requestPath)]) {
		NSArray *additionalPathParams = [sRequestPathParams objectForKey:@(requestPath)];
		for (NSString *additionalPathKey in additionalPathParams) {
			id pathKeyValue = [localUpdateDict objectForKey:additionalPathKey];
            if ([pathKeyValue isKindOfClass:[NSNumber class]]) {
				pathKeyValue = [NSString stringWithFormat:@"%ld", (long)[pathKeyValue integerValue]];
			}
			ASSERT(pathKeyValue); // we need to make sure everything passed correctly
			NSString *replacedPathKey = [NSString stringWithFormat:@"{%@}", additionalPathKey];
			requestPathString = [requestPathString stringByReplacingOccurrencesOfString:replacedPathKey withString:pathKeyValue];
			//[localUpdateDict removeObjectForKey:additionalPathKey];
		}
	}

	NSData *httpBodyData = [NSJSONSerialization dataWithJSONObject:localUpdateDict options:0 error:nil];
	NSMutableURLRequest *resultRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestPathString]];

	if (requestMethod) {
		[resultRequest setHTTPMethod:[sMethodStrings objectForKey:@(requestMethod)]];
	}

	if (httpBodyData) {
		[resultRequest setHTTPBody:httpBodyData];
	}

	return resultRequest;
}

- (void)removeRequest:(ServerRequest *)request
{
	[_activeRequests removeObject:request];
}

- (void)preprocessResponse:(id)responseDictionary forLink:(ServerLink)link error:(NSError *__autoreleasing *)error
{
    if (!*error)
    {
        if ((link == ServerLinkLogin) || (link == ServerLinkRegister))
        {
            _sessionKey = [responseDictionary isKindOfClass:[NSDictionary class]] ? responseDictionary[@"sessionKey"] : nil;
        }
    }
}

@end
