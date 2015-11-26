#import "ModelObject.h"

@interface Trainer : ModelObject

@property (nonatomic, readonly) NSString *trainerId;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *lastname;
@property (nonatomic, readonly) BOOL showRating;
@property (nonatomic, readonly) int myRating;
@property (nonatomic, readonly) int votesCount;
@property (nonatomic, readonly) float rating;
@property (nonatomic, readonly) NSString *photoUrlStr;

-(NSString*)instructor;

@end
