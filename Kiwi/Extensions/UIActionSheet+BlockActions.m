//
//  UIActionSheet+BlockActions.h
//  PLSLibrary
//
//  Created by Georgiy Kassabli on 9/8/13.
//  Copyright (c) 2013 Playsoft Agency. All rights reserved.
//

#import "UIActionSheet+BlockActions.h"

#import <objc/runtime.h>

static char DELEGATE_IDENTIFER;

@interface PLSActionSheetBlockDelegate : NSObject <UIActionSheetDelegate>
{
    void (^_dismissBlock)(NSInteger);
    void (^_cancelBlock)();
}

+ (instancetype)delegateWithDismissBlock:(void (^)(NSInteger))dismissBlock cancelBlock:(void (^)())cancelBlock;

@end

@implementation PLSActionSheetBlockDelegate

+ (instancetype)delegateWithDismissBlock:(void (^)(NSInteger))dismissBlock cancelBlock:(void (^)())cancelBlock
{
    PLSActionSheetBlockDelegate *delegate = [self new];
    delegate->_dismissBlock = dismissBlock;
    delegate->_cancelBlock = cancelBlock;
    
    return delegate;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == [actionSheet cancelButtonIndex]) {
        if (_cancelBlock) {
            _cancelBlock();
        }
    } else if (_dismissBlock) {
        if (buttonIndex > actionSheet.cancelButtonIndex) {
            buttonIndex--;
        }
        _dismissBlock(buttonIndex);
    }
}

@end

@implementation UIActionSheet (BlockActions)

+ (UIActionSheet *)actionSheetWithTitle:(NSString *)title message:(NSString *)message buttons:(NSArray *)buttonTitles onDismiss:(void (^)(NSInteger))dismissed onCancel:(void (^)())cancelled
{
    return [self actionSheetWithTitle:title message:message destructiveButtonTitle:nil cancelButtonTitle:NSLocalizedString(@"Cancel", @"") buttons:buttonTitles onDismiss:dismissed onCancel:cancelled];
}

+ (UIActionSheet *)actionSheetWithTitle:(NSString *)title message:(NSString *)message destructiveButtonTitle:(NSString *)destructiveTitle cancelButtonTitle:(NSString *)cancelTitle buttons:(NSArray *)buttonTitles onDismiss:(void (^)(NSInteger))dismissed onCancel:(void (^)())cancelled
{
    PLSActionSheetBlockDelegate *internalDelegate = [PLSActionSheetBlockDelegate delegateWithDismissBlock:dismissed cancelBlock:cancelled];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:internalDelegate cancelButtonTitle:nil destructiveButtonTitle:destructiveTitle otherButtonTitles:nil];
    for (NSString *buttonName in buttonTitles) {
        [actionSheet addButtonWithTitle:buttonName];
    }
    [actionSheet addButtonWithTitle:cancelTitle];
    actionSheet.cancelButtonIndex = buttonTitles.count;
    objc_setAssociatedObject(self, &DELEGATE_IDENTIFER, internalDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC); // make sure internal delegate isn't destroyed while alert is alive
    
    return actionSheet;
}

+ (void)showActionSheetInView:(UIView *)view title:(NSString *)title message:(NSString *)message buttons:(NSArray *)buttonTitles onDismiss:(void (^)(NSInteger))dismissed onCancel:(void (^)())cancelled
{
    [self showActionSheetInView:view title:title message:message destructiveButtonTitle:nil cancelButtonTitle:NSLocalizedString(@"Cancel", @"") buttons:buttonTitles onDismiss:dismissed onCancel:cancelled];
}

+ (void)showActionSheetInView:(UIView *)view title:(NSString *)title message:(NSString *)message destructiveButtonTitle:(NSString *)destructiveTitle cancelButtonTitle:(NSString *)cancelTitle buttons:(NSArray *)buttonTitles onDismiss:(void (^)(NSInteger))dismissed onCancel:(void (^)())cancelled
{
    UIActionSheet *actionSheet = [self actionSheetWithTitle:title message:message destructiveButtonTitle:destructiveTitle cancelButtonTitle:cancelTitle buttons:buttonTitles onDismiss:dismissed onCancel:cancelled];
    if ([view isKindOfClass:[UITabBar class]]) {
        [actionSheet showFromTabBar:(UITabBar *)view];
    } else if ([view isKindOfClass:[UIBarButtonItem class]]) {
        [actionSheet showFromBarButtonItem:(UIBarButtonItem *)view animated:YES];
    } else if ([view isKindOfClass:[UIView class]]) {
        [actionSheet showInView:view];
    }
}

@end
