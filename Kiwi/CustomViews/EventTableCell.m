//
//  EventTableCell.m
//  Kiwi
//
//  Created by Georgiy on 5/17/14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

#import "EventTableCell.h"

#import "Event.h"

#import "UIFont+AppFonts.h"

#import "ImageCache.h"
#import "StarsSetter.h"

@implementation EventTableCell

- (void)awakeFromNib
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.titleLbl.font = [UIFont regularAppFontOfSize:17];
}

- (void)fillWithEvent:(Event *)event
{
    static StarsSetter *sStarsSetter;
    static NSDateFormatter *sDateFormatter;
    static NSArray *sTagColors;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sStarsSetter = [[StarsSetter alloc] initSmallStars];
        sDateFormatter = [NSDateFormatter new];
        sDateFormatter.dateFormat = ViewDateTimeFormat;
        sTagColors = @[[UIColor orangeColor], [UIColor greenColor], [UIColor brownColor], [UIColor blueColor], [UIColor magentaColor]];
    });
    
    self.titleLbl.text = event.eventname;
    self.costLbl.text = [NSString stringWithFormat:@"$%.0f", event.price];
    self.dateLbl.text = [sDateFormatter stringFromDate:event.start];
    
    // UStars
    [self.starImgs enumerateObjectsUsingBlock:^(UIImageView *starImgView, NSUInteger idx, BOOL *stop)
    {
        [sStarsSetter setImage:event.rating for:starImgView at:idx];
    }];
    self.ratingView.hidden = !event.showRating;

    self.colorView.backgroundColor = sTagColors[arc4random_uniform(4)];
    
    [[ImageCache sharedCache] getPhotoForUrl:[event.photoUrlStr fullUrlPath] completion:^(UIImage *image, NSString *objectUrl) {
        if (image) {
            self.eventImg.image = image;
        }
    }];
}

@end
