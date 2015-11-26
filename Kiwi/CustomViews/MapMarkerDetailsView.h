//
//  MapMarkerDetailsView.h
//  Kiwi
//
//  Created by Crackman on 26.05.14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

@class Event;

@protocol MapMarkerDetailsDelegate <NSObject>

-(void)onDetailsInvokedForEvent:(Event*)event;

@end

@interface MapMarkerDetailsView : UIView

@property (nonatomic, readonly) Event * event;
@property (nonatomic) id<MapMarkerDetailsDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIButton *detailsButton;

-(id)initWithEvent:(Event*)event;

@end
