//
//  MapMarkerDetailsView.m
//  Kiwi
//
//  Created by Crackman on 26.05.14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

#import "MapMarkerDetailsView.h"

#import "UIFont+AppFonts.h"
#import "UIColor+AppColors.h"

#import "Event.h"

#import "ImageCache.h"
#import "StarsSetter.h"

@interface MapMarkerDetailsView ()

@property (weak, nonatomic) IBOutlet UIImageView *iconImage;
@property (weak, nonatomic) IBOutlet UILabel *eventTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *instructorLabel;
@property (weak, nonatomic) IBOutlet UIView *rateView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rateViewWidth;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *starImgs;

@end

@implementation MapMarkerDetailsView


-(id)initWithEvent:(Event*)event
{
    NSArray * nibContents = [[NSBundle mainBundle] loadNibNamed:@"MapMarkerDetailsView"
                                                          owner:nil
                                                        options:nil];
    if (nibContents && nibContents.count > 0)
    {
        self = nibContents.lastObject;
    }
    if (self)
    {
        static NSDateFormatter * sDateFormatter;
        static StarsSetter * sStarsSetter;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sStarsSetter = [[StarsSetter alloc] initSmallStars];
            sDateFormatter = [NSDateFormatter new];
            sDateFormatter.dateFormat = ViewDateTimeFormat;
        });
        
        _event = event;
                
        _eventTitleLabel.font = [UIFont regularAppFontOfSize:18];
        _eventTitleLabel.text = _event.eventname;
        
        _dateTimeLabel.text = [sDateFormatter stringFromDate:_event.start];
        _dateTimeLabel.font = [UIFont boldAppFontOfSize:11];

        _instructorLabel.text = _event.shortName;
        _instructorLabel.font = [UIFont regularAppFontOfSize:15];
        _instructorLabel.textColor = [UIColor appGreenColor];
        
        // UStars
        if (!event.showRating)
        {
            _rateViewWidth.constant = 0;
            _rateView.hidden = YES;
        }
        else
        {
            [self.starImgs enumerateObjectsUsingBlock:^(UIImageView *starImgView, NSUInteger idx, BOOL *stop)
             {
                 [sStarsSetter setImage:event.rating for:starImgView at:idx];
             }];
        }
        
        _priceLabel.text = [NSString stringWithFormat:@"$%.0f", _event.price];
        _priceLabel.font = [UIFont boldAppFontOfSize:11];
    }
    return self;
}

-(void)didMoveToSuperview
{
    [[ImageCache sharedCache] getPhotoForUrl:[_event.photoUrlStr fullUrlPath] completion:^(UIImage *image, NSString *objectUrl) {
        if (image) {
            self.iconImage.image = image;
        }
    }];
}

- (IBAction)detailsButtonClicked:(id)sender
{
    if (_delegate &&
        [_delegate respondsToSelector:@selector(onDetailsInvokedForEvent:)])
    {
        [_delegate onDetailsInvokedForEvent:_event];
    }
}

- (IBAction)bodyClicked:(id)sender
{
    [self detailsButtonClicked:sender];
}


@end
