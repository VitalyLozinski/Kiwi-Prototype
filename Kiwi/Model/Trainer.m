#import "Trainer.h"

#import "ServerRequestQueue.h"

@implementation Trainer

- (void)updateFromArchivedValue:(id)value
{
    if ([value isKindOfClass:[NSDictionary class]])
    {
        _trainerId = [value objectForKey:@"trainer_id"];
        _photoUrlStr = value[@"photo"];
        if (!_photoUrlStr || [_photoUrlStr isKindOfClass:[NSString class]])
            _photoUrlStr = @"";
        
        _rating = [[value objectForKey:@"avg_rating"] floatValue];
        _myRating = [[value objectForKey:@"my_rating"] integerValue];
        _votesCount = [[value objectForKey:@"count_rating"] integerValue];
        
        _showRating = ([[value objectForKey:@"show_rating"] integerValue] != 0);
        
        _name = [value objectForKey:@"name"];
        _lastname = [value objectForKey:@"lastname"];
    }
}

- (NSString *)instructor
{
    return [NSString stringWithFormat:@"%@ %@", _name, _lastname];
}

@end
