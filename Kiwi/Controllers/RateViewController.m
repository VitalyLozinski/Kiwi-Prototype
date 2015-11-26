#import "RateViewController.h"
#import "UIColor+AppColors.h"
#import "UIFont+AppFonts.h"
#import "UIView+App.h"
#import "ImageCache.h"
#import "Event.h"
#import "NSObject+GoogleAnalytics.h"

@interface RateViewController ()
{
    UIImage * _emptyStar;
    UIImage * _fullStar;
    int _rate;
}

@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIView *colorBar;
@property (weak, nonatomic) IBOutlet UILabel *header;
@property (weak, nonatomic) IBOutlet UILabel *subHeader;
@property (weak, nonatomic) IBOutlet UIImageView *trainerIcon;
@property (weak, nonatomic) IBOutlet UILabel *trainerName;
@property (weak, nonatomic) IBOutlet UILabel *trainerTitle;
@property (weak, nonatomic) IBOutlet UILabel *className;
@property (weak, nonatomic) IBOutlet UILabel *rateHint;
@property (weak, nonatomic) IBOutlet UITextView *comment;
@property (weak, nonatomic) IBOutlet UIView *progressIndicator;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *stars;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *doneButtonHeight;

@end

@implementation RateViewController
{
    Event * _event;
    UIImage * _emptyStarImage;
    UIImage * _fullStarImage;
}

-(void)setEvent:(Event*)event
{
    _event = event;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventDidUpdate:) name:EventDidUpdateNotification object:_event];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ratingSaveDidFinish:) name:EventRatingSaveDidFinishNotification object:_event];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ratingSaveDidFail:) name:EventRatingSaveDidFailNotification object:_event];
    [_event update];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self gaiScreen:GaiRateTrainer];

    self.title = InterfaceString(@"DefaultTitle");
    
    _emptyStarImage = [UIImage imageNamed:@"EmptyStar"];
    _fullStarImage = [UIImage imageNamed:@"FullStar"];
    
    self.header.text = InterfaceString(@"RateHeader");
    self.header.textColor = [UIColor appGreenColor];
    self.header.font = [UIFont regularAppFontOfSize:26];

    self.subHeader.text = InterfaceString(@"RateSubHeader");
    self.subHeader.textColor = [UIColor grayColor];
    self.subHeader.font = [UIFont regularAppFontOfSize:18];
    
    self.trainerName.text = @"";
    self.trainerName.textColor = [UIColor appGreenColor];
    self.trainerName.font = [UIFont regularAppFontOfSize:26];
    
    self.trainerTitle.text = @"";
    self.trainerTitle.textColor = [UIColor darkGrayColor];
    self.trainerTitle.font = [UIFont boldAppFontOfSize:14];
    
    self.className.text = @"";
    self.className.textColor = [UIColor grayColor];
    self.className.font = [UIFont regularAppFontOfSize:18];
    
    self.rateHint.text = InterfaceString(@"RateHint");
    self.rateHint.textColor = [UIColor grayColor];
    self.rateHint.font = [UIFont regularAppFontOfSize:18];
    
    self.comment.textColor = [UIColor darkGrayColor];
    self.comment.font = [UIFont regularAppFontOfSize:14];
    self.comment.text = @"";
    self.comment.delegate = self;
    
    [[self.comment layer] setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [[self.comment layer] setBorderWidth:1];
    [[self.comment layer] setCornerRadius:2];
    
    [self textViewDidEndEditing:self.comment];
    
    [self.doneButton setTitle:InterfaceString(@"RateDone") forState:UIControlStateNormal];
    self.doneButton.titleLabel.font = [UIFont regularAppFontOfSize:18];
    self.doneButton.backgroundColor = [UIColor appGreenColor];
    
    self.doneButtonHeight.constant = 0;
}

- (void) animateTextView:(BOOL) up
{
    const int movementDistance = 200; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    int movement= movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.inputView.frame, 0, movement);
    [UIView commitAnimations];
}

-(NSString *)commentText
{
    if ([self.comment.text isEqualToString:InterfaceString(@"RateCommentPlaceholder")])
    {
        return @"";
    }
    return self.comment.text;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:InterfaceString(@"RateCommentPlaceholder")]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }
    [textView becomeFirstResponder];
    if (textView == self.comment)
    {
        [UIView animateWithDuration:0.5f animations:^
         {
             [self.view valign:-170];
         }];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = InterfaceString(@"RateCommentPlaceholder");
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
    if (textView == self.comment)
    {
        [UIView animateWithDuration:0.5f animations:^
         {
             [self.view valign:0];
         }];
    }
}

- (UINavigationItem *)navigationItem
{
    UINavigationItem *navItem = [super navigationItem];
    if (!navItem.leftBarButtonItems) {
        navItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BackButton"]
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(dismiss:)];
    }
    return navItem;
}

- (void)dismiss:(id)sender
{
    if (self.navigationController)
    {
        _event.rated = YES;
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)rate:(int)rate
{
    _rate = rate;
    for (int i = 0; i < self.stars.count; ++i)
    {
        [self.stars[i] setBackgroundImage:(i < _rate ?
                                           _fullStarImage :
                                           _emptyStarImage)
                                 forState:UIControlStateNormal];
    }
    if (_rate > 0 && self.doneButtonHeight.constant < 1)
    {
        [UIView animateWithDuration:0.5f animations:^
        {
            self.doneButtonHeight.constant = 40;
        }];
    }
}

- (IBAction)rate1:(id)sender
{
    [self rate:1];
}

- (IBAction)rate2:(id)sender
{
    [self rate:2];
}

- (IBAction)rate3:(id)sender
{
    [self rate:3];
}

- (IBAction)rate4:(id)sender
{
    [self rate:4];
}

- (IBAction)rate5:(id)sender
{
    [self rate:5];
}

- (IBAction)onDone:(id)sender
{
    if (_rate <= 0)
    {
        
        return;
    }
    self.progressIndicator.hidden = NO;
    [_event rate:_rate comment:[self commentText]];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)ratingSaveDidFinish:(NSNotification *)ntf
{
    dispatch_async(dispatch_get_main_queue(),^
    {
        _event.rated = YES;
        self.progressIndicator.hidden = YES;
        [self.navigationController popViewControllerAnimated:YES];
    });
}

- (void)ratingSaveDidFail:(NSNotification *)ntf
{
    dispatch_async(dispatch_get_main_queue(),^
    {
        self.progressIndicator.hidden = YES;
        [self.navigationController popViewControllerAnimated:YES];
    });
}

- (void)eventDidUpdate:(NSNotification *)ntf
{
    dispatch_async(dispatch_get_main_queue(),^
    {
        static NSDateFormatter *sDateFormatter;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sDateFormatter = [NSDateFormatter new];
            sDateFormatter.dateFormat = ViewDateTimeFormat;
        });
        
        self.trainerName.text = _event.fullName;
        self.trainerTitle.text = _event.profileTitle;
        self.className.text = _event.eventname;
        [[ImageCache sharedCache] getPhotoForUrl:[_event.photoUrlStr fullUrlPath]
                                      completion:^(UIImage *image, NSString *objectUrl)
        {
            if (image)
            {
                self.trainerIcon.image = image;
            }
        }];
        
        [self.view layoutIfNeeded];
    });
}

@end
