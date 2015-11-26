//
//  EventTableCell.h
//  Kiwi
//
//  Created by Georgiy on 5/17/14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

@class Event;

@interface EventTableCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *titleLbl;
@property (nonatomic, strong) IBOutlet UILabel *dateLbl;
@property (nonatomic, strong) IBOutlet UILabel *costLbl;
@property (nonatomic, strong) IBOutlet UIView *colorView;
@property (nonatomic, strong) IBOutlet UIImageView *eventImg;
@property (nonatomic, strong) IBOutletCollection(UIImageView) NSArray *starImgs;
@property (weak, nonatomic) IBOutlet UIButton *detailsButton;
@property (weak, nonatomic) IBOutlet UIView *ratingView;

- (void)fillWithEvent:(Event *)event;

@end
