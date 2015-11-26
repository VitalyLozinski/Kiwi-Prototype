#import "PaymentHistoryCell.h"
#import "Event.h"
#import "UIFont+AppFonts.h"
#import "UIColor+AppColors.h"

@implementation PaymentHistoryCell

- (void)awakeFromNib
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    self.titleLbl.font = [UIFont regularAppFontOfSize:16];
    self.titleLbl.textColor = [UIColor grayColor];

    self.dateLbl.font = [UIFont boldAppFontOfSize:9];
    self.dateLbl.textColor = [UIColor grayColor];
    
    self.valueLbl.font = [UIFont regularAppFontOfSize:17];
    self.valueLbl.textColor = [UIColor grayColor];
}

- (void)fillWithEvent:(Event *)event
{
    static NSDateFormatter *sDateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sDateFormatter = [NSDateFormatter new];
        sDateFormatter.dateFormat = ViewDateTimeFormat;
    });
    
    self.titleLbl.text = event.eventname;
    self.dateLbl.text = [sDateFormatter stringFromDate:event.start];
    self.valueLbl.text = [NSString stringWithFormat:@"$%.0f", event.price];
}

@end
