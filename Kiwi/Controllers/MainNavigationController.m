//
//  MainNavigationController.m
//  Kiwi
//
//  Created by Crackman on 17.05.14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

#import "MainNavigationController.h"

#import "EventMapViewController.h"
#import "EventsListViewController.h"
#import "LoginViewController.h"
#import "MenuViewController.h"
#import "PaymentsListViewController.h"
#import "UserProfileViewController.h"
#import "EventsListViewController.h"
#import "NotificationViewController.h"
#import "RateViewController.h"
#import "PromoViewController.h"
#import "ClassDetailsController.h"

#import "UIFont+AppFonts.h"
#import "UIColor+AppColors.h"
#import "UIAlertView+BlockActions.h"

#import "User.h"
#import "Event.h"
#import "MyClasses.h"
#import "Promo.h"
#import "PromosList.h"

#import "ErrorDisplayController.h"
#import "NSObject+GoogleAnalytics.h"

NSString * const MenuStateChangedNotification = @"MenuStateChangedNotification";
const float RefresherCooldown = 10 * 60;

@interface MainNavigationController ()
{
    EventMapViewController *_eventsMap;
    LoginViewController *_login;
    
    MenuViewController *_menu;
    
    UIBarButtonItem * _toggleMenuButton;
    UIBarButtonItem * _goBackButton;
    UIBarButtonItem * _showMapButton;
    float _refresherCooldown;
    NSTimer * _timer;
    NSTimeInterval _prevTick;
    
    BOOL _prompted;
}

@end

@implementation MainNavigationController

+ (instancetype)rootInstance
{
    static MainNavigationController *sRootInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sRootInstance = [self new];
    });
    return sRootInstance;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _refresherCooldown = RefresherCooldown;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(userDidLogin:)
                                                     name:UserDidLoginNotification
                                                   object:[User currentUser]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(userDidLogout:)
                                                     name:UserDidLogoutNotification
                                                   object:[User currentUser]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(promosUpdated:)
                                                     name:PromosListDidUpdateNotification
                                                   object:[PromosList sharedInstance]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(myClassesUpdated:)
                                                     name:MyClassesDidUpdateNotification
                                                   object:[MyClassesList sharedInstance]];
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_timer invalidate];
    _timer = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _toggleMenuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ActiveMenuButton"] style:UIBarButtonItemStylePlain target:self action:@selector(toggleMenu)];
    _goBackButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BackButton"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    _showMapButton = [[UIBarButtonItem alloc] initWithTitle:InterfaceString(@"Map") style:UIBarButtonItemStylePlain target:self action:@selector(showMap:)];
    [_showMapButton setTitleTextAttributes: @{NSFontAttributeName : [UIFont regularAppFontOfSize:14]} forState:UIControlStateNormal];
    [_showMapButton setTitlePositionAdjustment:UIOffsetMake(-8, 0) forBarMetrics:UIBarMetricsDefault];
    
    _eventsMap = [EventMapViewController new];
    _eventsMap.navigationItem.leftBarButtonItems = @[_toggleMenuButton];
    
    _login = [LoginViewController new];
    
    _menu = [MenuViewController new];
    _menu.delegate = self;
    
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavigationBarBackground"] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [UIImage imageNamed:@"NavigationBarShadow"];
    self.navigationBar.translucent = YES;
    
    [self setViewControllers:@[_eventsMap]];
    
    _prevTick = [NSDate dateWithTimeIntervalSinceNow:0].timeIntervalSince1970;
    _timer = [NSTimer scheduledTimerWithTimeInterval:2.0f
                                              target:self
                                            selector:@selector(tick)
                                            userInfo:nil
                                             repeats:YES];
    
    
}

-(void)refresh
{
    _refresherCooldown = 0;
}

-(void)tick
{
    NSTimeInterval now = [NSDate dateWithTimeIntervalSinceNow:0].timeIntervalSince1970;
    float delta = now - _prevTick;
    _prevTick = now;
    _refresherCooldown -= delta;
    
    if (_refresherCooldown < 0 &&
        [User currentUser].loggedIn &&
        self.viewControllers.count > 0 &&
        self.viewControllers[self.viewControllers.count - 1] == _eventsMap &&
        [_eventsMap isIdle])
    {
        Trace(@"Refreshing");
        [self tryPrompt];
        [_eventsMap forceUpdateEventsForCurrentMap];
    }
}

