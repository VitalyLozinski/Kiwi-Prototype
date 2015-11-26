#import "MapOverlay.h"

@implementation MapOverlay
{
    CLLocationCoordinate2D _coordinate;
    double _radius;
}

-(id)initWithCoordinate:(CLLocationCoordinate2D)coordinate
                 radius:(double)radius
{
    self = [super init];
    if (self)
    {
        _radius = radius;
        _coordinate = coordinate;
    }
    return self;
}

- (CLLocationCoordinate2D)coordinate
{
    return _coordinate;
}

- (double)radius
{
    return _radius;
}

- (MKMapRect)boundingMapRect
{
    MKMapPoint upperLeft = MKMapPointForCoordinate(self.coordinate);
    MKMapRect bounds = MKMapRectMake(upperLeft.x - _radius, upperLeft.y - _radius, _radius, _radius);
    return bounds;
}

@end
