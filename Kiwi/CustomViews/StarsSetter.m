#import "StarsSetter.h"

@implementation StarsSetter
{
    NSArray * _images;
}

-(id)initBigStars
{
    return [self initWithPrefix:@"BigStar"];
}

-(id)initStars
{
    return [self initWithPrefix:@"Star"];
}

-(id)initSmallStars
{
    return [self initWithPrefix:@"SmallStar"];
}

-(id)initWithPrefix:(NSString*)prefix
{
    if (self = [super init])
    {
        _images = @[
                    [UIImage imageNamed:[NSString stringWithFormat:@"%@0", prefix]],
                    [UIImage imageNamed:[NSString stringWithFormat:@"%@25", prefix]],
                    [UIImage imageNamed:[NSString stringWithFormat:@"%@50", prefix]],
                    [UIImage imageNamed:[NSString stringWithFormat:@"%@75", prefix]],
                    [UIImage imageNamed:[NSString stringWithFormat:@"%@100", prefix]],
                    ];
    }
    return self;
}

-(void)setImage:(UIImage*)image for:(UIImageView*)imageView
{
    imageView.highlighted = false;
    [imageView setImage:image];
    [imageView setHighlightedImage:image];
}

-(void)setImage:(float)rating for:(UIImageView*)imageView at:(NSInteger)index
{
    if (index < (int)rating)
    {
        //Trace(@"Star:    Full");
        [self setImage:(UIImage*)_images[_images.count - 1] for:imageView];
    }
    else if (index > (int)rating)
    {
        //Trace(@"Star:    Empty");
        [self setImage:(UIImage*)_images[0] for:imageView];
    }
    else
    {
        float f = (rating - (int)rating);
        float ff = f * (_images.count - 1) + 0.5f;
        int i = MAX(0, MIN((int)(ff), (int)_images.count - 1));
        //Trace(@"Star:    %4.2f -> %4.2f -> %i / %i", f, ff, i, _images.count);
        [self setImage:(UIImage*)_images[i] for:imageView];
    }
}

@end
