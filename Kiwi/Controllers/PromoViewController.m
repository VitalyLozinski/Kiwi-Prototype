#import "PromoViewController.h"
#import "UIView+App.h"
#import "UIFont+AppFonts.h"
#import "UIColor+AppColors.h"
#import "UIImage+App.h"
#import "Promo.h"
#import "Event.h"
#import "ImageCache.h"
#import "NSObject+GoogleAnalytics.h"

NSString * const LastPromoTimestamp = @"LastPromoTimestamp";

@interface PromoViewController ()
{
    NSArray * _content;
    NSArray * _events;
    NSInteger _page;
}

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dotsAdjust;

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *pages;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *images;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labels;

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *dotBackgrounds;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *dots;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *dotButtons;
@property (weak, nonatomic) IBOutlet UIButton *classButton;
@property (weak, nonatomic) IBOutlet UIButton *mapButton;

@end

@implementation PromoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

-(void)setContent:(NSArray*)content
{
    _content = content;
    _events = [NSMutableArray new];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self gaiScreen:GaiPromo];

    for (NSInteger i = _content.count; i < _pages.count; ++i)
    {
        ((UIView*)_dots[i]).hidden = YES;
        ((UIView*)_dotBackgrounds[i]).hidden = YES;
        ((UIView*)_dotButtons[i]).hidden = YES;
    }
    
    if (_content.count == 2)
    {
        _dotsAdjust.constant = -30;
    }
    if (_content.count == 1)
    {
        ((UIView*)_dots[0]).hidden = YES;
        ((UIView*)_dotBackgrounds[0]).hidden = YES;
        ((UIView*)_dotButtons[0]).hidden = YES;
    }
    
    for (NSInteger i = 0; i < _content.count && i < _labels.count; ++i)
    {
        ((UILabel*)_labels[i]).text = ((Promo*)_content[i]).text;
    }
    for (NSInteger i = 0; i < _content.count && i < _images.count; ++i)
    {
        ((UIImageView*)_images[i]).image = nil;
        [[ImageCache sharedCache] getPhotoForUrl:[((Promo*)_content[i]).photoUrlStr fullUrlPath] completion:^(UIImage *image, NSString *objectUrl)
        {
            if (image)
            {
                ((UIImageView*)_images[i]).image = image;
            }
        }];
    }
    
    [_mapButton setBackgroundImage:[UIImage imageWithColor:[UIColor appGreenColor]] forState:UIControlStateNormal];
    [_mapButton setBackgroundImage:[UIImage imageWithColor:[UIColor appGreenColor]] forState:UIControlStateDisabled];
    [_mapButton setBackgroundImage:[UIImage imageWithColor:[UIColor lightGreenColor]] forState:UIControlStateHighlighted];
    [_mapButton setTitle:InterfaceString(@"PromoGoToMap") forState:UIControlStateNormal];
    _mapButton.titleLabel.font = [UIFont regularAppFontOfSize:14];

    [_classButton setBackgroundImage:[UIImage imageWithColor:[UIColor appGreenColor]] forState:UIControlStateNormal];
    [_classButton setBackgroundImage:[UIImage imageWithColor:[UIColor appGreenColor]] forState:UIControlStateDisabled];
    [_classButton setBackgroundImage:[UIImage imageWithColor:[UIColor lightGreenColor]] forState:UIControlStateHighlighted];
    [_classButton setTitle:InterfaceString(@"PromoGoToClass") forState:UIControlStateNormal];
    _classButton.titleLabel.font = [UIFont regularAppFontOfSize:14];
    
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    [leftSwipe setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:leftSwipe];
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:rightSwipe];
    
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    float now = [NSDate dateWithTimeIntervalSinceNow:0].timeIntervalSince1970;
    [prefs setFloat:now forKey:LastPromoTimestamp];
    [prefs synchronize];
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)swipe
{
    if (swipe.direction == UISwipeGestureRecognizerDirectionLeft)
    {
        [self switchPageTo:_page + 1];
    }
    if (swipe.direction == UISwipeGestureRecognizerDirectionRight)
    {
        [self switchPageTo:_page - 1];
    }
}

- (IBAction)dotPressed:(id)sender
{
    for (NSInteger i = 0; i < _content.count && i < _dotButtons.count; ++i)
    {
        if (sender == _dotButtons[i])
        {
            [self switchPageTo:i];
            break;
        }
    }
}

- (void)switchPageTo:(NSInteger)page
{
    if (page >= _content.count ||
        page >= _pages.count ||
        page < 0 ||
        page == _page)
    {
        return;
    }
    
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
             for (NSInteger i = 0; i < _content.count && i < _pages.count; ++i)
             {
                 ((UIView*)_dots[i]).hidden = i != page;
             }
         }
     }];
}

- (IBAction)goToClass:(id)sender
{
    if (!((Promo*)_content[_page]).event.valid)
    {
        return;
    }
    
    [self dismissViewControllerAnimated:YES completion:^
     {
         if (_delegate)
         {
             [_delegate promoGoToClassDetails:((Promo*)_content[_page]).event];
         }
     }];
}

- (IBAction)goToMap:(id)sender
{
    if (!((Promo*)_content[_page]).event.valid)
    {
        return;
    }
    
    [self dismissViewControllerAnimated:YES completion:^
     {
         if (_delegate)
         {
             [_delegate promoGoToMap:((Promo*)_content[_page]).event];
         }
     }];
}

- (IBAction)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
