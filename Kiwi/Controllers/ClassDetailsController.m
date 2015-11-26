//
//  ClassDetailsController.m
//  Kiwi
//
//  Created by Crackman on 18.05.14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

#import "ClassDetailsController.h"

#import "PassViewController.h"

#import "MyClasses.h"
#import "Event.h"
#import "Payments.h"
#import "User.h"

#import "ImageCache.h"

#import "UIColor+AppColors.h"
#import "UIFont+AppFonts.h"
#import "UIView+App.h"

#import "ServerRequestQueue.h"

#import "MapMarker.h"
#import "StarsSetter.h"

#import "NSObject+GoogleAnalytics.h"

typedef enum
{
    ClassDetailsModeTrainerInfo,
    ClassDetailsModeMap,
    ClassDetailsModeBooked,
} TClassDetailsMode;

@implementation ClassDetailsController
{
    BOOL _classDetailsMode;
    BOOL _instructorDetailsMode;
    UIImage * _shortViewImage;
    UIImage * _fullViewImage;
    UIImage * _shortClassImage;
    UIImage * _fullClassImage;
    MapMarker * _marker;
    UIAlertView * _cancelConfirmation;
    
    StarsSetter * _starsSetter;
}

#pragma mark - lifecycle methods

@synthesize paymentViewController;

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    self.title = InterfaceString(@"DefaultTitle");
    
    _classDetailsMode = NO;
    _instructorDetailsMode = NO;
    
    _shortViewImage = [UIImage imageNamed:@"EventShortViewIcon"];
    _fullViewImage = [UIImage imageNamed:@"EventFullViewIcon"];
    _shortClassImage = [UIImage imageNamed:@"ClassViewEmptyIcon"];
    _fullClassImage = [UIImage imageNamed:@"ClassViewGreenIcon"];
    
    [self.bookBtn setTitle:InterfaceString(@"BookClass") forState:UIControlStateNormal];
    [self.cancelBtn setTitle:InterfaceString(@"CancelClass") forState:UIControlStateNormal];
    [self.showPassBtn setTitle:InterfaceString(@"ShowPass") forState:UIControlStateNormal];
    
    self.classTitleLbl.textColor = [UIColor appGreenColor];
    self.classTitleLbl.font = [UIFont regularAppFontOfSize:22];
    
    self.dateTimeLabel.font = [UIFont boldAppFontOfSize:14];
    self.addressLabel.font = [UIFont boldAppFontOfSize:14];
    self.attendeesLabel.font = [UIFont regularAppFontOfSize:16];
    self.attendeesValue.font = [UIFont boldAppFontOfSize:21];
    self.attendeesValue.textColor = [UIColor appGreenColor];

    self.instructorDescription.font = [UIFont boldAppFontOfSize:14];
    self.profileLbl.font = [UIFont boldAppFontOfSize:14];

    self.votesCountLbl.font = [UIFont regularAppFontOfSize:13];

    self.notificationLabel.font = [UIFont boldAppFontOfSize:14];
    
    self.bookBtn.backgroundColor = [UIColor appGreenColor];
    self.bookBtn.titleLabel.font = [UIFont regularAppFontOfSize:16];
    
    self.cancelBtn.backgroundColor = [UIColor appGreenColor];
    self.cancelBtn.titleLabel.font = [UIFont regularAppFontOfSize:16];
    
    self.showPassBtn.backgroundColor = [UIColor appGreenColor];
    self.showPassBtn.titleLabel.font = [UIFont regularAppFontOfSize:16];
    
    self.attendingLbl.text = InterfaceString(@"AttendingEvent");
    self.attendingLbl.font = [UIFont boldAppFontOfSize:16];
    self.attendingLbl.superview.backgroundColor = [UIColor appGreenColor];
    self.attendingHeight.constant = 0;
    
    self.notificationHeight.constant = 0;
    [self updateMode];
    
    self.mapView.delegate = self;
    
    [self eventDidUpdate:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventDidUpdate:) name:EventDidUpdateNotification object:_event];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventBookFailed:) name:EventBookDidFailNotification object:_event];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventBooked:) name:EventBookDidFinishNotification object:_event];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventCancelFailed:) name:EventCancelDidFailNotification object:_event];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventCanceled:) name:EventCancelDidFinishNotification object:_event];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cardSaveFailed:) name:CardSaveDidFailNotification object:[User currentUser].paymentInfo];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cardSaved:) name:CardSaveDidFinishNotification object:[User currentUser].paymentInfo];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_event update];
    [self updateMode];
}

