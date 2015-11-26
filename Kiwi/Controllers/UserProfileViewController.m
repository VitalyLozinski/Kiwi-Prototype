//
//  UserProfileViewContoller.m
//  Kiwi
//
//  Created by Crackman on 18.05.14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

#import "UserProfileViewController.h"

#import "UIActionSheet+BlockActions.h"
#import "UIColor+AppColors.h"
#import "UIFont+AppFonts.h"

#import "ImageCache.h"
#import "ErrorDisplayController.h"

#import "User.h"
#import "Payments.h"
#import "NSObject+GoogleAnalytics.h"

@implementation UserProfileViewController {
    UIBarButtonItem *_savedRightBtnItem;
    BOOL _needsDetailsSave;
    BOOL _needsPassSave;
    UIImage *_imageToUpload;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = InterfaceString(@"UserProfileTitle");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self gaiScreen:GaiMyProfile];
    
    self.oldPassTitleLbl.font = [UIFont regularAppFontOfSize:12];
    self.createPassTitleLbl.font = [UIFont regularAppFontOfSize:12];
    self.confirmPassTitleLbl.font = [UIFont regularAppFontOfSize:12];
    self.changePassTitleLbl.font = [UIFont regularAppFontOfSize:20];
    self.userImgBtn.titleLabel.numberOfLines = 2;
    self.userImgBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.saveBtn.backgroundColor = [UIColor appGreenColor];
    
    self.firstNameTxtField.placeholder = InterfaceString(@"FirstName");
    self.lastNameTxtField.placeholder = InterfaceString(@"LastName");
    self.emailTxtField.placeholder = InterfaceString(@"Email");
    self.changePassTitleLbl.text = InterfaceString(@"ChangePass");
    self.oldPassTitleLbl.text = InterfaceString(@"OldPass");
    self.createPassTitleLbl.text = InterfaceString(@"NewPass");
    self.confirmPassTitleLbl.text = InterfaceString(@"ConfirmPass");
    [self.userImgBtn setTitle:InterfaceString(@"UploadPhoto") forState:UIControlStateNormal];
    [self.saveBtn setTitle:InterfaceString(@"Save") forState:UIControlStateNormal];
    
    self.firstNameTxtField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 10)];
    self.firstNameTxtField.leftViewMode = UITextFieldViewModeAlways;
    self.firstNameTxtField.layer.borderWidth = 1;
    self.firstNameTxtField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.lastNameTxtField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 10)];
    self.lastNameTxtField.leftViewMode = UITextFieldViewModeAlways;
    self.lastNameTxtField.layer.borderWidth = 1;
    self.lastNameTxtField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.emailTxtField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 10)];
    self.emailTxtField.leftViewMode = UITextFieldViewModeAlways;
    self.emailTxtField.layer.borderWidth = 1;
    self.emailTxtField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.oldPassTxtField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 10)];
    self.oldPassTxtField.leftViewMode = UITextFieldViewModeAlways;
    self.oldPassTxtField.layer.borderWidth = 1;
    self.oldPassTxtField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.createPassTxtField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 10)];
    self.createPassTxtField.leftViewMode = UITextFieldViewModeAlways;
    self.createPassTxtField.layer.borderWidth = 1;
    self.createPassTxtField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.confirmPassTxtField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 10)];
    self.confirmPassTxtField.leftViewMode = UITextFieldViewModeAlways;
    self.confirmPassTxtField.layer.borderWidth = 1;
    self.confirmPassTxtField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userInfoUpdated:) name:UserDidUpdateNotification object:[User currentUser]];
    [self userInfoUpdated:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChanged:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - public methods

- (BOOL)hasUnsavedChanges
{
    return _needsDetailsSave || _needsPassSave || (_imageToUpload != nil);
}

#pragma mark - action processing

- (IBAction)userImgPressed:(id)sender
{
    BOOL _cameraAvailable = NO;
    NSMutableArray *availableMedias = [NSMutableArray new];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [availableMedias addObject:InterfaceString(@"TakePhoto")];
        _cameraAvailable = YES;
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [availableMedias addObject:InterfaceString(@"PickPhoto")];
    }
    [UIActionSheet showActionSheetInView:self.view title:nil message:nil buttons:availableMedias onDismiss:^(NSInteger buttonIndex) {
        UIImagePickerController *imagePickerController = [UIImagePickerController new];
        imagePickerController.delegate = self;
        if (buttonIndex == 0 && _cameraAvailable) {
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        [self presentViewController:imagePickerController animated:YES completion:^{}];
        UIDevice *currentDevice = [UIDevice currentDevice];
        while ([currentDevice isGeneratingDeviceOrientationNotifications]){
            [currentDevice endGeneratingDeviceOrientationNotifications];
        }
    } onCancel:^{}];
}

- (IBAction)savePressed:(id)sender
{
    if (_imageToUpload) {
        [[User currentUser] uploadPhoto:_imageToUpload];
        _imageToUpload = nil;
    }
    if (_needsPassSave || _needsDetailsSave) {
        if (![self.oldPassTxtField.text length]) {
            [[ErrorDisplayController sharedController] displayErrorText:InterfaceString(@"SavePassNeeded")];
            return;
        }
        if (![self.createPassTxtField.text isEqual:self.confirmPassTxtField.text]) {
            [[ErrorDisplayController sharedController] displayErrorText:InterfaceString(@"PassNotMatching")];
            return;
        }
        
        self.view.userInteractionEnabled = NO;
        _savedRightBtnItem = self.navigationItem.rightBarButtonItem;
        UIActivityIndicatorView * activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [activityIndicator startAnimating];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
        
        if (_needsDetailsSave) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userInfoSaved:) name:UserDidSaveDetailsNotification object:[User currentUser]];
            [[User currentUser] setEmail:self.emailTxtField.text name:self.firstNameTxtField.text lastName:self.lastNameTxtField.text password:self.oldPassTxtField.text];
        }
        if (_needsPassSave) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userInfoSaved:) name:UserDidSavePassNotification object:[User currentUser]];
            [[User currentUser] changePassword:self.oldPassTxtField.text newPassword:self.createPassTxtField.text];
        }
    } else if (_finishBlock) {
        _finishBlock();
    }
}

