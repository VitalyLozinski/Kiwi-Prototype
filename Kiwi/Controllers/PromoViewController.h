#import <UIKit/UIKit.h>

extern NSString * const LastPromoTimestamp;

@class Event;

@protocol PromoViewControllerDelegate

-(void)promoGoToMap:(Event*)event;
-(void)promoGoToClassDetails:(Event*)event;

@end

@interface PromoViewController : UIViewController

@property (nonatomic) id<PromoViewControllerDelegate> delegate;

-(void)setContent:(NSArray*)content;

@end
