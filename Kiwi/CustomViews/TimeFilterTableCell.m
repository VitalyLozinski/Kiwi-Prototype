//
//  EventTableCell.m
//  Kiwi
//
//  Created by Georgiy on 5/17/14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

#import "TimeFilterTableCell.h"

#import "TimeSpan.h"

#import "UIFont+AppFonts.h"

#import "ImageCache.h"

@interface TimeFilterTableCell()
{
    void (^_remove)(void);
    void (^_add)(void);
}

@property (nonatomic, strong) IBOutlet UILabel *fromLabel;
@property (nonatomic, strong) IBOutlet UILabel *toLabel;
@property (nonatomic, strong) IBOutlet UILabel *fromValue;
@property (nonatomic, strong) IBOutlet UILabel *toValue;
@property (nonatomic, strong) IBOutlet UILabel *addLabel;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIButton *removeButton;
@property (weak, nonatomic) IBOutlet UIView *separator;

@end

@implementation TimeFilterTableCell

- (void)awakeFromNib
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.fromLabel.font = [UIFont boldAppFontOfSize:14];
    self.fromLabel.text = InterfaceString(@"TimeFilterFrom");
    self.toLabel.font = [UIFont boldAppFontOfSize:14];
    self.toLabel.text = InterfaceString(@"TimeFilterTo");
    
    self.fromValue.font = [UIFont boldAppFontOfSize:14];
    self.toValue.font = [UIFont boldAppFontOfSize:14];
    
    self.addLabel.font = [UIFont regularAppFontOfSize:17];
    self.addLabel.text = InterfaceString(@"AddTimeFilter");
}

- (void)fillWithAddHandler:(void (^)(void))add
{
    _add = add;
    
    self.fromLabel.hidden = YES;
    self.toLabel.hidden = YES;
    self.fromValue.hidden = YES;
    self.toValue.hidden = YES;
    self.removeButton.hidden = YES;
    self.separator.hidden = YES;
    
    self.addLabel.hidden = NO;
    self.addButton.hidden = NO;
}

- (void)fillWithTimeSpan:(TimeSpan *)timeSpan removeHandler:(void (^)(void))remove
{
    _remove = remove;
    
    static NSDateFormatter *sDateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sDateFormatter = [NSDateFormatter new];
        sDateFormatter.dateFormat = ViewDateTimeFormat;
    });
    
    self.fromValue.text = [sDateFormatter stringFromDate:(NSDate*)timeSpan.from];
    self.toValue.text = [sDateFormatter stringFromDate:(NSDate*)timeSpan.to];

    self.fromLabel.hidden = NO;
    self.toLabel.hidden = NO;
    self.fromValue.hidden = NO;
    self.toValue.hidden = NO;
    self.removeButton.hidden = NO;
    self.separator.hidden = NO;

    self.addLabel.hidden = YES;
    self.addButton.hidden = YES;
}

- (IBAction)addButtonClicked:(id)sender
{
    _add();
}

- (IBAction)removeButtonClicked:(id)sender
{
    _remove();
}

@end