#pragma mark - notification processing

- (void)userInfoUpdated:(NSNotification *)ntf
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.firstNameTxtField.text = [User currentUser].userName;
        self.lastNameTxtField.text = [User currentUser].lastName;
        self.emailTxtField.text = [User currentUser].email;
        NSString *photoUrl = [[User currentUser].userPicUrl fullUrlPath];
        Trace(@"Loading profile photo from %@", photoUrl);
        [self.userImgBtn setTitle:InterfaceString(@"UploadPhoto") forState:UIControlStateNormal];
        if ([User currentUser].pictureIsUploading) {
            [self.userImgBtn setTitle:nil forState:UIControlStateNormal];
            [self.photoUploadIndicator startAnimating];
        } else if ([photoUrl length] > 0) {
            if (![self.userImgBtn imageForState:UIControlStateNormal]) {
                [self.userImgBtn setTitle:nil forState:UIControlStateNormal];
                [self.photoUploadIndicator startAnimating];
            }
            [[ImageCache sharedCache] getPhotoForUrl:photoUrl completion:^(UIImage *image, NSString *objectUrl) {
                [self.photoUploadIndicator stopAnimating];
                if (image) {
                    [self.userImgBtn setImage:image forState:UIControlStateNormal];
                } else if (![self.userImgBtn imageForState:UIControlStateNormal]) {
                    [self.userImgBtn setTitle:InterfaceString(@"UploadPhoto") forState:UIControlStateNormal];
                }
            }];
        }
    });
}

- (void)userInfoSaved:(NSNotification *)ntf
{
    NSError *error = ntf.userInfo[@"error"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ntf.name object:nil];
    if (!error) {
        if ([ntf.name isEqualToString:UserDidSaveDetailsNotification]) {
            _needsDetailsSave = NO;
        } else {
            _needsPassSave = NO;
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) {
            self.view.userInteractionEnabled = YES;
            [[ErrorDisplayController sharedController] displayError:error];
            self.navigationItem.rightBarButtonItem = _savedRightBtnItem;
        } else if (!_needsDetailsSave && !_needsPassSave && _finishBlock) {
            _finishBlock();
        }
    });
}

- (void)keyboardFrameChanged:(NSNotification *)ntf
{
    CGFloat keyboardHeight = self.view.frame.size.height - [ntf.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
    CGFloat saveBtnHeight = CGRectGetHeight(self.saveBtn.frame);
    self.scrollViewBottomConstraint.constant = (keyboardHeight > saveBtnHeight) ? keyboardHeight - saveBtnHeight : 0;
}

- (void)textFieldChanged:(NSNotification *)ntf
{
    UITextField *textField = ntf.object;
    if (textField == self.firstNameTxtField || textField == self.lastNameTxtField || textField == self.emailTxtField) {
        User *user = [User currentUser];
        _needsDetailsSave = ![self.firstNameTxtField.text isEqual:user.userName] || ![self.lastNameTxtField.text isEqual:user.lastName] || ![self.emailTxtField.text isEqual:user.email];
    } else {
        _needsPassSave = ([self.createPassTxtField.text length] > 0) || ([self.confirmPassTxtField.text length] > 0);
    }
}

#pragma mark - UIImagePickerController delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    _imageToUpload = info[UIImagePickerControllerOriginalImage];
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImageWriteToSavedPhotosAlbum(_imageToUpload, nil, nil, NULL);
    }
    if (_imageToUpload){
        [self.userImgBtn setTitle:nil forState:UIControlStateNormal];
        [self.userImgBtn setImage:_imageToUpload forState:UIControlStateNormal];
    } else if (![self.userImgBtn imageForState:UIControlStateNormal]) {
        [self.userImgBtn setTitle:InterfaceString(@"UploadPhoto") forState:UIControlStateNormal];
    }
    
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [textField resignFirstResponder];
}

@end
