//
//  TransparentView.m
//  Kiwi
//
//  Created by Crackman on 25.05.14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

#import "TransparentView.h"

@implementation TransparentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    for (UIView * view in [self subviews])
    {
        if (view.userInteractionEnabled &&
            [view pointInside:[self convertPoint:point toView:view]
                    withEvent:event])
        {
            return YES;
        }
    }
    return NO;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
