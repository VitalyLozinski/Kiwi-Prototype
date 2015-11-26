//
//  MainNavigationController.h
//  Kiwi
//
//  Created by Crackman on 17.05.14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

#import "MenuDelegate.h"
#import "PromoViewController.h"

extern NSString * const MenuStateChangedNotification;

@interface MainNavigationController : UINavigationController<MenuDelegate, PromoViewControllerDelegate>

@property (nonatomic, readonly) BOOL menuOpened;

+ (instancetype)rootInstance;

- (void)setMenuOpened:(BOOL)menuOpened animated:(BOOL)animated;

- (void)goToLogin;

- (void)refresh;

@end
