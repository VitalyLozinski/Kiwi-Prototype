#import "MyClasses.h"
#import "Event.h"

#import "ServerRequestQueue.h"

#import "Event.h"
#import "User.h"
#import "Conventions.h"

NSString * const MyClassesDidUpdateNotification = @"MyClassesDidUpdateNotification";

@implementation MyClassesList

+ (instancetype)sharedInstance
{
	static MyClassesList *sSharedInstance = nil;
	static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        sSharedInstance = [MyClassesList new];
    });
	return sSharedInstance;
}

- (void)updateFromArchivedValue:(id)value
{
    [super updateFromArchivedValue:value];
    
    _events = [@[] mutableCopy];
    _eventsToRate = [@[] mutableCopy];
    _currentEvents = [@[] mutableCopy];
    for (id event in value)
    {
        Event * newEvent = [[Event alloc] initWithArchivedValue:event];
        if (newEvent.canceled)
            continue;
        [((NSMutableArray*)_events) addObject:newEvent];
        
        NSTimeInterval diff = [newEvent.start timeIntervalSinceNow];
        
        Trace(@"Event %@ (%@) diff from now is %4.2f", newEvent.eventname, newEvent.startString, diff);
        
        if (abs(diff) < 60 * 15)
        {
            [((NSMutableArray*)_currentEvents) addObject:newEvent];
        }
        
        if (diff < -(60 * 20) &&
            diff > -(60 * 60 * 24 * 7) &&
            !newEvent.rated)
        {
            [((NSMutableArray*)_eventsToRate) addObject:newEvent];
        }
    }
    
    _eventsToRate = [_eventsToRate sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2)
    {
        return [((Event*)obj1).start compare:((Event*)obj2).start];
    }];
    
    Trace(@"Current events: %i, Events to rate: %i", _currentEvents.count, _eventsToRate.count);
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
    
    [[ServerRequestQueue defaultQueue] addServerRequestForLink:ServerLinkMyClasses withBodyDict:dict completionHandler: ^(id result, NSError *error)
     {
         NSDictionary *userInfo = nil;
         
         if (error)
         {
             userInfo = @{ @"error" : error };
             _events = @[];
             _eventsToRate = @[];
             _currentEvents = @[];
         }
         else
         {
             [self updateFromArchivedValue:result];
         }
         _updating = NO;
         
         [[NSNotificationCenter defaultCenter] postNotificationName:MyClassesDidUpdateNotification object:self userInfo:userInfo];
     }];
}

@end
