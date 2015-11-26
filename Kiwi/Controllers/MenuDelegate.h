//
//  MenuDelegate.h
//  Kiwi
//
//  Created by Crackman on 18.05.14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MenuDelegate <NSObject>

-(void)goToProfile;
-(void)goToPayments;
-(void)goToClasses;
-(void)signOut;
-(void)hideMenu;

@end
