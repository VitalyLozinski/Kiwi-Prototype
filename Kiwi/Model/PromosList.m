#import "PromosList.h"
#import "Promo.h"
#import "ServerRequestQueue.h"

NSString * const PromosListDidUpdateNotification = @"PromosListDidUpdateNotification";

@implementation PromosList

+ (instancetype)sharedInstance
{
	static PromosList *sSharedInstance = nil;
	static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        sSharedInstance = [PromosList new];
    });
	return sSharedInstance;
}

- (void)updateFromArchivedValue:(id)value
{
    [super updateFromArchivedValue:value];
    
    _promos = [@[] mutableCopy];
    for (id promo in value)
    {
        [((NSMutableArray*)_promos) addObject:[[Promo alloc] initWithArchivedValue:promo]];
    }
}

- (void)update
{
    if (_updating)
    {
        return;
    }
    
    _updating = YES;
    NSMutableDictionary * dict = [NSMutableDictionary new];

    [[ServerRequestQueue defaultQueue] addServerRequestForLink:ServerLinkPromosList
                                                  withBodyDict:dict
                                             completionHandler:^(id result, NSError *error)
     {
         NSDictionary *userInfo = nil;
         
         if (error)
         {
             userInfo = @{ @"error" : error };
             _promos = @[];
         }
         else
         {
             [self updateFromArchivedValue:result];
         }
         _updating = NO;
         
         [[NSNotificationCenter defaultCenter] postNotificationName:PromosListDidUpdateNotification object:self userInfo:userInfo];
     }];
}

@end
