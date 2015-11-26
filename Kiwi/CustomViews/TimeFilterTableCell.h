//
//  EventTableCell.h
//  Kiwi
//
//  Created by Georgiy on 5/17/14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

@class TimeSpan;

@interface TimeFilterTableCell : UITableViewCell

- (void)fillWithAddHandler:(void (^)(void))add;
- (void)fillWithTimeSpan:(TimeSpan *)timeSpan removeHandler:(void (^)(void))remove;

@end
