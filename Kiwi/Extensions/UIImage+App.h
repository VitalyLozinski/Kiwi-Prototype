//
//  UIImage+App.h
//  Kiwi
//
//  Created by Crackman on 01.06.14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (App)

+ (UIImage *)imageWithColor:(UIColor *)color;
- (UIImage *)tintedWithColor:(UIColor *)tintColor;

@end
