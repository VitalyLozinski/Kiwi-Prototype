#import <Foundation/Foundation.h>

@class PLSCalendarDate;

@interface TimeSpan : NSObject

@property PLSCalendarDate * from;
@property PLSCalendarDate * to;

-(id)initFrom:(PLSCalendarDate*)from to:(PLSCalendarDate*)to;

@end
