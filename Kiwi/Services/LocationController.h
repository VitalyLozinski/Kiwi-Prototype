//
//  LocationController.h
//  Kiwi
//
//  Created by Georgiy on 5/10/14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

extern NSString * const LocationDidUpdateNotification;

@interface LocationController : NSObject <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocation *userLocation;

+ (instancetype)sharedController;

- (void)startLocationTracking;

@end
