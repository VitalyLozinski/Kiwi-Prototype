#import "ModelObject.h"
#import <MapKit/MapKit.h>

extern NSString * const TrainersListDidUpdateNotification;

@interface TrainersList : ModelObject

@property (nonatomic, readonly) CLLocationCoordinate2D location;
@property (nonatomic, readonly) float range;
@property (nonatomic, readonly) NSArray *trainers;
@property (nonatomic, readonly) BOOL updating;

- (void)setLatitude:(float)latitude
          longitude:(float)longitude
              range:(float)range;
- (void)update;

@end
