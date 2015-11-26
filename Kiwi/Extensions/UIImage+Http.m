//
//  UIImage+Http.m
//  Kiwi
//
//  Created by Georgiy on 6/15/14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

#import "UIImage+Http.h"

@implementation UIImage (Http)

- (NSString *)base64EncodedJpegWithQuality:(CGFloat)quality
{
    return [UIImageJPEGRepresentation(self, quality) base64EncodedStringWithOptions:0];
}

@end
