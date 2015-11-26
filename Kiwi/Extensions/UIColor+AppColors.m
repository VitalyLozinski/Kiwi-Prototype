//
//  UIColor+AppColors.m
//  Kiwi
//
//  Created by Georgiy on 5/14/14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

#import "UIColor+AppColors.h"

@implementation UIColor (AppColors)

+ (UIColor *)lightGreenColor
{
    return [UIColor colorWithRed:173.0 / 255.0 green:199.0 / 255.0 blue:11.0 / 255.0 alpha:1.0];
}

+ (UIColor *)transparentWhiteColor
{
    return [UIColor colorWithRed:255 / 255.0 green:255.0 / 255.0 blue:255.0 / 255.0 alpha:0.0];
}

+ (UIColor *)appGreenColor
{
    return [UIColor colorWithRed:128.0 / 255.0 green:168.0 / 255.0 blue:13.0 / 255.0 alpha:1.0];
}

+ (UIColor *)redButtonColor
{
    return [UIColor colorWithRed:208.0 / 255.0 green:88.0 / 255.0 blue:43.0 / 255.0 alpha:1.0];
}

+ (UIColor *)grayMenuItemColor
{
    return [UIColor colorWithRed:100 / 255.0 green:100 / 255.0 blue:100 / 255.0 alpha:1.0];
}

+ (UIColor *)blueMenuItemColor
{
    return [UIColor colorWithRed:0 / 255.0 green:200 / 255.0 blue:255 / 255.0 alpha:1.0];
}

+ (UIColor *)orangeInstructorColor
{
    return [UIColor colorWithRed:255 / 255.0 green:200 / 255.0 blue:150 / 255.0 alpha:0.5];
}


@end