#pragma mark - notification processing

- (void)userDidLogin:(NSNotification *)ntf
{
    Trace(@"User did login");
    dispatch_async(dispatch_get_main_queue(),
    ^{
        NSError *error = ntf.userInfo[@"error"];
        if (error)
        {
            [[ErrorDisplayController sharedController] displayError:error];
        }
        else
        {
            [self tryPrompt];
        }
    });
}

-(void)tryPrompt
{
    _prompted = NO;
    _refresherCooldown = RefresherCooldown;

    dispatch_async(dispatch_get_main_queue(),
    ^{
        float timeSinceLastPromo = 1000000.0f;
            
        NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
        float lastPromo = [prefs floatForKey:LastPromoTimestamp];
            
        if (lastPromo > 1)
        {
            timeSinceLastPromo = [NSDate dateWithTimeIntervalSinceNow:0].timeIntervalSince1970 - lastPromo;
        }
        
        if (timeSinceLastPromo > 60 * 60 * 24)
        {
            Trace(@"Waiting for promos");
            [[PromosList sharedInstance] update];
        }
        else
        {
            Trace(@"Promos are on cooldown, waiting for my classes");
            [[MyClassesList sharedInstance] update];
        }
    });
}

-(void)promosUpdated:(NSNotification*)ntf
{
    dispatch_async(dispatch_get_main_queue(),
    ^{
        Trace(@"Promos updated: %@", _prompted ? @"yes" : @"no");
        if (!_prompted && [PromosList sharedInstance].promos.count > 0)
        {
            _prompted = YES;
            if (_login.isViewLoaded && _login.view.window)
            {
                Trace(@"Prompting for promos after login");
            
                [_login dismissViewControllerAnimated:YES completion:^
                {
                    PromoViewController *promoViewController = [PromoViewController new];
                    promoViewController.delegate = self;
                    [promoViewController setContent:[PromosList sharedInstance].promos];
                    [self presentViewController:promoViewController animated:YES completion:nil];
                 
                    [[MyClassesList sharedInstance] update];
                }];
            }
            else
            {
                Trace(@"Prompting for promos");
                
                PromoViewController *promoViewController = [PromoViewController new];
                promoViewController.delegate = self;
                [promoViewController setContent:[PromosList sharedInstance].promos];
                [self presentViewController:promoViewController animated:YES completion:nil];
                
                [[MyClassesList sharedInstance] update];
            }
        }
        else
        {
            Trace(@"No promos, waiting for my classes");
            [[MyClassesList sharedInstance] update];
        }
    });
}

-(void)myClassesUpdated:(NSNotification*)ntf
{
    Trace(@"myClassesUpdated");
    dispatch_async(dispatch_get_main_queue(),
    ^{
        Trace(@"Current view controller: %@", [self presentedViewController]);
        if (!_prompted)
        {
            _prompted = YES;
            if ([self presentedViewController] == _login)
            {
                if (ntf && ntf.userInfo[@"error"])
                {
                    [[ErrorDisplayController sharedController] displayError:ntf.userInfo[@"error"]];
                }
                else
                {
                    NSArray * currentEvents = [[MyClassesList sharedInstance] currentEvents];
                    NSArray * eventsToRate = [[MyClassesList sharedInstance] eventsToRate];
            
                    if (currentEvents.count > 0)
                    {
                        Trace(@"Presenting event notification");
                        NotificationViewController * notification = [NotificationViewController new];
                        [notification setLoginOrigin:YES];
                        [notification setEvent:currentEvents[0]];
                        [_login presentViewController:notification animated:NO completion:nil];
                    }
                    else if (eventsToRate.count > 0)
                    {
                        Trace(@"Dismissing login to show rate");
                        [_login dismissViewControllerAnimated:YES completion:^
                        {
                            RateViewController *rateViewController = [RateViewController new];
                            [rateViewController setEvent:eventsToRate[eventsToRate.count - 1]];
                            Trace(@"Pushing rate");
                            [self pushViewController:rateViewController animated:YES];
                        }];
                    }
                    else
                    {
                        Trace(@"Just dismissing login");
                        [_login dismissViewControllerAnimated:YES completion:nil];
                    }
                }
            }
            else
            {
                NSArray * currentEvents = [[MyClassesList sharedInstance] currentEvents];
                NSArray * eventsToRate = [[MyClassesList sharedInstance] eventsToRate];
                
                if (currentEvents.count > 0)
                {
                    NotificationViewController * notification = [NotificationViewController new];
                    [notification setEvent:currentEvents[0]];
                    Trace(@"Presenting event notification");
                    [self presentViewController:notification animated:NO completion:nil];
                }
                else if (eventsToRate.count > 0)
                {
                    RateViewController *rateViewController = [RateViewController new];
                    [rateViewController setEvent:eventsToRate[eventsToRate.count - 1]];
                    Trace(@"Pushing rate");
                    [self pushViewController:rateViewController animated:YES];
                }
            }
        }
    });
}

