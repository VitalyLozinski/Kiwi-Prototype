#import "ModelObject.h"

#import <CoreLocation/CoreLocation.h>
#import "PLSCalendarDate.h"

typedef enum
{
    BodyMindEvent = 1,
    BuildEvent = 2,
    BurnEvent = 3,
} EventType;

@interface EventTypeObject : NSObject

-(id)initWith:(EventType)type;

@property EventType type;

@end

extern NSString * const EventDidUpdateNotification;
extern NSString * const EventBookDidFailNotification;
extern NSString * const EventBookDidFinishNotification;
extern NSString * const EventCancelDidFailNotification;
extern NSString * const EventCancelDidFinishNotification;
extern NSString * const EventRatingSaveDidFailNotification;
extern NSString * const EventRatingSaveDidFinishNotification;

@interface Event : ModelObject

@property (nonatomic, readonly) BOOL valid;

@property (nonatomic, readonly) NSString *eventname;
@property (nonatomic, readonly) EventType type;
@property (nonatomic, readonly) NSString *description;
@property (nonatomic, readonly) CLLocation * location;
@property (nonatomic, readonly) NSString * address;
@property (nonatomic, readonly) PLSCalendarDate * start;
@property (nonatomic, readonly) NSString * startString;
@property (nonatomic, readonly) BOOL showRating;
@property (nonatomic, readonly) int myRating;
@property (nonatomic, readonly) int votesCount;
@property (nonatomic, readonly) float rating;
@property (nonatomic, readonly) float price;
@property (nonatomic, readonly) NSInteger freeSeats;
@property (nonatomic, readonly) NSInteger totalSeats;
@property (nonatomic, readonly) NSString *photoUrlStr;

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *lastname;
@property (nonatomic, readonly) NSString *fullName;
@property (nonatomic, readonly) NSString *shortName;
@property (nonatomic, readonly) NSString *profileTitle;
@property (nonatomic, readonly) NSString *profile;

@property (nonatomic) BOOL rated;
@property (nonatomic, readonly) BOOL booked;
@property (nonatomic, readonly) BOOL canceled;
@property (nonatomic, readonly) BOOL finished;
@property (nonatomic, readonly) NSInteger passImage;
@property (nonatomic, readonly) NSInteger passColor;

- (NSString *)fullName;

- (void)update;
- (void)updateFor:(NSString*)detailId;

- (void)book:(NSDictionary *)paymentInfo;
- (void)rate:(NSInteger)stars;
- (void)rate:(NSInteger)stars comment:(NSString*)text;
- (void)cancel;

@end
