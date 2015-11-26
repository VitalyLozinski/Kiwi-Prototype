//
//  ErrorDisplayController.m
//  Kiwi
//
//  Created by Georgiy on 5/27/14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

#import "ErrorDisplayController.h"

#import "UIColor+AppColors.h"

@implementation ErrorDisplayController

+ (instancetype)sharedController
{
    static ErrorDisplayController *sSharedController;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sSharedController = [ErrorDisplayController new];
    });
    return sSharedController;
}

- (void)displayError:(NSError *)error
{
    [self displayErrorText:error.localizedDescription];
}

- (void)displayErrorText:(NSString *)errorText
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:errorText delegate:self cancelButtonTitle:InterfaceString(@"Ok") otherButtonTitles:nil];
    alertView.tintColor = [UIColor lightGreenColor];
    [alertView show];
}

#pragma mark - UIAlertViewDelegate

@end
