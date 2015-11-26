#import <Foundation/Foundation.h>

@interface StarsSetter : NSObject

-(id)initBigStars;
-(id)initStars;
-(id)initSmallStars;

-(void)setImage:(float)rating for:(UIImageView*)imageView at:(NSInteger)index;

@end
