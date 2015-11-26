//
//  MapMarkerView.m
//  Kiwi
//
//  Created by Crackman on 20.05.14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

#import "MapMarker.h"

#import "Event.h"

@interface MapMarker()

@property (weak, nonatomic) IBOutlet UIImageView *image;

@end

@implementation MapMarker

-(id)initWithEvent:(Event*)event
{
    NSArray * nibContents = [[NSBundle mainBundle] loadNibNamed:@"MapMarker"
                                                          owner:nil
                                                        options:nil];
    if (nibContents && nibContents.count > 0)
    {
        self = nibContents.lastObject;
    }
    if (self)
    {
        _event = event;
        _eventsGroup = nil;
        _coordinate = event.location.coordinate;
        switch (_event.type)
        {
            case BuildEvent:
                self.image.image = [UIImage imageNamed:@"MapClassPinBuild"];
                break;
            case BurnEvent:
                self.image.image = [UIImage imageNamed:@"MapClassPinBurn"];
                break;
            case BodyMindEvent:
            default:
                self.image.image = [UIImage imageNamed:@"MapClassPinBodyMind"];
                break;
        }
        self.enabled = YES;
        self.canShowCallout = NO;
    }
    return self;
}

-(id)initWithEvent:(Event*)event at:(CLLocationCoordinate2D)coordinate
{
    NSArray * nibContents = [[NSBundle mainBundle] loadNibNamed:@"MapMarker"
                                                          owner:nil
                                                        options:nil];
    if (nibContents && nibContents.count > 0)
    {
        self = nibContents.lastObject;
    }
    if (self)
    {
        _event = event;
        _eventsGroup = nil;
        _coordinate = coordinate;
        switch (_event.type)
        {
            case BuildEvent:
                self.image.image = [UIImage imageNamed:@"MapClassIconBuild"];
                break;
            case BurnEvent:
                self.image.image = [UIImage imageNamed:@"MapClassIconBurn"];
                break;
            case BodyMindEvent:
            default:
                self.image.image = [UIImage imageNamed:@"MapClassIconBodyMind"];
                break;
        }
        self.enabled = YES;
        self.canShowCallout = NO;
    }
    return self;
}

-(id)initWithEventsGroup:(NSArray*)events at:(CLLocationCoordinate2D)coordinate
{
    NSArray * nibContents = [[NSBundle mainBundle] loadNibNamed:@"MapMarker"
                                                          owner:nil
                                                        options:nil];
    if (nibContents && nibContents.count > 0)
    {
        self = nibContents.lastObject;
    }
    if (self)
    {
        _event = nil;
        _eventsGroup = [events copy];
        _coordinate = coordinate;
        self.image.image = [UIImage imageNamed:@"MapClassPinGroup"];
        self.enabled = YES;
        self.canShowCallout = NO;
    }
    return self;
}

-(NSString*)title
{
    if (_event == nil)
    {
        return InterfaceString(@"EventsGroupTitle");
    }
    return _event.eventname;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    _coordinate = newCoordinate;
}

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent*)event
{
    UIView* hitView = [super hitTest:point withEvent:event];
    if (hitView != nil)
    {
        [self.superview bringSubviewToFront:self];
    }
    return hitView;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event
{
    CGRect rect = self.bounds;
    BOOL isInside = CGRectContainsPoint(rect, point);
    if(!isInside)
    {
        for (UIView *view in self.subviews)
        {
            isInside = CGRectContainsPoint(view.frame, point);
            if(isInside)
                break;
        }
    }
    return isInside;
}

@end
