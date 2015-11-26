#import "TrainersList.h"
#import "Trainer.h"

#import "ServerRequestQueue.h"

#import "User.h"

NSString * const TrainersListDidUpdateNotification = @"TrainersListDidUpdateNotification";

@implementation TrainersList

- (void)updateFromArchivedValue:(id)value
{
    [super updateFromArchivedValue:value];
    
    _trainers = [@[] mutableCopy];
    for (id trainer in value)
    {
        [((NSMutableArray*)_trainers) addObject:[[Trainer alloc] initWithArchivedValue:trainer]];
    }
}

- (void)setLatitude:(float)latitude
          longitude:(float)longitude
              range:(float)range
{
    _location.latitude = latitude;
    _location.longitude = longitude;
    _range = range;
}

- (void)update
{
    if (_updating)
    {
        return;
    }
    
    _updating = YES;

    NSMutableDictionary * dict = [NSMutableDictionary new];
    dict[@"northeast_latitude"] = [NSString stringWithFormat:@"%f", (_location.latitude + _range)];
    dict[@"northeast_longitude"] = [NSString stringWithFormat:@"%f", (_location.longitude + _range)];
    dict[@"southwest_latitude"] = [NSString stringWithFormat:@"%f", (_location.latitude - _range)];
    dict[@"southwest_longitude"] = [NSString stringWithFormat:@"%f", (_location.longitude - _range)];
    
    [[ServerRequestQueue defaultQueue] addServerRequestForLink:ServerLinkTrainersList withBodyDict:dict completionHandler: ^(id result, NSError *error)
    {
        NSDictionary *userInfo = nil;
        
        if (error)
        {
            userInfo = @{ @"error" : error };
            _trainers = @[];
        }
        else
        {
            [self updateFromArchivedValue:result];
        }
        _updating = NO;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:TrainersListDidUpdateNotification object:self userInfo:userInfo];
    }];
}

@end
