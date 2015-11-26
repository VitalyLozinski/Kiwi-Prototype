#import "ModelObject.h"

extern NSString * const PromosListDidUpdateNotification;

@interface PromosList : ModelObject

@property (nonatomic, readonly) NSArray *promos;
@property (nonatomic, readonly) BOOL updating;

+ (instancetype)sharedInstance;
- (void)update;

@end
