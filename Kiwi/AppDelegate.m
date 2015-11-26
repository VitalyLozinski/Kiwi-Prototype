//
//  AppDelegate.m
//  Kiwi
//
//  Created by Georgiy on 5/6/14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

#import "AppDelegate.h"

#import "UIFont+AppFonts.h"
#import "UIColor+AppColors.h"

#import "MainNavigationController.h"

#import "LocationController.h"
#import "SocialController.h"

#import <VenmoTouch/VenmoTouch.h>

#import <FacebookSDK.h>

#import <Instabug/Instabug.h>

#import "NSObject+GoogleAnalytics.h"
#import "GAI.h"
#import "GAIFields.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSString * instabugToken = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"InstabugToken"];
    if (instabugToken && instabugToken.length > 0)
    {
        [Instabug startWithToken:instabugToken
                   captureSource:IBGCaptureSourceUIKit
                 invocationEvent:IBGInvocationEventShake];
    }
    
    [[UINavigationBar appearance] setTintColor:[UIColor appGreenColor]];
    [[UINavigationBar appearance] setTitleTextAttributes: @{NSForegroundColorAttributeName:[UIColor appGreenColor],
                                                            NSFontAttributeName: [UIFont regularAppFontOfSize:16.0f]}];
    
    [SocialController sharedController];
    [[LocationController sharedController] startLocationTracking];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    MainNavigationController * main = [MainNavigationController rootInstance];
    self.window.rootViewController = main;
    [self.window makeKeyAndVisible];
    
    [self initGoogleAnalytics];
    [self initVTClient];
    [main goToLogin];
    return YES;
}

-(void)initGoogleAnalytics
{
    NSString * trackingId = [[NSBundle mainBundle]
                             objectForInfoDictionaryKey:@"GoogleTrackingId"];
    if (trackingId && trackingId.length > 0)
    {
        [GAI sharedInstance].trackUncaughtExceptions = YES;
        [GAI sharedInstance].dispatchInterval = 20;
        [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
        id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:trackingId];
        
        NSString * name = [[NSBundle mainBundle]
                           objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey];
        NSString * version = [[NSBundle mainBundle]
                              objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
        
        [tracker set:kGAIAppName value:name];
        [tracker set:kGAIAppVersion value:version];
        
        [self gaiScreen:GaiOpenApp];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBAppCall handleDidBecomeActive];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    MainNavigationController * main = [MainNavigationController rootInstance];
    [main refresh];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// Initialize a VTClient with your correct merchant settings.
- (void) initVTClient
{
    NSString * btEnvironment = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"BrainTreeEnvironment"];
    if (btEnvironment == nil || [btEnvironment isEqualToString:@"sandbox"])
    {
        Trace(@"Using sandbox payments, %@.../%@...",
              [BT_SANDBOX_MERCHANT_ID substringToIndex:3],
              [BT_SANDBOX_CLIENT_SIDE_ENCRYPTION_KEY substringToIndex:20]);
        
        [VTClient
         startWithMerchantID:BT_SANDBOX_MERCHANT_ID
         customerEmail:@"your_customer_email"
         braintreeClientSideEncryptionKey:BT_SANDBOX_CLIENT_SIDE_ENCRYPTION_KEY
         environment:VTEnvironmentSandbox];
    }
    else
    {
        Trace(@"Using production payments, %@.../%@...",
              [BT_PRODUCTION_MERCHANT_ID substringToIndex:3],
              [BT_PRODUCTION_CLIENT_SIDE_ENCRYPTION_KEY substringToIndex:20]);

        [VTClient
         startWithMerchantID:BT_PRODUCTION_MERCHANT_ID
         customerEmail:@"your_customer_email"
         braintreeClientSideEncryptionKey:BT_PRODUCTION_CLIENT_SIDE_ENCRYPTION_KEY
         environment:VTEnvironmentProduction];
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [[SocialController sharedController] handleFacebookCallbackUrl:url sourceApplication:sourceApplication];
}

@end
