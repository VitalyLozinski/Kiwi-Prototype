#import "MapGroupRenderer.h"

@implementation MapGroupRenderer


- (void)fillPath:(CGPathRef)path inContext:(CGContextRef)context
{
    CGRect rect = CGPathGetBoundingBox(path);
    
    CGContextAddPath(context, path);
    CGContextClip(context);
    
    CGFloat gradientLocations[4] = {0.3f, 0.975f, 0.98f, 1.0f};
    CGFloat gradientColors[16] =
    {
        0.64f, 0.82f, 0.30f,  0.0f,
        0.64f, 0.82f, 0.30f,  0.4f,
        0.42f, 0.60f, 0.16f, 0.5f,
        0.42f, 0.60f, 0.16f, 0.5f,
    };
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, gradientColors, gradientLocations, 4);
    
    CGPoint gradientCenter = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    CGFloat gradientRadius = MIN(rect.size.width, rect.size.height) / 2;
    
    CGContextDrawRadialGradient(context, gradient, gradientCenter, 0, gradientCenter, gradientRadius, kCGGradientDrawsAfterEndLocation);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

@end
