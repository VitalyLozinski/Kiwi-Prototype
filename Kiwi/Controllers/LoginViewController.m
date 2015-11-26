//
//  LoginViewController.m
//  Kiwi
//
//  Created by Georgiy on 5/10/14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

#import "LoginViewController.h"
#import "TermsViewController.h"
#import "InfoViewController.h"
#import "NetworkManager.h"

#import "UIFont+AppFonts.h"
#import "UIColor+AppColors.h"
#import "UIImage+App.h"
#import "NSString+Utilities.h"

#import "ErrorDisplayController.h"
#import "SocialController.h"
#import "User.h"
#import "NSObject+GoogleAnalytics.h"

extern NSString * TacAcceptedKey;
extern NSString * IntroPlayedKey;

NSString * const EmailKey = @"LoginEmail";

const BOOL SkipTac = NO;

@implementation LoginViewController
{
    NSOperationQueue *operationQueue;
    BOOL _introPlayed;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.titleLbl.text = InterfaceString(@"LoginTitle");
    self.orLbl.text = InterfaceString(@"Or");
    self.titleLbl.font = [UIFont regularAppFontOfSize:28];
    self.orLbl.font = [UIFont regularAppFontOfSize:14];
    
    [self restoreEmail];
    
//    [self.forgotBtn setTitle:InterfaceString(@"ForgotPassText") forState:UIControlStateNormal];
    [self.registerBtn setBackgroundImage:[UIImage imageWithColor:[UIColor appGreenColor]] forState:UIControlStateNormal];
    [self.loginBtn setBackgroundImage:[UIImage imageWithColor:[UIColor appGreenColor]] forState:UIControlStateNormal];
    [self.registerBtn setBackgroundImage:[UIImage imageWithColor:[UIColor appGreenColor]] forState:UIControlStateDisabled];
    [self.loginBtn setBackgroundImage:[UIImage imageWithColor:[UIColor appGreenColor]] forState:UIControlStateDisabled];
    [self.registerBtn setBackgroundImage:[UIImage imageWithColor:[UIColor lightGreenColor]] forState:UIControlStateHighlighted];
    [self.loginBtn setBackgroundImage:[UIImage imageWithColor:[UIColor lightGreenColor]] forState:UIControlStateHighlighted];
    [self.registerBtn setTitle:InterfaceString(@"Register") forState:UIControlStateNormal];
    [self.loginBtn setTitle:InterfaceString(@"Signin") forState:UIControlStateNormal];
//    self.forgotBtn.titleLabel.font = [UIFont regularAppFontOfSize:12];
    self.registerBtn.titleLabel.font = [UIFont regularAppFontOfSize:14];
    self.loginBtn.titleLabel.font = [UIFont regularAppFontOfSize:14];
    
    self.emailField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.passField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.emailField.layer.borderWidth = 1.0;
    self.passField.layer.borderWidth = 1.0;
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, self.emailField.frame.size.height)];
    self.emailField.leftView = paddingView;
    self.emailField.leftViewMode = UITextFieldViewModeAlways;
    UIView *paddingView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, self.passField.frame.size.height)];
    self.passField.leftView = paddingView2;
    self.passField.leftViewMode = UITextFieldViewModeAlways;
    
    self.forgotPasswordBtn.titleLabel.font = [UIFont regularAppFontOfSize:14];
    [self.forgotPasswordBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.forgotPasswordBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    [self.forgotPasswordBtn setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    [self.forgotPasswordBtn setTitle:InterfaceString(@"ForgotPassword") forState:UIControlStateNormal];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogin:) name:UserDidLoginNotification object:[User currentUser]];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self unlockControls];
    
    if (!_introPlayed)
    {
        _introPlayed = YES;
        NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
        if ([prefs integerForKey:IntroPlayedKey] == 0)
        {
            [self presentViewController:[InfoViewController new] animated:NO completion:nil];
        }
    }
}

- (IBAction)forgotPasswordTapped:(id)sender
{
    NSString * url = [NSString stringWithFormat:@"%@/trainer/userpassword", [NetworkManager baseResourceUrl]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark - action processing

- (void)prestartLogin:(void (^)(void))action
{
    void (^loginAction)() = ^(){
        [self.activityView startAnimating];
        self.facebookBtn.enabled = NO;
        self.twitterBtn.enabled = NO;
        self.registerBtn.enabled = NO;
        self.loginBtn.enabled = NO;
        action();
    };
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    if (SkipTac || [prefs integerForKey:TacAcceptedKey] != 0)
    {
        loginAction();
    }
    else
    {
        TermsViewController *termsController = [TermsViewController new];
        termsController.acceptBlock = loginAction;
        [self presentViewController:termsController animated:YES completion:nil];
    }
}

- (IBAction)socialLogin:(id)sender
{
    [self prestartLogin:^
    {
        if (sender == self.facebookBtn)
        {
            [self gaiScreen:GaiFacebookLogin];
            [[SocialController sharedController] startFacebookLogin];
        }
        else if (sender == self.twitterBtn)
        {
            [self gaiScreen:GaiTwitterLogin];
            [[SocialController sharedController] startTwitterLogin];
        }
    }];
}

-(void)saveEmail
{
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:self.emailField.text forKey:EmailKey];
    [prefs synchronize];
}

-(void)restoreEmail
{
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    NSString * email = [prefs stringForKey:EmailKey];
    if (!email)
        email = @"";
    self.emailField.text = email;
}

- (IBAction)login:(id)sender
{
    [self saveEmail];
    
    [self gaiScreen:GaiLogin];
    [self prestartLogin:^
    {
        [[User currentUser] loginWithEmail:self.emailField.text password:self.passField.text];
    }];
}

- (IBAction)register:(id)sender
{
    if ([self.emailField.text isValidEmail])
    {
        [self saveEmail];
        [self gaiScreen:GaiRegistration];
        [self prestartLogin:^
        {
            [[User currentUser] registerWithEmail:self.emailField.text password:self.passField.text];
        }];
    }
    else
    {
        [[ErrorDisplayController sharedController] displayErrorText:InterfaceString(@"InvalidEmail")];
    }
}

-(void)unlockControls
{
    [self.activityView stopAnimating];
    self.facebookBtn.enabled = YES;
    self.twitterBtn.enabled = YES;
    self.registerBtn.enabled = YES;
    self.loginBtn.enabled = YES;
}

#pragma mark - notification processing

- (void)userDidLogin:(NSNotification *)ntf
{
    dispatch_async(dispatch_get_main_queue(),
    ^{
        [self unlockControls];
    });
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (textField == self.emailField) {
        [self.passField becomeFirstResponder];
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    textField.layer.borderColor = [UIColor lightGreenColor].CGColor;
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    textField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    return YES;
}

@end
