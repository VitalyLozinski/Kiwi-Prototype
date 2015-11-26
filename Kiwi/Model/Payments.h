//
//  Payments.h
//  Kiwi
//
//  Created by Crackman on 05.06.14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

#import "ModelObject.h"

extern NSString * const CardSaveDidFailNotification;
extern NSString * const CardSaveDidFinishNotification;
//extern NSString * const CardUseDidFailNotification;
//extern NSString * const CardUseDidFinishNotification;

@interface Payments : ModelObject

- (void)saveCard:(NSDictionary *)paymentInfo;
//- (void)useCard:(NSDictionary *)paymentInfo;

@end
