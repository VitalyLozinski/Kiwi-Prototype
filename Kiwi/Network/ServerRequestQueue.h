//
//  ServerRequestQueue.h
//  Kiwi
//
//  Created by Georgiy on 5/10/14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//
//  Singleton class that handles server request construction. Also can handle utility functions like stubs for specific request of offline reques handling

#import "ServerRequest.h"

typedef enum {
	ServerLinkNone,
    ServerLinkRegister,
    ServerLinkLogin,
    ServerLinkGetProfile,
    ServerLinkSaveProfile,
    ServerLinkChangePassword,
    ServerLinkUploadProfilePicture,
    ServerLinkSearch,
    ServerLinkEventsList,
    ServerLinkEventDetails,
    ServerLinkEventCancel,
    ServerLinkTrainersList,
    ServerLinkMyClasses,
    ServerLinkCardSaveCard,
    ServerLinkCardUseCard,
    ServerLinkEventSaveRating,
    ServerLinkPromosList,
} ServerLink;

@interface ServerRequestQueue : NSObject

+ (instancetype)defaultQueue;

- (ServerRequest *)addServerRequestForLink:(ServerLink)link withBodyDict:(NSDictionary *)updateDict completionHandler:(void (^)(id result, NSError *error))completionHandler;

@end

@interface ServerRequest (QueueExtension)

- (void)cancel;

@end
