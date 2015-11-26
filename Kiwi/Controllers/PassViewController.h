//
//  PassViewController.h
//  Kiwi
//
//  Created by Crackman on 01.06.14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PassViewDelegate

-(BOOL)customPassViewDismiss;
  
@end
      

@interface PassViewController : UIViewController

- (void)setImage:(NSInteger)image color:(NSInteger)color;
- (void)setDelegate:(id<PassViewDelegate>)delegate;

@end
