//
//  UIView+App.m
//  Kiwi
//
//  Created by Crackman on 31.05.14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

#import "UIView+App.h"

@implementation UIView (App)

-(void)valign:(NSInteger)y
{
    CGRect b = self.bounds;
    CGRect f = self.frame;
    
    b.origin.y = 0;
    f.origin.y = y;
    
    self.bounds = b;
    self.frame = f;
}

-(void)valign:(NSInteger)y height:(NSInteger)height
{
    CGRect b = self.bounds;
    CGRect f = self.frame;
    
    b.origin.y = 0;
    f.origin.y = y;
    f.size.height = height;
    
    self.bounds = b;
    self.frame = f;
}

-(void)halign:(NSInteger)x
{
    CGRect b = self.bounds;
    CGRect f = self.frame;
    
    b.origin.x = 0;
    f.origin.x = x;
    
    self.bounds = b;
    self.frame = f;
}

-(void)halign:(NSInteger)x width:(NSInteger)width
{
    CGRect b = self.bounds;
    CGRect f = self.frame;
    
    b.origin.x = 0;
    f.origin.x = x;
    f.size.width = width;
    
    self.bounds = b;
    self.frame = f;
}

@end
