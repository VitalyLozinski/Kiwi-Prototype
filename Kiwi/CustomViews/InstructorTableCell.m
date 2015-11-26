//
//  EventTableCell.m
//  Kiwi
//
//  Created by Georgiy on 5/17/14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

#import "InstructorTableCell.h"

#import "Trainer.h"

#import "UIFont+AppFonts.h"
#import "UIColor+AppColors.h"

#import "ImageCache.h"
#import "StarsSetter.h"

@implementation InstructorTableCell

- (void)awakeFromNib
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.titleLbl.font = [UIFont regularAppFontOfSize:17];
    self.votesCountLbl.font = [UIFont regularAppFontOfSize:12];
}

- (void)fillWithTrainer:(Trainer *)trainer selected:(BOOL)selected
{
    static NSArray *sTagColors;
    static StarsSetter * sStarsSetter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sStarsSetter = [[StarsSetter alloc] initSmallStars];
        sTagColors = @[[UIColor orangeColor], [UIColor greenColor], [UIColor brownColor], [UIColor blueColor], [UIColor magentaColor]];
    });
    
    self.backgroundColor = selected ? [UIColor orangeInstructorColor] : [UIColor transparentWhiteColor];
    
    self.titleLbl.text = [trainer instructor];
    self.ratingView.hidden = !trainer.showRating;
    self.votesCountLbl.hidden = !trainer.showRating;
    self.votesCountLbl.text = [NSString stringWithFormat:@"%i votes", trainer.votesCount];
    // UStars
    [self.starImgs enumerateObjectsUsingBlock:^(UIImageView *starImgView, NSUInteger idx, BOOL *stop)
    {
        [sStarsSetter setImage:trainer.rating for:starImgView at:idx];
    }];
    
    self.colorView.backgroundColor = sTagColors[[[trainer instructor] hash] % 4];

    if ([trainer.photoUrlStr isKindOfClass:[NSString class]])
    {
        [[ImageCache sharedCache] getPhotoForUrl:[trainer.photoUrlStr fullUrlPath] completion:^(UIImage *image, NSString *objectUrl)
        {
            if (image)
            {
                self.eventImg.image = image;
            }
        }];
    }
}

@end