- (UINavigationItem *)navigationItem
{
    UINavigationItem *navItem = [super navigationItem];
    if (!navItem.leftBarButtonItems) {
        navItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BackButton"]
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(dismiss:)];
    }
    return navItem;
}

#pragma mark - action methods

- (void)dismiss:(id)sender
{
    if (self.navigationController)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)bookPressed:(id)sender
{
    if (_event.price < 0.0001f)
    {
        Trace(@"Booking free class");
        NSMutableDictionary *paymentInfo = [@{ @"payment_method_code" : @"none" } mutableCopy];
        [self.event book:paymentInfo];
        return;
    }
    
    [self gaiScreen:GaiClassBooking];

    self.paymentViewController = [BTPaymentViewController paymentViewControllerWithVenmoTouchEnabled:YES];
    self.paymentViewController.delegate = self;
    
    UINavigationController *paymentNavigationController =
    [[UINavigationController alloc] initWithRootViewController:self.paymentViewController];
    
    self.paymentViewController.navigationItem.leftBarButtonItem =
    [[UIBarButtonItem alloc]
     initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:paymentNavigationController
     action:@selector(dismissModalViewControllerAnimated:)];
    
    [self presentViewController:paymentNavigationController animated:(sender != nil) completion:nil];
}

- (IBAction)showPassPressed:(id)sender
{
    Trace(@"Showing pass");
    PassViewController * passViewController = [PassViewController new];
    [passViewController setImage:_event.passImage color:_event.passColor];
    [self.navigationController presentViewController:passViewController
                                            animated:YES
                                          completion:nil];
}

- (IBAction)cancelPressed:(id)sender
{
    [self gaiScreen:GaiBookingCancel];

    _cancelConfirmation = [[UIAlertView alloc] initWithTitle:InterfaceString(@"CancelConfirmationTitle")
                                                     message:InterfaceString(@"CancelConfirmationText")
                                                    delegate:self
                                           cancelButtonTitle:@"No"
                                           otherButtonTitles:@"Yes", nil];
    
    [_cancelConfirmation show];
}

- (void)alertView : (UIAlertView *)alertView clickedButtonAtIndex : (NSInteger)buttonIndex
{
    if (alertView == _cancelConfirmation)
    {
        if (buttonIndex == 1)
        {
            [_event cancel];
        }
        _cancelConfirmation = nil;
    }
}

- (IBAction)switchModePressed:(id)sender
{
    _instructorDetailsMode = !_instructorDetailsMode;
    if (_instructorDetailsMode)
        _classDetailsMode = NO;
    [UIView animateWithDuration:0.5 animations:^
    {
        [self updateMode];
    }];
}

- (IBAction)switchMode2Pressed:(id)sender
{
    _classDetailsMode = !_classDetailsMode;
    if (_classDetailsMode)
        _instructorDetailsMode = NO;
    [UIView animateWithDuration:0.5 animations:^
    {
        [self updateMode];
    }];
}

-(void)updateMode
{
    if (!_classDetailsMode && !_instructorDetailsMode)
    {
        [self gaiScreen:GaiClassSummary];
    }
    else if (_classDetailsMode)
    {
        [self gaiScreen:GaiClassDetails];
    }
    else if (_instructorDetailsMode)
    {
        [self gaiScreen:GaiTrainerDetails];
    }
    
    if (_instructorDetailsMode)
    {
        [_switchModeBtn setImage:_fullViewImage forState:UIControlStateNormal];
        [_switchModeBtn setImage:_fullViewImage forState:UIControlStateHighlighted];
    }
    else
    {
        [_switchModeBtn setImage:_shortViewImage forState:UIControlStateNormal];
        [_switchModeBtn setImage:_shortViewImage forState:UIControlStateHighlighted];
    }
    
    if (_classDetailsMode)
    {
        [_switchMode2Btn setImage:_fullClassImage forState:UIControlStateNormal];
        [_switchMode2Btn setImage:_fullClassImage forState:UIControlStateHighlighted];
    }
    else
    {
        [_switchMode2Btn setImage:_shortClassImage forState:UIControlStateNormal];
        [_switchMode2Btn setImage:_shortClassImage forState:UIControlStateHighlighted];
    }
    
    if (!_classDetailsMode && !_instructorDetailsMode)
    {
        _mapHeight.constant = [UIScreen mainScreen].bounds.size.height - 298;
        _attendeesHeight.constant = 0;
        _instructorViewOffset.constant = 320;
    }
    else
    {
        _mapHeight.constant = 0;
        _attendeesHeight.constant = 0;
        _instructorViewOffset.constant = _classDetailsMode ? 320 : 5;
    }
    [self.view layoutIfNeeded];
}

