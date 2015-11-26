//
//  SocialController.h
//  Kiwi
//
//  Created by Georgiy on 5/14/14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

@interface SocialController : NSObject

+ (instancetype)sharedController;

- (void)startFacebookLogin;
- (void)startTwitterLogin;

- (BOOL)handleFacebookCallbackUrl:(NSURL *)url sourceApplication:(NSString *)sourceApplication;

@end
