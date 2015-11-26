//
//  NSNull+ConcreteValues.h
//  Kiwi
//
//  Created by Georgiy Kassabli on 29/05/2014.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

@interface NSNull (ConcreteValues)

- (NSString *)stringValue;
- (NSInteger)integerValue;
- (CGFloat)floatValue;
- (id)objectForKey:(id)key;

@end
