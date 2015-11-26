//
//  TermsViewController.m
//  Kiwi
//
//  Created by Crackman on 01.06.14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

#import "TermsViewController.h"

#import "UIColor+AppColors.h"
#import "UIFont+AppFonts.h"

NSString * TacAcceptedKey = @"TacAccepted";

@interface TermsViewController ()
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet UILabel *termsTitleLabel;
@property (weak, nonatomic) IBOutlet UITextView *termsTextView;

@end

@implementation TermsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _acceptButton.titleLabel.font = [UIFont regularAppFontOfSize:14];
    _acceptButton.titleLabel.text = InterfaceString(@"TacAccept");
    
    _termsTitleLabel.font = [UIFont regularAppFontOfSize:18];
    _termsTitleLabel.text = InterfaceString(@"TacTitle");
    
    _termsTextView.font = [UIFont regularAppFontOfSize:14];
    UIFont * boldFont = [UIFont boldAppFontOfSize:14];
    
    NSMutableAttributedString * tos = [[NSMutableAttributedString alloc] initWithString:InterfaceString(@"TacText") attributes:@{NSFontAttributeName:_termsTextView.font}];
    
    while(true)
    {
        NSRange start = [tos.string rangeOfString:@"{"];
        NSRange finish = [tos.string rangeOfString:@"}"];
        if (start.location == NSNotFound ||
            finish.location == NSNotFound ||
            start.location > finish.location)
        {
            break;
        }
        [tos deleteCharactersInRange:finish];
        [tos deleteCharactersInRange:start];
        
        [tos addAttribute:NSFontAttributeName
                    value:boldFont
                    range:NSMakeRange(start.location, finish.location - start.location - 1)];
    }
    
    NSArray * links = @[@"http://www.kiwisweat.com/privacy",
                        @"http://www.kiwisweat.com/about"];
    NSInteger link = 0;
    
    while(true)
    {
        NSRange start = [tos.string rangeOfString:@"<"];
        NSRange finish = [tos.string rangeOfString:@">"];
        if (start.location == NSNotFound ||
            finish.location == NSNotFound ||
            start.location > finish.location)
        {
            break;
        }
        [tos deleteCharactersInRange:finish];
        [tos deleteCharactersInRange:start];
        
        if (link < links.count)
        {
            [tos addAttribute:NSLinkAttributeName
                        value:links[link]
                        range:NSMakeRange(start.location, finish.location - start.location - 1)];
        }
        
        link++;
    }
    
    _termsTextView.attributedText = tos;
    _termsTextView.textAlignment = NSTextAlignmentJustified;
}

- (IBAction)acceptButtonClicked:(id)sender
{
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:1 forKey:TacAcceptedKey];
    [prefs synchronize];
    
    [self dismissViewControllerAnimated:YES completion:^
    {
        if (self.acceptBlock)
        {
            self.acceptBlock();
        }
    }];
}

@end
