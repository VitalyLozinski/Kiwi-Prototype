//
//  MenuViewController.m
//  Kiwi
//
//  Created by Crackman on 18.05.14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

#import "MenuViewController.h"
#import "User.h"

#import "UIFont+AppFonts.h"
#import "UIButton+App.h"
#import "UIView+App.h"

@interface MenuViewController ()

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *logOutButton;
@property (weak, nonatomic) IBOutlet UIButton *profileButton;
@property (weak, nonatomic) IBOutlet UIButton *paymentsButton;
@property (weak, nonatomic) IBOutlet UIButton *classesButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *myProfileHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *myClassesHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *myPaymentsHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *signOutHeight;

@end

@implementation MenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        CGRect frame = self.view.frame;
        frame.origin.y = 64;
        self.view.frame = frame;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_profileButton makeTinted];
    [_paymentsButton makeTinted];
    [_classesButton makeTinted];
    [_logOutButton makeTinted];
    
    _myProfileHeight.constant = 50;
    _myClassesHeight.constant = 50;
    _myPaymentsHeight.constant = 50;
    _signOutHeight.constant = 50;
    [self.view valign:0 height:200];
    
    _profileButton.titleLabel.font = [UIFont regularAppFontOfSize:18];
    _paymentsButton.titleLabel.font = [UIFont regularAppFontOfSize:18];
    _classesButton.titleLabel.font = [UIFont regularAppFontOfSize:18];
    _logOutButton.titleLabel.font = [UIFont regularAppFontOfSize:18];

    UISwipeGestureRecognizer * closeSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    [closeSwipe setDirection:UISwipeGestureRecognizerDirectionUp];
    [self.view addGestureRecognizer:closeSwipe];
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)swipe
{
    if (swipe.direction == UISwipeGestureRecognizerDirectionUp)
    {
        if (self.delegate)
            [self.delegate hideMenu];
    }
}

- (void)setMenuOpen:(BOOL)open animated:(BOOL)animated
{
    void (^animationBlock)(void) = ^
    {
        [self.contentView valign: open ? 0 : -self.view.bounds.size.height];
    };
    void (^completionBlock)(BOOL) = ^(BOOL finished)
    {
        if (!open) {
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
        }
    };
    if (open) {
        [self.contentView valign:-self.view.bounds.size.height];
    }
    if (animated) {
        [UIView animateWithDuration:0.5f animations:animationBlock completion:completionBlock];
    } else {
        animationBlock();
        completionBlock(YES);
    }
}

- (IBAction)profileButtonClicked:(id)sender
{
    if (self.delegate)
        [self.delegate goToProfile];
}

- (IBAction)paymentsButtonClicked:(id)sender
{
    if (self.delegate)
        [self.delegate goToPayments];
}

- (IBAction)classesButtonClicked:(id)sender
{
    if (self.delegate)
        [self.delegate goToClasses];
}

- (IBAction)logOutButtonClicked:(id)sender
{
    if (self.delegate)
        [self.delegate signOut];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
