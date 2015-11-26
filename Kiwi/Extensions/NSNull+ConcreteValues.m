//
//  NSNull+ConcreteValues.m
//  Kiwi
//
//  Created by Georgiy Kassabli on 29/05/2014.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

#import "NSNull+ConcreteValues.h"

@implementation NSNull (ConcreteValues)

- (NSString *)stringValue
{
    return nil;
}

- (NSInteger)integerValue
{
    return 0;
}

- (CGFloat)floatValue
{
    return 0.0;
}

- (id)objectForKey:(id)key
{
    return nil;
}

@end
