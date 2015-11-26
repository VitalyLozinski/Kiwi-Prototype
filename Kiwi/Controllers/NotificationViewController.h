#import <UIKit/UIKit.h>

#import "PassViewController.h"

@class Event;

@interface NotificationViewController : UIViewController<PassViewDelegate>

-(void)setLoginOrigin:(BOOL)login;
-(void)setEvent:(Event*)event;

@end
