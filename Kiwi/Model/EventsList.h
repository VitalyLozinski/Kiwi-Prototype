#import "ModelObject.h"
#import <MapKit/MapKit.h>

extern NSString * const EventsListDidUpdateNotification;

@class EventsFilter;

@interface EventsList : ModelObject

@property (nonatomic, readonly) CLLocationCoordinate2D location;
@property (nonatomic, readonly) EventsFilter * filter;
@property (nonatomic, readonly) float range;
@property (nonatomic, readonly) NSArray *events;
@property (nonatomic, readonly) BOOL updating;

- (void)setLatitude:(float)latitude
          longitude:(float)longitude
              range:(float)range;
- (void)setFilter:(EventsFilter*)filter;
- (void)update;

@end