-(void)promoGoToClassDetails:(Event *)event
{
    [_eventsMap goToEventDetails:event];
}

-(void)promoGoToMap:(Event *)event
{
    [_eventsMap centerOnEvent:event];
}

- (void)userDidLogout:(NSNotification *)ntf
{
    dispatch_async(dispatch_get_main_queue(), ^{
        Trace(@"User logged out");
        [self presentViewController:_login animated:YES completion:nil];
    });
}

- (void)pictureUploadError:(NSNotification *)ntf
{
    if (ntf.userInfo[@"error"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[ErrorDisplayController sharedController] displayError:ntf.userInfo[@"error"]];
        });
    }
}

#pragma mark - action processing

- (void)goBack
{
    [self popViewControllerAnimated:YES];
}

- (void)showMap:(id)sender
{
    [self displayController:_eventsMap push:NO];
}

- (void)goToProfile
{
    UserProfileViewController* userProfile = [UserProfileViewController new];
    userProfile.navigationItem.leftBarButtonItem = _toggleMenuButton;
    userProfile.navigationItem.rightBarButtonItem = _showMapButton;
    userProfile.finishBlock = ^() {
        [self showMap:nil];
    };
    
    [self displayController:userProfile push:NO];
}

- (void)goToPayments
{
    PaymentsListViewController * paymentsList = [PaymentsListViewController new];
    paymentsList.navigationItem.leftBarButtonItems = @[_goBackButton];
    [self displayController:paymentsList push:YES];
}

- (void)goToClasses
{
    [self displayController:[EventsListViewController new] push:YES];
}

- (void)signOut
{
    [self gaiScreen:GaiSignOut];

    [self setMenuOpened:NO animated:NO];
    [[User currentUser] logout];
}

- (void)goToLogin
{
    [self presentViewController:_login animated:NO completion:nil];
}

- (void)toggleMenu
{
    [self setMenuOpened:![self menuOpened] animated:YES];
}

- (void)hideMenu
{
    [self setMenuOpened:NO animated:YES];
}

- (void)setMenuOpened:(BOOL)menuOpened animated:(BOOL)animated
{
    if (menuOpened != _menuOpened)
    {
        _menuOpened = menuOpened;
        if (menuOpened) {
            [self addChildViewController:_menu];
            [self.view addSubview:_menu.view];
        }
        [_menu setMenuOpen:menuOpened animated:animated];
        [[NSNotificationCenter defaultCenter] postNotificationName:MenuStateChangedNotification object:self];
    }
}

#pragma mark - internal methods

- (void)displayController:(UIViewController *)controller push:(BOOL)push
{
    [self setMenuOpened:NO animated:NO];
    if (push) {
        [self pushViewController:controller animated:YES];
    } else {
        void (^displayBlock)(void) = ^{
            [self setViewControllers:@[controller] animated:YES];
        };
        
        UserProfileViewController *activeController = self.viewControllers[0];
        if ([activeController isKindOfClass:[UserProfileViewController class]] && [activeController hasUnsavedChanges]) {
            [UIAlertView showAlertViewWithTitle:InterfaceString(@"UnsavedChanges") message:InterfaceString(@"UnsavedChangesText") cancelButtonTitle:InterfaceString(@"Cancel") otherButtonTitles:@[InterfaceString(@"No"), InterfaceString(@"Yes")] onDismiss:^(NSInteger buttonIndex) {
                if (buttonIndex == 0) {
                    displayBlock();
                } else {
                    activeController.finishBlock = displayBlock;
                    [activeController savePressed:nil];
                }
            } onCancel:NULL];
        } else {
            displayBlock();
        }
    }
}

@end