#pragma mark - notification processings

- (void)eventDidUpdate:(NSNotification *)ntf
{
    Trace(@"Event did update %ld / %ld", _event.passImage, _event.passColor);

    dispatch_async(dispatch_get_main_queue(),^
{
    static NSDateFormatter * sDateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sDateFormatter = [NSDateFormatter new];
        sDateFormatter.dateFormat = ViewDateTimeFormat;
    });

    if (!_starsSetter)
    {
        _starsSetter = [[StarsSetter alloc] initStars];
    }
    
    //self.title = _event.eventname;
    
    _classTitleLbl.text = _event.fullName;
    _trainerTypeLbl.text = _event.profileTitle;
    _classTypeLbl.text = _event.eventname;
    _priceLbl.text = [NSString stringWithFormat:@"$%d", (int)_event.price];
    _profileLbl.text = _event.description;
    _instructorDescription.text = _event.profile;
    _dateTimeLabel.text = [sDateFormatter stringFromDate:_event.start];
    _addressLabel.text = _event.address;
    
    _attendingLbl.text = ([_event.start timeIntervalSinceNow] > 0) ?
        InterfaceString(@"AttendingEvent") :
        InterfaceString(@"AttendedEvent");
    
    // UStars
    NSArray * starViews = @[_star0, _star1, _star2, _star3, _star4];
    for (NSUInteger i = 0; i < 5; ++i)
    {
        [_starsSetter setImage:_event.rating
                           for:((UIImageView *)starViews[i])
                            at:i];
    };
    self.votesCountLbl.text = [NSString stringWithFormat:@"%i votes", _event.votesCount];
    self.ratingView.hidden = !_event.showRating;
    self.votesCountLbl.hidden = !_event.showRating;
    
    NSInteger attendess = _event.totalSeats - _event.freeSeats;
    if (attendess < 0)
        attendess = 0;
    if (attendess > _event.totalSeats)
        attendess = _event.totalSeats;
    
    _attendeesValue.text = [NSString stringWithFormat:@"%ld of %ld",
                            (long)attendess, (long)_event.totalSeats];
    
    [[ImageCache sharedCache] getPhotoForUrl:[_event.photoUrlStr fullUrlPath] completion:^(UIImage *image, NSString *objectUrl) {
        if (image) {
            self.classImageView.image = image;
        }
    }];
    
    NSTimeInterval diff = [_event.start timeIntervalSinceNow];
    BOOL cancelable = diff > 60 * 60 * 24;
    _bookBtn.hidden = _event.booked;
    _showPassBtn.hidden = !_event.booked || cancelable;
    _cancelBtn.hidden = !_event.booked || !cancelable;
    
    _mapView.region =
    MKCoordinateRegionMakeWithDistance(_event.location.coordinate, 1000, 1000);
    
    if (_marker)
    {
        [_mapView removeAnnotations:@[_marker]];
    }
    _marker = [[MapMarker alloc] initWithEvent:_event];
    [_mapView addAnnotation:_marker];
    
    if (_event.booked && self.attendingHeight.constant < 30)
    {
        [UIView animateWithDuration:0.5 animations:^
        {
            self.attendingHeight.constant = 30;
            [self.view layoutIfNeeded];
        }];
    }
    if (!_event.booked && self.attendingHeight.constant > 0)
    {
        [UIView animateWithDuration:0.5 animations:^
        {
            self.attendingHeight.constant = 0;
            [self.view layoutIfNeeded];
        }];
    }
    
    [self.view layoutIfNeeded];
});
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation
{
    if (annotation == _marker)
    {
        return _marker;
    }
    return nil;
}

#pragma mark - BTPaymentViewControllerDelegate

