//
//  UIActionSheet+BlockActions.h
//  PLSLibrary
//
//  Created by Georgiy Kassabli on 9/8/13.
//  Copyright (c) 2013 Playsoft Agency. All rights reserved.
//

@interface UIActionSheet (BlockActions)

// Methods with short signature use action sheet without destructive button and cancel button title NSLocalizedString(@"Cancel", @"")
+ (UIActionSheet *)actionSheetWithTitle:(NSString *)title message:(NSString *)message buttons:(NSArray *)buttonTitles onDismiss:(void (^)(NSInteger buttonIndex))dismissed onCancel:(void (^)())cancelled;
+ (UIActionSheet *)actionSheetWithTitle:(NSString *)title message:(NSString *)message destructiveButtonTitle:(NSString *)destructiveTitle cancelButtonTitle:(NSString *)cancelTitle buttons:(NSArray *)buttonTitles onDismiss:(void (^)(NSInteger buttonIndex))dismissed onCancel:(void (^)())cancelled;

+ (void)showActionSheetInView:(UIView *)view title:(NSString *)title message:(NSString *)message buttons:(NSArray *)buttonTitles onDismiss:(void (^)(NSInteger buttonIndex))dismissed onCancel:(void (^)())cancelled;
+ (void)showActionSheetInView:(UIView *)view title:(NSString *)title message:(NSString *)message destructiveButtonTitle:(NSString *)destructiveTitle cancelButtonTitle:(NSString *)cancelTitle buttons:(NSArray *)buttonTitles onDismiss:(void (^)(NSInteger buttonIndex))dismissed onCancel:(void (^)())cancelled;

@end
