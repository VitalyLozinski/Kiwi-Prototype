#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapOverlay : MKCircle<MKOverlay>

-(id)initWithCoordinate:(CLLocationCoordinate2D)coordinate
                 radius:(double)radius;

@end