// When a user types in their credit card information correctly, the BTPaymentViewController sends you
// card details via the `didSubmitCardWithInfo` delegate method.
//
// NB: you receive raw, unencrypted info in the `cardInfo` dictionary, but
// for easy PCI Compliance, you should use the `cardInfoEncrypted` dictionary
// to securely pass data through your servers to the Braintree Gateway.
- (void)paymentViewController:(BTPaymentViewController *)paymentViewController
        didSubmitCardWithInfo:(NSDictionary *)cardInfo
         andCardInfoEncrypted:(NSDictionary *)cardInfoEncrypted
{
    Trace(@"didSubmitCardWithInfo %@ andCardInfoEncrypted %@", cardInfo, cardInfoEncrypted);
    [[User currentUser].paymentInfo saveCard:cardInfoEncrypted];
}

// When a user adds a saved card from Venmo Touch to your app, the BTPaymentViewController sends you
// a paymentMethodCode that you can pass through your servers to the Braintree Gateway to
// add the full card details to your Vault.
- (void)paymentViewController:(BTPaymentViewController *)paymentViewController
didAuthorizeCardWithPaymentMethodCode:(NSString *)paymentMethodCode
{
    Trace(@"didAuthorizeCardWithPaymentMethodCode %@", paymentMethodCode);
    // Create a dictionary of POST data of the format
    // {"payment_method_code": "[encrypted payment_method_code data from Venmo Touch client]"}
    NSMutableDictionary *paymentInfo = [NSMutableDictionary dictionaryWithObject:paymentMethodCode
                                                                          forKey:@"payment_method_code"];
    [self.event book:paymentInfo];
}

#pragma mark - Networking


-(void)cardSaveFailed:(NSNotification *)ntf
{
    dispatch_async(dispatch_get_main_queue(),^
    {
        Trace(@"cardSaveFailed: %@", ntf.userInfo[@"error"]);
        
        [self.paymentViewController showErrorWithTitle:@"Error" message:@"Error saving your card"];
    });
}

-(void)cardSaved:(NSNotification *)ntf
{
    [[VTClient sharedVTClient] refresh];
    
    dispatch_async(dispatch_get_main_queue(),^
    {
        [self.paymentViewController prepareForDismissal];
        
        [self dismissViewControllerAnimated:NO completion:^(void)
        {
            [self bookPressed:nil];
        }];
    });
}

-(void)eventBookFailed:(NSNotification *)ntf
{
    dispatch_async(dispatch_get_main_queue(),^
    {
        [self.paymentViewController prepareForDismissal];
        [self dismissViewControllerAnimated:YES completion:^(void)
        {
            [self showMessage:InterfaceString(@"EventBookingFailed")
                    withColor:[UIColor redButtonColor]
                          for:3];
        }];
    });
}

-(void)eventBooked:(NSNotification *)ntf
{
    [_event update];
    [[MyClassesList sharedInstance] update];
    dispatch_async(dispatch_get_main_queue(),^
    {
        [self eventDidUpdate:nil];
        [self.paymentViewController prepareForDismissal];
        [self dismissViewControllerAnimated:YES completion:^(void)
        {
            //[self showMessage:InterfaceString(@"EventBooked")
            //        withColor:[UIColor appGreenColor]
            //              for:3];
            [[VTClient sharedVTClient] refresh];
        }];
    });
}

-(void)eventCancelFailed:(NSNotification *)ntf
{
    dispatch_async(dispatch_get_main_queue(),^
    {
        [self showMessage:InterfaceString(@"EventCancelFailed")
                withColor:[UIColor redButtonColor]
                      for:3];
    });
}

-(void)eventCanceled:(NSNotification *)ntf
{
    [_event update];
    [[MyClassesList sharedInstance] update];
    dispatch_async(dispatch_get_main_queue(),^
    {
        [self eventDidUpdate:nil];
        [self showMessage:InterfaceString(@"EventCanceled")
                withColor:[UIColor appGreenColor]
                      for:3];
    });
}

-(void)showMessage:(NSString*)message withColor:(UIColor*)color for:(NSInteger)time
{
    _notificationLabel.text = message;
    _notificationView.backgroundColor = color;
    [UIView animateWithDuration:0.5 animations:^
    {
        _notificationHeight.constant = 30;
        [self.view layoutIfNeeded];
    }
    completion:^(BOOL finished)
    {
        if (finished)
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
            {
                [UIView animateWithDuration:0.5 animations:^
                {
                    _notificationHeight.constant = 0;
                    [self.view layoutIfNeeded];
                }];
            });
        }
    }];
}

@end
