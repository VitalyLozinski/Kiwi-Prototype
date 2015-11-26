//
//  PaymentHistoryCell.h
//  Kiwi
//
//  Created by Georgiy on 6/29/14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

@class Event;

@interface PaymentHistoryCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *titleLbl;
@property (nonatomic, weak) IBOutlet UILabel *dateLbl;
@property (nonatomic, weak) IBOutlet UILabel *valueLbl;

- (void)fillWithEvent:(Event *)event;

@end
