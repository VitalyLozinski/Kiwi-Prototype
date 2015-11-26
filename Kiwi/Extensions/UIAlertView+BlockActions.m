//
//  UIAlertView+BlockActions.m
//  PLSLibrary
//
//  Created by Georgiy Kassabli on 9/8/13.
//  Copyright (c) 2013 Playsoft Agency. All rights reserved.
//

#import "UIAlertView+BlockActions.h"

#import <objc/runtime.h>

typedef void (^DismissBlock)(NSInteger buttonIndex);
typedef void (^CancelBlock)();

static char DELEGATE_IDENTIFER;

@interface PLSAlertViewBlockDelegate : NSObject <UIAlertViewDelegate>
{
    DismissBlock _dismissBlock;
    CancelBlock _cancelBlock;
}

+ (instancetype)delegateWithDismissBlock:(DismissBlock)dismissBlock cancelBlock:(CancelBlock)cancelBlock;

@end

@implementation PLSAlertViewBlockDelegate

+ (instancetype)delegateWithDismissBlock:(DismissBlock)dismissBlock cancelBlock:(CancelBlock)cancelBlock
{
    PLSAlertViewBlockDelegate *delegate = [self new];
    delegate->_dismissBlock = dismissBlock;
    delegate->_cancelBlock = cancelBlock;
    
    return delegate;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex) {
        if (_cancelBlock) {
            _cancelBlock();
        }
    } else if (_dismissBlock) {
        if (buttonIndex > alertView.cancelButtonIndex) {
            buttonIndex--;
        }
        _dismissBlock(buttonIndex);
    }
}

@end

@implementation UIAlertView (BlockActions)

+ (UIAlertView *)alertViewWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtons onDismiss:(void (^)(NSInteger))dismissed onCancel:(void (^)(void))cancelled
{
    PLSAlertViewBlockDelegate *internalDelegate = [PLSAlertViewBlockDelegate delegateWithDismissBlock:dismissed cancelBlock:cancelled];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:internalDelegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
    objc_setAssociatedObject(alert, &DELEGATE_IDENTIFER, internalDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC); // make sure internal delegate isn't destroyed while alert is alive
    
    for (NSString *buttonTitle in otherButtons) {
        [alert addButtonWithTitle:buttonTitle];
    }
    
    return alert;
}

+ (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtons onDismiss:(void (^)(NSInteger))dismissed onCancel:(void (^)(void))cancelled
{
    UIAlertView *alert = [self alertViewWithTitle:title message:message cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtons onDismiss:dismissed onCancel:cancelled];
    [alert show];
}

@end
