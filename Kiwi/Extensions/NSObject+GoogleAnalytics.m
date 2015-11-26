//
//  NSObject+GoogleAnalytics.m
//  Kiwi
//
//  Created by Anton Kryvenko on 31.08.14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

#import "NSObject+GoogleAnalytics.h"

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

NSString * const GaiOpenApp = @"OpenApp";
NSString * const GaiIntro = @"Intro";
NSString * const GaiPromo = @"Promo";

NSString * const GaiRegistration = @"Registration";
NSString * const GaiLogin = @"Login";
NSString * const GaiFacebookLogin = @"FacebookLogin";
NSString * const GaiTwitterLogin = @"TwitterLogin";

NSString * const GaiRateTrainer = @"RateTrainer";

NSString * const GaiMapListSwap = @"MapListSwap";

NSString * const GaiFilterCategory = @"FilterCategory";
NSString * const GaiFilterTrainer = @"FilterTrainer";
NSString * const GaiFilterTime = @"FilterTime";
NSString * const GaiRightHereRightNow = @"RightHereRightNow";

NSString * const GaiClassSummary = @"ClassSummary";
NSString * const GaiClassDetails = @"ClassDetails";
NSString * const GaiTrainerDetails = @"TrainerDetails";

NSString * const GaiClassBooking = @"ClassBooking";
NSString * const GaiBookingCancel = @"BookingCancel";

NSString * const GaiMyProfile = @"MyProfile";
NSString * const GaiMyClasses = @"MyClasses";
NSString * const GaiMyPayments = @"MyPayments";
NSString * const GaiSignOut = @"SignOut";

@implementation NSObject (GoogleAnalytics)

-(void)gaiScreen:(NSString*)screenName
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:screenName];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

@end
