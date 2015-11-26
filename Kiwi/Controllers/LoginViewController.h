//
//  LoginViewController.h
//  Kiwi
//
//  Created by Georgiy on 5/10/14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

@interface LoginViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UILabel *titleLbl;
@property (nonatomic, strong) IBOutlet UILabel *orLbl;
@property (nonatomic, strong) IBOutlet UITextField *emailField;
@property (nonatomic, strong) IBOutlet UITextField *passField;
@property (nonatomic, strong) IBOutlet UIButton *facebookBtn;
@property (nonatomic, strong) IBOutlet UIButton *twitterBtn;
//@property (nonatomic, strong) IBOutlet UIButton *forgotBtn;
@property (nonatomic, strong) IBOutlet UIButton *registerBtn;
@property (nonatomic, strong) IBOutlet UIButton *loginBtn;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityView;

@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordBtn;


- (IBAction)socialLogin:(id)sender;
- (IBAction)login:(id)sender;
- (IBAction)register:(id)sender;

@end
