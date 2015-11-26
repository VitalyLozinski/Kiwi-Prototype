//
//  UserProfileViewContoller.h
//  Kiwi
//
//  Created by Crackman on 18.05.14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

@interface UserProfileViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIButton *saveBtn;
@property (nonatomic, strong) IBOutlet UIButton *userImgBtn;
@property (nonatomic, strong) IBOutlet UILabel *changePassTitleLbl;
@property (nonatomic, strong) IBOutlet UILabel *oldPassTitleLbl;
@property (nonatomic, strong) IBOutlet UILabel *createPassTitleLbl;
@property (nonatomic, strong) IBOutlet UILabel *confirmPassTitleLbl;
@property (nonatomic, strong) IBOutlet UITextField *firstNameTxtField;
@property (nonatomic, strong) IBOutlet UITextField *lastNameTxtField;
@property (nonatomic, strong) IBOutlet UITextField *emailTxtField;
@property (nonatomic, strong) IBOutlet UITextField *oldPassTxtField;
@property (nonatomic, strong) IBOutlet UITextField *createPassTxtField;
@property (nonatomic, strong) IBOutlet UITextField *confirmPassTxtField;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *photoUploadIndicator;

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *scrollViewBottomConstraint;

@property (nonatomic, strong) void (^finishBlock)();

@property (nonatomic, readonly) BOOL hasUnsavedChanges;

- (IBAction)userImgPressed:(id)sender;
- (IBAction)savePressed:(id)sender;

@end
