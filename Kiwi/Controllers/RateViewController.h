//
//  RateViewController.h
//  Kiwi
//
//  Created by Crackman on 10.07.14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Event;

@interface RateViewController : UIViewController<UITextViewDelegate>

-(void)setEvent:(Event*)event;

@end
