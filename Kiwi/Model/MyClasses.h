#import "ModelObject.h"
#import <MapKit/MapKit.h>

extern NSString * const MyClassesDidUpdateNotification;

@interface MyClassesList : ModelObject

@property (nonatomic, readonly) NSArray *events;
@property (nonatomic, readonly) NSArray *currentEvents;
@property (nonatomic, readonly) NSArray *eventsToRate;
@property (nonatomic, readonly) BOOL updating;

+ (instancetype)sharedInstance;
- (void)update;

@end
