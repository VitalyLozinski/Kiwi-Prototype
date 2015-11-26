//
//  Payments.m
//  Kiwi
//
//  Created by Crackman on 05.06.14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

#import "Payments.h"

#import "ServerRequestQueue.h"

NSString * const CardSaveDidFailNotification = @"CardSaveDidFailNotification";
NSString * const CardSaveDidFinishNotification = @"CardSaveDidFinishNotification";
NSString * const CardUseDidFailNotification = @"CardUseDidFailNotification";
NSString * const CardUseDidFinishNotification = @"CardUseDidFinishNotification";

@implementation Payments

+ (instancetype)sharedInstance
{
    static Payments *sInstance = nil;
	static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        sInstance = [Payments new];
    });
	return sInstance;
}

-(void)saveCard:(NSDictionary *)paymentInfo
{
    ServerLink serverLink = ServerLinkCardSaveCard;
    
    [[ServerRequestQueue defaultQueue] addServerRequestForLink:serverLink withBodyDict:paymentInfo completionHandler: ^(id result, NSError *error)
    {
        if (error)
        {
            NSDictionary * userInfo = @{@"error": error};
            [[NSNotificationCenter defaultCenter] postNotificationName:CardSaveDidFailNotification object:self userInfo:userInfo];
        }
        else
        {
            NSDictionary * userInfo = @{};
            [[NSNotificationCenter defaultCenter] postNotificationName:CardSaveDidFinishNotification object:self userInfo:userInfo];
        }
    }];
}

-(void)useCard:(NSDictionary *)paymentInfo
{
    
}

@end
