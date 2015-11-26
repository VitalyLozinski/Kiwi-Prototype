//
//  FiltersViewController.h
//  Kiwi
//
//  Created by Crackman on 25.05.14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DatePickerViewController.h"

@class EventsFilter;

@protocol FiltersViewDelegate <NSObject>

-(void)applyFilter:(EventsFilter*)filter;

@end

@interface FiltersViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) id<FiltersViewDelegate> delegate;

- (void)setLatitude:(float)latitude
          longitude:(float)longitude
              range:(float)range;
-(void)reset;

-(void)appearIn:(UIViewController*)parent;
-(void)disappear;


@end
