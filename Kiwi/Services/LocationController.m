//
//  LocationController.m
//  Kiwi
//
//  Created by Georgiy on 5/10/14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

#import "LocationController.h"

NSString * const LocationDidUpdateNotification = @"LocationDidUpdateNotification";

#define kDefaultTimeoutInterval 20.0

@implementation LocationController {
    CLLocationManager *_locationManager;
    NSTimer *_timeoutTimer;
    BOOL _activeMonitoring;
    NSDate *_lastActiveTimestamp;
}

+ (instancetype)sharedController
{
    static LocationController *sSharedController;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sSharedController = [LocationController new];
    });
    return sSharedController;
}

- (instancetype)init
{
    if (self = [super init]) {
        _locationManager = [CLLocationManager new];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)startLocationTracking
{
    [_timeoutTimer invalidate];
    _timeoutTimer = nil;
    _timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:kDefaultTimeoutInterval target:self selector:@selector(timerFired) userInfo:nil repeats:NO];
    _timeoutTimer.tolerance = kDefaultTimeoutInterval / 5;
    _activeMonitoring = YES;
    if ([[[[UIDevice currentDevice] systemVersion] substringToIndex:1] intValue] >= 8)
    {
        [_locationManager requestWhenInUseAuthorization];
        _locationManager.pausesLocationUpdatesAutomatically = NO;
    }

    [_locationManager startUpdatingLocation];
}

#pragma mark - private methods

- (void)timerFired
{
    _timeoutTimer = nil;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if (_activeMonitoring) {
        CLLocation *location = [locations firstObject];
        if (!_userLocation || location.horizontalAccuracy < _userLocation.horizontalAccuracy) {
            _userLocation = location;
            [[NSNotificationCenter defaultCenter] postNotificationName:LocationDidUpdateNotification object:self];
        }
        if (_userLocation.horizontalAccuracy < kCLLocationAccuracyNearestTenMeters || ![_timeoutTimer isValid]) {
            _activeMonitoring = NO;
            _lastActiveTimestamp = [NSDate date];
            [_locationManager stopUpdatingLocation];
            [_locationManager startMonitoringSignificantLocationChanges];
        }
    } else {
        // if we receive significant location changes we need to check if it isn't old data
        CLLocation *newLocation = [locations firstObject];
        if ([newLocation.timestamp compare:_lastActiveTimestamp] == NSOrderedDescending) {
            _userLocation = [locations firstObject];
            [self startLocationTracking];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:LocationDidUpdateNotification object:self userInfo:@{@"error": error}];
}

@end
