//
//  ClassDetailsController.h
//  Kiwi
//
//  Created by Crackman on 18.05.14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//


#import "BTPaymentViewController.h"
//@class Event;
//@protocol EventBookDelegate;
#import "Event.h"

#import <MapKit/MapKit.h>

@interface ClassDetailsController : UIViewController<BTPaymentViewControllerDelegate, MKMapViewDelegate>


@property (weak, nonatomic) IBOutlet UIImageView *star0;
@property (weak, nonatomic) IBOutlet UIImageView *star1;
@property (weak, nonatomic) IBOutlet UIImageView *star2;
@property (weak, nonatomic) IBOutlet UIImageView *star3;
@property (weak, nonatomic) IBOutlet UIImageView *star4;
@property (weak, nonatomic) IBOutlet UILabel *votesCountLbl;

@property (nonatomic, strong) IBOutlet UIImageView *classImageView;
@property (nonatomic, strong) IBOutletCollection(UIImageView) NSArray *ratingIconViews;
@property (nonatomic, strong) IBOutlet UILabel *classTitleLbl;
@property (nonatomic, strong) IBOutlet UILabel *trainerTypeLbl;
@property (weak, nonatomic) IBOutlet UITextView *profileLbl;
@property (nonatomic, strong) IBOutlet UILabel *classTypeLbl;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (nonatomic, strong) IBOutlet UILabel *priceLbl;
@property (nonatomic, strong) IBOutlet UIButton *bookBtn;
@property (weak, nonatomic) IBOutlet UIButton *showPassBtn;
@property (weak, nonatomic) IBOutlet UIButton *switchModeBtn;
@property (weak, nonatomic) IBOutlet UIButton *switchMode2Btn;

@property (weak, nonatomic) IBOutlet UILabel *dateTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *attendeesLabel;
@property (weak, nonatomic) IBOutlet UILabel *attendeesValue;

@property (weak, nonatomic) IBOutlet UIView *notificationView;
@property (weak, nonatomic) IBOutlet UILabel *notificationLabel;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic, strong) Event *event;

@property (nonatomic, strong) BTPaymentViewController *paymentViewController;

@property (weak, nonatomic) IBOutlet UILabel *attendingLbl;

@property (weak, nonatomic) IBOutlet UIView *ratingView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *attendeesHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *notificationHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shortDetailsHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *attendingHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *instructorViewOffset;

@property (weak, nonatomic) IBOutlet UIView *instructorView;
@property (weak, nonatomic) IBOutlet UITextView *instructorDescription;


- (IBAction)switchModePressed:(id)sender;

@end
