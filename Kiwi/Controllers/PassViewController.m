//
//  PassViewController.m
//  Kiwi
//
//  Created by Crackman on 01.06.14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

#import "PassViewController.h"
#import "UIImage+App.h"

@interface PassViewController ()
{
    NSArray * _colors;
    NSArray * _images;
    
    NSInteger _image;
    NSInteger _color;
    
    NSTimer * _timer;
    NSInteger _frame;
    
    NSArray * _heartsSequence;
    
    id<PassViewDelegate> _delegate;
}

@property (weak, nonatomic) IBOutlet UIView *image0;
@property (weak, nonatomic) IBOutlet UIView *image1;
@property (weak, nonatomic) IBOutlet UIView *image2;
@property (weak, nonatomic) IBOutlet UIView *image3;
@property (weak, nonatomic) IBOutlet UIView *image4;
@property (weak, nonatomic) IBOutlet UIView *image5;
@property (weak, nonatomic) IBOutlet UIView *image6;
@property (weak, nonatomic) IBOutlet UIView *image7;
@property (weak, nonatomic) IBOutlet UIView *image8;
@property (weak, nonatomic) IBOutlet UIView *image9;

@property (weak, nonatomic) IBOutlet UIImageView *heart;

@end

@implementation PassViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)beat
{
    _frame ++;
    if (_frame >= _heartsSequence.count)
    {
        _frame = 0;
    }
    
    [_heart setImage:_heartsSequence[_frame]];
}

- (void)setImage:(NSInteger)image color:(NSInteger)color
{
    _image = image;
    _color = color;
    
    [self applyPass];
}

- (void)setDelegate:(id<PassViewDelegate>)delegate
{
    _delegate = delegate;
}

- (NSArray*)heartAnimation:(NSString*)prefix
{
    NSMutableArray * result = [NSMutableArray new];
    for (NSInteger i = 16; i < 43; ++i)
    {
        NSString * imageName = [NSString stringWithFormat:@"%@Frame%li", prefix, (long)i];
        //Trace(@"%@", imageName);
        [result addObject:[UIImage imageNamed:imageName]];
    }
    return result;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.046f
                                              target:self
                                            selector:@selector(beat)
                                            userInfo:nil
                                             repeats:YES];
    
    _colors = @[@"Heart5",
                @"Heart1",
                @"Heart6",
                @"Heart4",
                @"Heart7",
                @"Heart2",
                @"Heart3"];
    
    _images = @[_image4, _image9, _image2, _image6, _image1,
                _image0, _image8, _image7, _image5, _image3];
    
    [self applyPass];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [_timer invalidate];
    _timer = nil;
}

-(void)applyPass
{
    if (!_images ||  _images.count == 0 ||
        !_colors || _colors.count == 0)
    {
        return;
    }
    for (NSInteger i = 0; i < _images.count; ++i)
    {
        ((UIView*)_images[i]).hidden = i != (_image % _images.count);
    }
    _heartsSequence = [self heartAnimation:_colors[_color % _colors.count]];
}

- (IBAction)screenPressed:(id)sender
{
    if (!_delegate || ![_delegate customPassViewDismiss])
    {
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
