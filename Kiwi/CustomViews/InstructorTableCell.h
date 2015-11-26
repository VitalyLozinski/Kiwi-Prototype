//
//  EventTableCell.h
//  Kiwi
//
//  Created by Georgiy on 5/17/14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

@class Trainer;

@interface InstructorTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *votesCountLbl;
@property (nonatomic, strong) IBOutlet UILabel *titleLbl;
@property (nonatomic, strong) IBOutlet UIView *colorView;
@property (nonatomic, strong) IBOutlet UIImageView *eventImg;
@property (nonatomic, strong) IBOutletCollection(UIImageView) NSArray *starImgs;
@property (weak, nonatomic) IBOutlet UIView *ratingView;

- (void)fillWithTrainer:(Trainer *)trainer selected:(BOOL)selected;

@end
