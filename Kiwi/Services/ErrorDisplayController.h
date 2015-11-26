//
//  ErrorDisplayController.h
//  Kiwi
//
//  Created by Georgiy on 5/27/14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

@interface ErrorDisplayController : NSObject <UIAlertViewDelegate>

+ (instancetype)sharedController;

- (void)displayError:(NSError *)error;
- (void)displayErrorText:(NSString *)errorText;

@end
