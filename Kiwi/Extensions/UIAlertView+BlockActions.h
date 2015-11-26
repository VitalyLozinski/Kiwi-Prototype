//
//  UIAlertView+BlockActions.h
//  PLSLibrary
//
//  Created by Georgiy Kassabli on 9/8/13.
//  Copyright (c) 2013 Playsoft Agency. All rights reserved.
//

@interface UIAlertView (BlockActions)

+ (UIAlertView *)alertViewWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtons onDismiss:(void (^)(NSInteger buttonIndex))dismissed onCancel:(void (^)(void))cancelled;

+ (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtons onDismiss:(void (^)(NSInteger buttonIndex))dismissed onCancel:(void (^)(void))cancelled;

@end
