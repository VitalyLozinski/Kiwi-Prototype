#import "Promo.h"
#import "Event.h"
#import "PLSCalendarDate.h"

@implementation Promo
{
    NSString * _id;
}

static NSDateFormatter *eventDateFormatter;

-(id)init
{
    self = [super init];
    _event = [Event new];
    return self;
}

- (void)updateFromArchivedValue:(id)value
{
    if ([value isKindOfClass:[NSDictionary class]])
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            eventDateFormatter = [NSDateFormatter new];
            eventDateFormatter.dateFormat = ModelDateTimeFormat;
            eventDateFormatter.timeZone = [NSTimeZone timeZoneWithName:ModelTimeZone];
        });
        
        _id = [value objectForKey:@"id_promo"];
        _text = value[@"promotext"];
        _photoUrlStr = value[@"photo"];
        _name = value[@"trainer_name"];
        _lastname = value[@"trainer_lastname"];
        _eventname = value[@"event_name"];
        _price = [[value objectForKey:@"price"] floatValue];
        NSString *startStr = value[@"start"];
        _start = [[eventDateFormatter dateFromString:startStr] calendarDateCopy];
        
        [_event updateFor:[value objectForKey:@"eventdetail_id"]];
    }
}

- (NSString *)fullName
{
    return [NSString stringWithFormat:@"%@ %@", _name, _lastname];
}

@end
