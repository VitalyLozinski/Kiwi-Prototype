#import "EventsList.h"
#import "Event.h"

#import "ServerRequestQueue.h"
#import "EventsFilter.h"
#import "TimeSpan.h"

#import "Event.h"
#import "User.h"

NSString * const EventsListDidUpdateNotification = @"EventsListDidUpdateNotification";

@implementation EventsList

- (void)updateFromArchivedValue:(id)value
{
    [super updateFromArchivedValue:value];
    
    _events = [@[] mutableCopy];
    for (id event in value)
    {
        [((NSMutableArray*)_events) addObject:[[Event alloc] initWithArchivedValue:event]];
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

- (void)setFilter:(EventsFilter*)filter
{
    _filter = filter;
}

static NSDateFormatter *eventFilterDateFormatter;

- (void)update
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        eventFilterDateFormatter = [NSDateFormatter new];
        eventFilterDateFormatter.dateFormat = ModelDateTimeFormat;
        eventFilterDateFormatter.timeZone = [NSTimeZone timeZoneWithName:ModelTimeZone];
    });
    
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
    
    if (_filter)
    {
        if (_filter.eventTypes && _filter.eventTypes.count > 0)
        {
            NSMutableArray * strings = [NSMutableArray new];
            for (EventTypeObject * event in _filter.eventTypes)
            {
                [strings addObject:[NSString stringWithFormat:@"%ld", (long)(event.type)]];
            }
            dict[@"event_types"] = strings;
        }
        if (_filter.instructors && _filter.instructors.count > 0)
        {
            NSMutableArray * strings = [NSMutableArray new];
            for (NSString * instructor in _filter.instructors)
            {
                [strings addObject:[NSString stringWithFormat:@"%@", instructor]];
            }
            dict[@"instructors"] = strings;
        }
        
        NSMutableArray * periods = [NSMutableArray new];
        if (_filter.timeSpans && _filter.timeSpans.count > 0)
        {
            for (TimeSpan * timeSpan in _filter.timeSpans)
            {
                [periods addObject:@{ @"from" : [eventFilterDateFormatter stringFromDate:timeSpan.from],
                                      @"to" : [eventFilterDateFormatter stringFromDate:timeSpan.to],
                                    }];
            }
        }
        if (_filter.hereAndNow)
        {
            NSDate * from = [NSDate dateWithTimeIntervalSinceNow:0];
            NSDate * to = [NSDate dateWithTimeIntervalSinceNow:60 * 60 * 2];
            [periods addObject:@{ @"from" : [eventFilterDateFormatter stringFromDate:from],
                                  @"to" : [eventFilterDateFormatter stringFromDate:to],
                                  }];
        }
        if (periods.count > 0)
        {
            dict[@"periods"] = periods;
        }
        
        if (_filter.bookedOnly)
        {
            dict[@"bookedonly"] = @"1";
        }
    }
    
    [[ServerRequestQueue defaultQueue] addServerRequestForLink:ServerLinkEventsList withBodyDict:dict completionHandler: ^(id result, NSError *error)
    {
        NSDictionary *userInfo = nil;
        
        if (error)
        {
            userInfo = @{ @"error" : error };
            _events = @[];
        }
        else
        {
            [self updateFromArchivedValue:result];
        }
        _updating = NO;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:EventsListDidUpdateNotification object:self userInfo:userInfo];
    }];
}

@end
