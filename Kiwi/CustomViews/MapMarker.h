//
//  MapMarkerView.h
//  Kiwi
//
//  Created by Crackman on 20.05.14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

#import <MapKit/MapKit.h>

@class Event;

@interface MapMarker : MKAnnotationView<MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly) Event * event;
@property (nonatomic, readonly) NSArray * eventsGroup;

-(id)initWithEvent:(Event*)event;
-(id)initWithEvent:(Event*)event at:(CLLocationCoordinate2D)coordinate;
-(id)initWithEventsGroup:(NSArray*)events at:(CLLocationCoordinate2D)coordinate;

@end
