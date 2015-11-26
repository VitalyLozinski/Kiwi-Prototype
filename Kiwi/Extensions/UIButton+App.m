//
//  UIButton+App.m
//  Kiwi
//
//  Created by Crackman on 26.05.14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

#import "UIButton+App.h"
#import "UIImage+App.h"

@implementation UIButton (App)

-(void)makeTinted
{
    [self setImage:[self.imageView.image tintedWithColor:[self titleColorForState:UIControlStateNormal]]
          forState:UIControlStateNormal];
    
    [self setImage:[self.imageView.image tintedWithColor:[self titleColorForState:UIControlStateHighlighted]]
          forState:UIControlStateHighlighted];
    
    [self setImage:[self.imageView.image tintedWithColor:[self titleColorForState:UIControlStateSelected]]
          forState:UIControlStateSelected];

    self.imageView.tintColor = self.titleLabel.textColor;
}

@end
