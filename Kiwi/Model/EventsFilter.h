#import <Foundation/Foundation.h>

#import "Event.h"

@class TimeSpan;

@interface EventsFilter : NSObject

@property (nonatomic) NSArray * eventTypes;
@property (nonatomic) NSArray * instructors;
@property (nonatomic) NSArray * timeSpans;
@property (nonatomic) BOOL hereAndNow;
@property (nonatomic) BOOL bookedOnly;

-(void)reset;

-(void)addEventType:(EventType)type;
-(void)removeEventType:(EventType)type;

-(void)addInstructor:(NSString*)instructor;
-(void)removeInstructor:(NSString*)instructor;

-(void)addTimeSpan:(TimeSpan*)timeSpan;
-(void)removeTimeSpan:(TimeSpan*)timeSpan;

@end
