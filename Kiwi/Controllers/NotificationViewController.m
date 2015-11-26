#import "NotificationViewController.h"
#import "PassViewController.h"

#import "Event.h"

@interface NotificationViewController ()

@end

@implementation NotificationViewController
{
    Event * _event;
    BOOL _updated;
    BOOL _shaken;
    BOOL _loginOrigin;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _updated = NO;
        _shaken = NO;
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)setEvent:(Event*)event
{
    _event = event;
    _updated = NO;
    _shaken = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventDidUpdate:) name:EventDidUpdateNotification object:_event];
    [_event update];
}

-(void)setLoginOrigin:(BOOL)login
{
    _loginOrigin = login;
}

- (void)eventDidUpdate:(NSNotification *)ntf
{
    dispatch_async(dispatch_get_main_queue(),^
    {
        _updated = YES;
        [self tryShow];
    });
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        _shaken = YES;
        [self tryShow];
    }
}

- (IBAction)onTap:(id)sender
{
    if (_loginOrigin)
    {
        [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)tryShow
{
    if (!_shaken || !_updated)
    {
        return;
    }
    
    if (_event.passImage >= 0 && _event.passColor >= 0)
    {
        PassViewController * passViewController = [PassViewController new];
        [passViewController setImage:_event.passImage color:_event.passColor];
        [passViewController setDelegate:self];
        [self presentViewController:passViewController
                           animated:YES
                         completion:nil];
     };
}

-(BOOL)customPassViewDismiss
{
    if (_loginOrigin)
    {
        [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    return YES;
}

@end
