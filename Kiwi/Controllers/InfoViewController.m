//
//  InfoViewController.m
//  Kiwi
//
//  Created by Crackman on 01.06.14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

#import "InfoViewController.h"
#import "UIView+App.h"
#import "UIFont+AppFonts.h"
#import "NSObject+GoogleAnalytics.h"

NSString * IntroPlayedKey = @"IntroPlayed";

@interface InfoViewController ()
{
    NSInteger _page;
    NSArray * _pages;
    NSArray * _pageDots;
}

@property (weak, nonatomic) IBOutlet UIView *page1;
@property (weak, nonatomic) IBOutlet UIView *page2;
@property (weak, nonatomic) IBOutlet UIView *page3;

@property (weak, nonatomic) IBOutlet UIButton *nextPageButton;
@property (weak, nonatomic) IBOutlet UIButton *closeIntroButton;

@property (weak, nonatomic) IBOutlet UIImageView *page1Dot;
@property (weak, nonatomic) IBOutlet UIImageView *page2Dot;
@property (weak, nonatomic) IBOutlet UIImageView *page3Dot;

@property (weak, nonatomic) IBOutlet UILabel *page1Title;
@property (weak, nonatomic) IBOutlet UILabel *page1Text;

@property (weak, nonatomic) IBOutlet UILabel *page2Title;
@property (weak, nonatomic) IBOutlet UILabel *page2Text;

@property (weak, nonatomic) IBOutlet UILabel *page3Title;
@property (weak, nonatomic) IBOutlet UILabel *page3Text;

@end

@implementation InfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self gaiScreen:GaiIntro];
    
    _pages = @[_page1, _page2, _page3];
    _pageDots = @[_page1Dot, _page2Dot, _page3Dot];
    
    _page1Title.font = [UIFont regularAppFontOfSize:52];
    _page1Title.text = InterfaceString(@"InfoPage1Title");
    _page1Text.font = [UIFont regularAppFontOfSize:25];
    _page1Text.text = InterfaceString(@"InfoPage1Text");
    
    _page2Title.font = [UIFont regularAppFontOfSize:52];
    _page2Title.text = InterfaceString(@"InfoPage2Title");
    _page2Text.font = [UIFont regularAppFontOfSize:25];
    _page2Text.text = InterfaceString(@"InfoPage2Text");
    
    _page3Title.font = [UIFont regularAppFontOfSize:52];
    _page3Title.text = InterfaceString(@"InfoPage3Title");
    _page3Text.font = [UIFont regularAppFontOfSize:25];
    _page3Text.text = InterfaceString(@"InfoPage3Text");
    
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    [leftSwipe setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:leftSwipe];

    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:rightSwipe];
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)swipe
{
    if (swipe.direction == UISwipeGestureRecognizerDirectionLeft)
    {
        [self nextPage];
    }
    if (swipe.direction == UISwipeGestureRecognizerDirectionRight)
    {
        [self prevPage];
    }
}

- (void)nextPage
{
    if (_page < 2)
    {
        [self switchPageTo:_page + 1];
    }
}

- (void)prevPage
{
    if (_page > 0)
    {
        [self switchPageTo:_page - 1];
    }
}

- (IBAction)page0:(id)sender
{
    [self switchPageTo:0];
}

- (IBAction)page1:(id)sender
{
    [self switchPageTo:1];
}

- (IBAction)page2:(id)sender
{
    [self switchPageTo:2];
}


- (void)switchPageTo:(NSInteger)page
{
    if (page == _page)
        return;
    
    NSInteger from = (page > _page) ? 320 : -320;
 
    Trace(@"Switching from %li to %li", (long)_page, (long)page);
    
    ((UIView *)_pages[ page]).hidden = NO;
    [((UIView *)_pages[ page]) halign:from];
    [((UIView *)_pages[_page]) halign:0];
    
    [UIView animateWithDuration:0.5f animations:^
     {
         [((UIView *)_pages[ page]) halign:0];
         [((UIView *)_pages[_page]) halign:-from];
     }
    completion:^(BOOL completed)
     {
         if (completed)
         {
             ((UIView *)_pages[_page]).hidden = YES;
             _page = page;
             for (NSInteger i = 0; i < _pageDots.count; ++i)
             {
                 ((UIView*)_pageDots[i]).hidden = i != page;
             }
         }
     }];
}

- (IBAction)closePressed:(id)sender
{
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:1 forKey:IntroPlayedKey];
    [prefs synchronize];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
