#import "TimeSpan.h"
#import "PLSCalendarDate.h"

@implementation TimeSpan

-(id)initFrom:(PLSCalendarDate*)from to:(PLSCalendarDate*)to
{
    self = [super init];
    if (self)
    {
        _to = to;
        _from = from;
    }
    return self;
}

@end
