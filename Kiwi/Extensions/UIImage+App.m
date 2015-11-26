//
//  UIImage+App.m
//  Kiwi
//
//  Created by Crackman on 01.06.14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

#import "UIImage+App.h"

@implementation UIImage (App)

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)tintedWithColor:(UIColor *)tintColor
{
    UIImage * image = self;
    
    CGSize size = image.size;
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    
    if (rect.size.height < 1 || rect.size.width < 1)
    {
        return image;
    }
    
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    
    // draw alpha-mask
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextDrawImage(context, rect, image.CGImage);
    
    // draw tint color, preserving alpha values of original image
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    [tintColor setFill];
    CGContextFillRect(context, rect);
    
    UIImage *coloredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return coloredImage;
}

@end
