//
//  MenuViewController.h
//  Kiwi
//
//  Created by Crackman on 18.05.14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

#import "MenuDelegate.h"

@interface MenuViewController : UIViewController

@property (nonatomic, strong) IBOutlet id<MenuDelegate> delegate;

- (void)setMenuOpen:(BOOL)open animated:(BOOL)animated;

@end
