#import "ModelObject.h"

@class PLSCalendarDate;
@class Event;

@interface Promo : ModelObject

@property (nonatomic, readonly) Event *event;

@property (nonatomic, readonly) NSString *text;
@property (nonatomic, readonly) NSString *eventname;
@property (nonatomic, readonly) PLSCalendarDate * start;
@property (nonatomic, readonly) NSString * startString;
@property (nonatomic, readonly) float price;
@property (nonatomic, readonly) NSString *photoUrlStr;

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *lastname;
@property (nonatomic, readonly) NSString *fullName;

@end
