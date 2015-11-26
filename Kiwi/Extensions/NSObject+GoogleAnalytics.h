//
//  NSObject+GoogleAnalytics.h
//  Kiwi
//
//  Created by Anton Kryvenko on 31.08.14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

extern NSString * const GaiOpenApp;             // DONE
extern NSString * const GaiIntro;               // DONE

extern NSString * const GaiTwitterLogin;        // DONE
extern NSString * const GaiFacebookLogin;       // DONE
extern NSString * const GaiLogin;               // DONE
extern NSString * const GaiRegistration;        // DONE

extern NSString * const GaiPromo;               // DONE
extern NSString * const GaiRateTrainer;         // DONE

extern NSString * const GaiMapListSwap;         // DONE

extern NSString * const GaiFilterCategory;      // DONE
extern NSString * const GaiFilterTrainer;       // DONE
extern NSString * const GaiFilterTime;          // DONE
extern NSString * const GaiRightHereRightNow;   // DONE

extern NSString * const GaiClassSummary;        // DONE
extern NSString * const GaiClassDetails;        // DONE
extern NSString * const GaiTrainerDetails;      // DONE
extern NSString * const GaiClassBooking;        // DONE
extern NSString * const GaiBookingCancel;       // DONE

extern NSString * const GaiMyProfile;           // DONE
extern NSString * const GaiMyClasses;           // DONE
extern NSString * const GaiMyPayments;          // DONE
extern NSString * const GaiSignOut;             // DONE

@interface NSObject (GoogleAnalytics)

-(void)gaiScreen:(NSString*)screenName;

@end
