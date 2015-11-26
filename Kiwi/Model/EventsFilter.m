#import "EventsFilter.h"
#import "TimeSpan.h"

@implementation EventsFilter

-(id)init
{
    self = [super init];
    if (self)
    {
        [self reset];
    }
    return self;
}

-(void)reset
{
    _eventTypes = [NSMutableArray arrayWithArray: @[]];
    _instructors = [NSMutableArray arrayWithArray: @[]];
    _timeSpans = [NSMutableArray arrayWithArray: @[]];
    _hereAndNow = NO;
}

-(void)addEventType:(EventType)type
{
    [self removeEventType:type];
    [((NSMutableArray*)_eventTypes) addObject:[[EventTypeObject alloc] initWith:type]];
}

-(void)removeEventType:(EventType)type
{
    for (EventTypeObject * t in _eventTypes)
    {
        if (t.type == type)
        {
            [((NSMutableArray*)_eventTypes) removeObject:t];
        }
    }
}

-(void)addInstructor:(NSString*)instructor
{
    [self removeInstructor:instructor];
    [((NSMutableArray*)_instructors) addObject:instructor];
}

-(void)removeInstructor:(NSString*)instructor
{
    for (NSString * i in _instructors)
    {
        if ([i isEqualToString:instructor])
        {
            [((NSMutableArray*)_instructors) removeObject:i];
        }
    }
}

-(void)addTimeSpan:(TimeSpan*)timeSpan
{
    [self removeTimeSpan:timeSpan];
    [((NSMutableArray*)_timeSpans) addObject:timeSpan];
}

-(void)removeTimeSpan:(TimeSpan*)timeSpan
{
    for (TimeSpan * t in _timeSpans)
    {
        if ([t.from compare:timeSpan.from] == NSOrderedSame &&
            [t.to compare:timeSpan.to] == NSOrderedSame)
        {
            [((NSMutableArray*)_timeSpans) removeObject:t];
        }
    }
}

@end
