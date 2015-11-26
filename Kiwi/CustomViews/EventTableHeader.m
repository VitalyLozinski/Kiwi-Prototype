//
//  EventTableHeader.m
//  Kiwi
//
//  Created by Georgiy on 5/18/14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

#import "EventTableHeader.h"

#import "UIFont+AppFonts.h"

@implementation EventTableHeader

- (void)awakeFromNib
{
    self.titleLbl.font = [UIFont boldAppFontOfSize:15];
}

@end
