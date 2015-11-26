//
//  UIFont+AppFonts.m
//  Kiwi
//
//  Created by Georgiy on 5/13/14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

#import "UIFont+AppFonts.h"

@implementation UIFont (AppFonts)

/* Font names are:
NeoSansStd-Black
NeoSansStd-Bold
NeoSansStd-BoldItalic
NeoSansStd-Regular
NeoSansStd-Italic
NeoSansStd-BlackItalic
NeoSansStd-MediumItalic
NeoSansStd-UltraItalic
NeoSansStd-LightItalic
NeoSansStd-Medium
NeoSansStd-Light
 */

+ (UIFont *)regularAppFontOfSize:(CGFloat)size
{
    return [UIFont fontWithName:@"NeoSansStd-Light" size:size];
}

+ (UIFont *)boldAppFontOfSize:(CGFloat)size
{
    return [UIFont fontWithName:@"NeoSansStd-Regular" size:size];
}

@end
