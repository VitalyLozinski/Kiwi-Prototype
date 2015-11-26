//
//  SocialController.m
//  Kiwi
//
//  Created by Georgiy on 5/14/14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

#import "SocialController.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "OAuthCore.h"
#import <FacebookSDK.h>
#import <STTwitter/STTwitter.h>

#import "User.h"

@implementation SocialController
{
    NSOperationQueue *_operationQueue;
    FBSession *_loginSession;
}

+ (NSString *)stringByDecodingURLFormat:(NSString*)str
{
    if (!str || ![str isKindOfClass:[NSString class]])
        return nil;
    
    NSString *result = [str stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    result = [result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return result;
}

+ (instancetype)sharedController
{
    static SocialController *sSharedController;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sSharedController = [SocialController new];
    });
    return sSharedController;
}

- (instancetype)init
{
    if (self = [super init]) {
        [FBSession.activeSession setStateChangeHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            [self sessionStateChanged:session state:status error:error];
        }];
        if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
            [self startFacebookLogin:YES];
        }
    }
    return self;
}

#pragma mark - public methods

- (void)startFacebookLogin
{
    [self startFacebookLogin:NO];
}

- (void)startFacebookLogin:(BOOL)internal
{
    NSArray *permisssions = @[@"email"];
    if (internal) {
        [FBSession openActiveSessionWithReadPermissions:permisssions allowLoginUI:NO completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            [self sessionStateChanged:session state:status error:error];
        }];
    } else {
        _loginSession = [[FBSession alloc] initWithPermissions:permisssions];
        [_loginSession openWithBehavior:FBSessionLoginBehaviorUseSystemAccountIfPresent completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            [FBSession setActiveSession:_loginSession];
            [self sessionStateChanged:session state:status error:error];
        }];
    }
}

- (void)startTwitterLogin
{
    STTwitterAPI * twitterController = [STTwitterAPI twitterAPIOSWithFirstAccount];
    
    [twitterController verifyCredentialsWithSuccessBlock:^(NSString *username)
    {
        [[User currentUser] loginWithTwiUsername:username];
    }
    errorBlock:^(NSError *error)
    {
        NSError *incorrectTwiAccError = [[NSError alloc] initWithDomain:NSUnderlyingErrorKey code:0 userInfo:@{NSLocalizedDescriptionKey: InterfaceString(@"TwitterSetupInstruction")}];
        [[NSNotificationCenter defaultCenter] postNotificationName:UserDidLoginNotification object:[User currentUser] userInfo:@{@"error": incorrectTwiAccError}];
    }];
}

- (BOOL)handleFacebookCallbackUrl:(NSURL *)url sourceApplication:(NSString *)sourceApplication
{
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:_loginSession fallbackHandler:^(FBAppCall *call) {
        [[NSNotificationCenter defaultCenter] postNotificationName:UserDidLoginNotification object:[User currentUser] userInfo:@{@"error": call.error}];
    }];
}

#pragma mark - handle Facebook logged in

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState)state error:(NSError *)error
{
    if (error) {
        NSString *userMsg = [FBErrorUtility userMessageForError:error];
        if (!userMsg) {
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                userMsg = InterfaceString(@"AllowFBAccount");
            } else {
                userMsg = error.localizedDescription;
            }
        }
        error = [NSError errorWithDomain:error.domain code:error.code userInfo:@{NSLocalizedDescriptionKey: userMsg}];
        [[NSNotificationCenter defaultCenter] postNotificationName:UserDidLoginNotification object:[User currentUser] userInfo:@{@"error": error}];
    } else if (state == FBSessionStateOpen) {
        [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                [[User currentUser] loginWithFbToken:session.accessTokenData.accessToken];
            }
        }];
    }
}

@end
