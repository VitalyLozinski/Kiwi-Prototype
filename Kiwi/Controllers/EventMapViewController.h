//
//  EventMapViewController.h
//  Kiwi
//
//  Created by Georgiy on 5/11/14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "FiltersViewController.h"
#import "MapMarkerDetailsView.h"

@class EventsList;

@interface EventMapViewController : UIViewController <MKMapViewDelegate, UITableViewDataSource, FiltersViewDelegate, UITableViewDelegate, MapMarkerDetailsDelegate>

@property (nonatomic, readonly) EventsList *eventsList;

-(void)goToEventDetails:(Event*)event;
-(void)centerOnEvent:(Event *)event;
-(BOOL)isIdle;
-(void)forceUpdateEventsForCurrentMap;

@end
