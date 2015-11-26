//
//  EventMapViewController.m
//  Kiwi
//
//  Created by Georgiy on 5/11/14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

#import "EventMapViewController.h"
#import "LocationController.h"
#import "EventsList.h"
#import "EventsFilter.h"
#import "Event.h"
#import "User.h"
#import "ClassDetailsController.h"
#import "MainNavigationController.h"
#import "MapMarkerDetailsView.h"

#import "EventTableCell.h"
#import "MapMarker.h"
#import "MapOverlay.h"
#import "MapGroupRenderer.h"

#import "UIFont+AppFonts.h"
#import "UIColor+AppColors.h"
#import "UIView+App.h"

#import "FiltersViewController.h"

#import "ClassDetailsController.h"
#import "NSObject+GoogleAnalytics.h"

NSString * LatitudeKey = @"EMVC_Latitude";
NSString * LongitudeKey = @"EMVC_Longitude";
NSString * LatitudeSpanKey = @"EMVC_LatitudeSpan";
NSString * LongitudeSpanKey = @"EMVC_LongitudeSpan";

static NSString * const sEventCellIdentifier = @"MapEventCell";

@interface EventMapViewController ()
{
    NSMutableArray * _markers;
    
    BOOL _locateScheduled;
    BOOL _eventsUpdateScheduled;
    
    UIBarButtonItem * _viewToggle;
    
    BOOL _filtersVisible;
    FiltersViewController * _filtersController;
    
    BOOL _forceEventsUpdate;
    
    MapMarker * _expandedMarker;
    MapMarker * _prevMarkerSelection;
    MapMarker * _nextMarkerSelection;
    BOOL _handlingMarkerSwitch;
    
    NSArray * _sortedEvents;
    
    float _zoom;
}

@property (weak, nonatomic) IBOutlet UIView *mapContainer;
@property (weak, nonatomic) IBOutlet UIView *listContainer;

@property (weak, nonatomic) IBOutlet MKMapView *map;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UIButton *filterButton;

@property (weak, nonatomic) IBOutlet UITableView *table;

@property (weak, nonatomic) IBOutlet UIView *filtersContainer;

@end

@implementation EventMapViewController

#pragma mark - view lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _viewToggle = [[UIBarButtonItem alloc] initWithTitle:InterfaceString(@"EventsListView")
                                                       style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:@selector(toggleView:)];
        [_viewToggle setTitleTextAttributes: @{NSFontAttributeName : [UIFont regularAppFontOfSize:14]} forState:UIControlStateNormal];
        [_viewToggle setTitlePositionAdjustment:UIOffsetMake(-8, 0) forBarMetrics:UIBarMetricsDefault];
        self.navigationItem.rightBarButtonItem = _viewToggle;
        
        self.title = InterfaceString(@"EventMapTitle");
        
        _markers = [NSMutableArray arrayWithArray:@[]];
        _eventsList = [EventsList new];
        
        _eventsUpdateScheduled = NO;
        _locateScheduled = YES;
        _forceEventsUpdate = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventsListDidUpdate:) name:EventsListDidUpdateNotification object:_eventsList];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidUpdate:) name:LocationDidUpdateNotification object:[LocationController sharedController]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoggedIn:) name:UserDidLoginNotification object:[User currentUser]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuStateChanged:) name:MenuStateChangedNotification object:nil];
        
        _filtersController = [FiltersViewController new];
        _filtersController.view.frame = self.view.frame;
        _filtersController.delegate = self;
        
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _searchField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 12)];
    _searchField.leftViewMode = UITextFieldViewModeAlways;
    _searchField.placeholder = InterfaceString(@"SearchBarPlaceholder");
    _searchField.font = [UIFont regularAppFontOfSize:14];
    _filterButton.titleLabel.font = [UIFont regularAppFontOfSize:14];
    
        [_table registerNib:[UINib nibWithNibName:NSStringFromClass([EventTableCell class]) bundle:nil] forCellReuseIdentifier:sEventCellIdentifier];
    _table.dataSource = self;
    _table.delegate = self;

    _map.delegate = self;
    
    [self restoreAnchor];
    
    UISwipeGestureRecognizer *filtersSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    [filtersSwipe setDirection:UISwipeGestureRecognizerDirectionUp];
    [_filterButton addGestureRecognizer:filtersSwipe];
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)swipe
{
    if (swipe.direction == UISwipeGestureRecognizerDirectionUp &&
        swipe.view == _filterButton)
    {
        [self filterButtonClicked:_filterButton];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self hideAllPopups];
}

-(BOOL)isIdle
{
    return self.mapContainer.hidden || _expandedMarker == nil;
}

- (void)hideMenu
{
    [[MainNavigationController rootInstance] setMenuOpened:NO animated:YES];
}

- (void)hideFilters
{
    [_filtersController disappear];
}

- (void)hideSearchBar
{
    _searchField.hidden = YES;
    [[self view] endEditing:YES];
}

- (void)hideAllPopups
{
    [self hideMenu];
    [self hideFilters];
    [self hideSearchBar];
}

#pragma mark - notification processing

- (void)locationDidUpdate:(NSNotification *)ntf
{
    CLLocationCoordinate2D coord = [LocationController sharedController].userLocation.coordinate;
    if (coord.latitude == 0 && coord.longitude == 0)
    {
        Trace(@"Location unavailable, using current view value");
        coord = self.map.centerCoordinate;
    }
    
    Trace(@"Location updated: %f, %f", coord.latitude, coord.longitude);
    
    if (_locateScheduled)
    {
        _locateScheduled = NO;
        [self.map setCenterCoordinate:coord animated:YES];
    }
    
    if ([User currentUser].loggedIn)
    {
        if (_eventsUpdateScheduled)
        {
            _eventsUpdateScheduled = NO;
            [self updateEventsForCurrentMap];
        }
    }
}

- (void)eventsListDidUpdate:(NSNotification *)ntf
{
    Trace(@"Events list updated: %i events", _eventsList.events.count);
    
    _expandedMarker = nil;
    
    dispatch_async(dispatch_get_main_queue(),^
    {
        if (_eventsList.events.count == 0 &&
            _eventsList.filter.hereAndNow)
        {
            UIAlertView * alert = [[UIAlertView alloc]
                                       initWithTitle:InterfaceString(@"NoRightHereRightNowTitle")
                                             message:InterfaceString(@"NoRightHereRightNowText")
                                            delegate:nil
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil];
            [alert show];
            _eventsList.filter.hereAndNow = NO;
            return;
        }
        _eventsList.filter.hereAndNow = NO;
        
        [self.map removeAnnotations:_markers];
        [self.map removeOverlays:self.map.overlays];
        [_markers removeAllObjects];
        
        _sortedEvents = [_eventsList.events sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2)
        {
            return [((Event*)obj1).start compare:((Event*)obj2).start];
        }];
        
        NSMutableArray * eventGroups = [@[] mutableCopy];
        
        for (Event * newEvent in _sortedEvents)
        {
            BOOL duplicate = NO;
            NSMutableArray * matchingGroup = nil;
            
            for (NSMutableArray * group in eventGroups)
            {
                for (Event * oldEvent in group)
                {
                    if ([newEvent.location distanceFromLocation:oldEvent.location] < 0.001f)
                    {
                        matchingGroup = group;
                        
                        if ([newEvent.fullName isEqualToString:oldEvent.fullName]
                            && [newEvent.eventname isEqualToString:oldEvent.eventname]
                            )
                        {
                            duplicate = YES;
                        }
                    }
                }
            }
            if (duplicate)
            {
                continue;
            }
            if (matchingGroup)
            {
                [matchingGroup addObject:newEvent];
            }
            else
            {
                [eventGroups addObject:[@[newEvent] mutableCopy]];
            }
        }
        
        for (NSMutableArray * group in eventGroups)
        {
            if (group.count > 1)
            {
                MapMarker * marker = [[MapMarker alloc] initWithEventsGroup:group
                                                                         at:((Event*)group[0]).location.coordinate];
                [_markers addObject:marker];
            }
            else
            {
                MapMarker * marker = [[MapMarker alloc] initWithEvent:group[0]];
                [_markers addObject:marker];
            }
        }
        
        [self.map addAnnotations:_markers];
        
        [self.table reloadData];
        
        if (_eventsUpdateScheduled)
        {
            _eventsUpdateScheduled = NO;
            [self updateEventsForCurrentMap];
        }
    });
}

- (void)userLoggedIn:(NSNotification *)ntf
{
    if (ntf.userInfo)
    {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(),^
    {
        _forceEventsUpdate = YES;
        if (_locateScheduled)
        {
            _eventsUpdateScheduled = YES;
        }
        else
        {
            [self updateEventsForCurrentMap];
        }
    });
}

- (void)menuStateChanged:(NSNotification *)ntf
{
    if ([[MainNavigationController rootInstance] menuOpened]) {
        [self hideFilters];
        [self hideSearchBar];
    }
}

-(void)forceUpdateEventsForCurrentMap
{
    _forceEventsUpdate = YES;
    [self updateEventsForCurrentMap];
}

-(void)updateEventsForCurrentMap
{
    if (!_forceEventsUpdate)
    {
        CLLocation * dataCenter = [[CLLocation alloc] initWithLatitude:_eventsList.location.latitude
                                                        longitude:_eventsList.location.longitude];
    
        CLLocation * mapCenter = [[CLLocation alloc] initWithLatitude:self.map.centerCoordinate.latitude
                                                        longitude:self.map.centerCoordinate.longitude];
    
        if (fabs(dataCenter.coordinate.latitude - mapCenter.coordinate.latitude) < _eventsList.range / 2 &&
            fabs(dataCenter.coordinate.longitude - mapCenter.coordinate.longitude) < _eventsList.range / 2)
        {
            return;
        }
    }
    
    _forceEventsUpdate = NO;
    
    [_eventsList setLatitude:self.map.centerCoordinate.latitude
                   longitude:self.map.centerCoordinate.longitude
                       range:(MAX((self.map.region.span.latitudeDelta),
                                  (self.map.region.span.longitudeDelta)) * 2)];
    [_eventsList update];
    
    [_filtersController setLatitude:self.map.centerCoordinate.latitude
                          longitude:self.map.centerCoordinate.longitude
                              range:(MAX((self.map.region.span.latitudeDelta),
                                         (self.map.region.span.longitudeDelta)) * 2)];
    
}

#pragma mark - action processing

- (IBAction)locateButtonClicked:(id)sender
{
    [self hideAllPopups];
    _eventsList.filter.hereAndNow = NO;
    [self locate];
}

- (IBAction)searchButtonClicked:(id)sender
{
    if (self.searchField.hidden)
    {
        [self hideAllPopups];
        self.searchField.hidden = NO;
        self.searchField.text = @"";
        [self.searchField becomeFirstResponder];
    }
    else
    {
        [self hideAllPopups];
    }
}

- (IBAction)onSearchQueryEntered:(id)sender
{
    [self hideAllPopups];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:self.searchField.text
                 completionHandler:^(NSArray *placemarks, NSError *error)
    {
        double distance = CLLocationDistanceMax;
        CLPlacemark * bestMatch = nil;
        if (placemarks && placemarks.count > 0)
        {
            CLLocation * center = [[CLLocation alloc] initWithLatitude:self.map.centerCoordinate.latitude
                                                             longitude:self.map.centerCoordinate.longitude];
            for (int i = 0; i < placemarks.count; ++i)
            {
                CLPlacemark * placemark = [placemarks objectAtIndex:i];
                
                double d = [center distanceFromLocation:placemark.location];
                if (d < distance)
                {
                    distance = d;
                    bestMatch = placemark;
                }
            }
            
            Trace(@"Search '%@' gave %lu results, picking closest one: %@",
                  self.searchField.text,
                  (unsigned long)placemarks.count,
                  bestMatch.description);
        }
        
        if (bestMatch)
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [self.map setRegion:MKCoordinateRegionMakeWithDistance(self.map.centerCoordinate,
                                                                 ((CLCircularRegion*)bestMatch.region).radius,
                                                                   ((CLCircularRegion*)bestMatch.region).radius) animated:NO];
                [self.map setCenterCoordinate:bestMatch.location.coordinate animated:YES];
                _eventsList.filter.hereAndNow = NO;
                [self updateEventsForCurrentMap];
            });
        }
    }];
}

- (IBAction)filterButtonClicked:(id)sender
{
    [self hideMenu];
    [self hideSearchBar];

    [_filtersController appearIn:self];
}

-(void)toggleView:(id)sender
{
    [self gaiScreen:GaiMapListSwap];
    [self hideAllPopups];
    if (!self.mapContainer.isHidden)
    {
        _viewToggle.title = InterfaceString(@"EventsMapView");
        self.mapContainer.hidden = NO;
        self.listContainer.hidden = NO;
        [self.listContainer valign:-self.listContainer.bounds.size.height];
        [UIView animateWithDuration:0.5f animations:^
        {
            [self.listContainer valign:0];
            [self.mapContainer valign:self.listContainer.bounds.size.height];
        }
        completion:^(BOOL finished)
        {
            if (finished)
            {
                self.mapContainer.hidden = YES;
                self.listContainer.hidden = NO;
            }
        }];
    }
    else
    {
        _viewToggle.title = InterfaceString(@"EventsListView");
        self.mapContainer.hidden = NO;
        self.listContainer.hidden = NO;
        [self.mapContainer valign:self.listContainer.bounds.size.height];
        [UIView animateWithDuration:0.5f animations:^
        {
            [self.listContainer valign:-self.listContainer.bounds.size.height];
            [self.mapContainer valign:0];
        }
        completion:^(BOOL finished)
        {
            if (finished)
            {
                self.mapContainer.hidden = NO;
                self.listContainer.hidden = YES;
            }
        }];
    }
}

#pragma mark - FiltersViewDelegate

- (void)applyFilter:(EventsFilter *)filter
{
    [_eventsList setFilter:filter];
    _forceEventsUpdate = YES;
    if (filter.hereAndNow)
    {
        _map.region = MKCoordinateRegionMakeWithDistance(_map.region.center,
                                                         10000, 10000);
        [self locate];
    }
    else
    {
        [self updateEventsForCurrentMap];
    }
}

#pragma mark - MKMapView delegate


-(void)expandGroup:(MapMarker*)marker inMap:(MKMapView *)mapView
{
    _expandedMarker = marker;
    NSMutableArray * otherMarkers = [_markers mutableCopy];
    [otherMarkers removeObject:marker];
    
    [self.map removeAnnotations:otherMarkers];
    [_markers removeObjectsInArray:otherMarkers];
    
    NSArray * eventsGroup = marker.eventsGroup;
    CLLocationCoordinate2D center = ((Event*)eventsGroup[0]).location.coordinate;
    float angle = 0;
    float step = 6.28f / eventsGroup.count;
    double range = MIN(mapView.region.span.latitudeDelta,
                      mapView.region.span.longitudeDelta) * 0.15;
    
    MKCircle * mapOverlay = [MKCircle circleWithCenterCoordinate:center radius:range * 90000];
    [mapView addOverlay:mapOverlay];
    
    NSMutableArray * newMarkers = [@[] mutableCopy];
    for (Event * event in eventsGroup)
    {
        CLLocationCoordinate2D coord = center;
        coord.latitude += sinf(angle) * range;
        coord.longitude += cosf(angle) * range;
        
        angle += step;
        
        MapMarker * newMarker = [[MapMarker alloc] initWithEvent:event at:coord];
        [newMarkers addObject:newMarker];
    }
    [mapView addAnnotations:newMarkers];
    [_markers addObjectsFromArray:newMarkers];
}

-(void)collapseGroup
{
    [self eventsListDidUpdate:nil];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay
{
    return [[MapGroupRenderer alloc] initWithOverlay:overlay];
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation
{
    MKAnnotationView * result = nil;
    if (annotation != self.map.userLocation)
    {
        result = _markers[[_markers indexOfObjectPassingTest:^BOOL(MapMarker *marker, NSUInteger idx, BOOL *stop) {
            return (annotation == marker);
        }]];
    }
    
    [mapView bringSubviewToFront:result];
    
    return result;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if([view.annotation isKindOfClass:[MKUserLocation class]])
    {
        return;
    }
    
    _nextMarkerSelection = (MapMarker*)view;
    if (!_prevMarkerSelection)
    {
        MapMarker * next = _nextMarkerSelection;
        _prevMarkerSelection = nil;
        _nextMarkerSelection = nil;
        [self mapView:mapView
        didSwitchFrom:nil
                   to:next];
    }
}

-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    _prevMarkerSelection = (MapMarker*)view;
    _nextMarkerSelection = nil;
    
    dispatch_async(dispatch_get_main_queue(), ^
    {
        MapMarker * prev = _prevMarkerSelection;
        MapMarker * next = _nextMarkerSelection;
        _prevMarkerSelection = nil;
        _nextMarkerSelection = nil;
        [self mapView:mapView
        didSwitchFrom:prev
                   to:next];
    });
}

-(void)mapView:(MKMapView *)mapView
 didSwitchFrom:(MapMarker *)from
            to:(MapMarker *)to
{
    if (_handlingMarkerSwitch)
    {
        return;
    }
    _handlingMarkerSwitch = YES;
    
    if (_expandedMarker)
    {
        if (from != nil && from != _expandedMarker)
        {
            [from.rightCalloutAccessoryView removeFromSuperview];
            from.rightCalloutAccessoryView = nil;
        }
        
        if (to == nil)
        {
            if (from == _expandedMarker)
            {
                [self collapseGroup];
            }
            else
            {
                [mapView selectAnnotation:_expandedMarker animated:NO];
            }
        }
        else if (to != _expandedMarker)
        {
            [self.map setCenterCoordinate:to.coordinate animated:YES];
            MapMarkerDetailsView *calloutView = [[MapMarkerDetailsView alloc] initWithEvent:to.event];
            CGRect calloutViewFrame = calloutView.frame;
            calloutViewFrame.origin = CGPointMake(-calloutViewFrame.size.width/2 + 17, -calloutViewFrame.size.height);
            calloutView.frame = calloutViewFrame;
            calloutView.delegate = self;

            [to addSubview:calloutView];
            to.rightCalloutAccessoryView = calloutView;
        }
    }
    else
    {
        if (from)
        {
            [from.rightCalloutAccessoryView removeFromSuperview];
            from.rightCalloutAccessoryView = nil;
        }
        if (to)
        {
            Event * event = to.event;
            if (event)
            {
                [self.map setCenterCoordinate:to.coordinate animated:YES];
                MapMarkerDetailsView *calloutView = [[MapMarkerDetailsView alloc] initWithEvent:event];
                CGRect calloutViewFrame = calloutView.frame;
                calloutViewFrame.origin = CGPointMake(-calloutViewFrame.size.width/2 + 17, -calloutViewFrame.size.height);
                calloutView.frame = calloutViewFrame;
                calloutView.delegate = self;
        
                [to addSubview:calloutView];
                to.rightCalloutAccessoryView = calloutView;
            }
            else
            {
                [self.map setCenterCoordinate:to.coordinate animated:YES];
                [self expandGroup:to inMap:mapView];
            }
        }
    }
    _handlingMarkerSwitch = NO;
}

-(void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    _zoom = mapView.region.span.latitudeDelta;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    float zoom = mapView.region.span.latitudeDelta;
    if (fabs(_zoom - zoom) > 0.001f && _expandedMarker)
    {
        [self collapseGroup];
    }
    
    if (_eventsList.updating || ![User currentUser].loggedIn)
    {
        _eventsUpdateScheduled = YES;
    }
    else
    {
        [self updateEventsForCurrentMap];
    }
    [self saveAnchor];
}

-(void)onDetailsInvokedForEvent:(Event*)event
{
    [self goToEventDetails:event];
}

-(void)goToEventDetails:(Event*)event
{
    [self hideAllPopups];
    ClassDetailsController *classDetailsController = [ClassDetailsController new];
    classDetailsController.event = event;
    [self.navigationController pushViewController:classDetailsController animated:YES];
}

-(void)centerOnEvent:(Event *)event
{
    self.map.region = MKCoordinateRegionMakeWithDistance(event.location.coordinate,
                                                10000,
                                                10000);
    _eventsList.filter.hereAndNow = NO;
    [self updateEventsForCurrentMap];
}

-(void)restoreAnchor
{
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    
    float latitude = [prefs floatForKey:LatitudeKey];
    float longitude = [prefs floatForKey:LongitudeKey];
    float latitudeSpan = [prefs floatForKey:LatitudeSpanKey];
    float longitudeSpan = [prefs floatForKey:LongitudeSpanKey];
    
    if (latitudeSpan < 0.0001f || longitudeSpan < 0.0001f)
    {
        latitudeSpan = 0.1f;
        longitudeSpan = 0.1f;
    }
    
    Trace(@"Restored anchor: %f x %f / %f x %f", latitude, longitude, latitudeSpan, longitudeSpan);
   
    self.map.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(latitude, longitude),
                                             MKCoordinateSpanMake(latitudeSpan, longitudeSpan));
}

-(void)saveAnchor
{
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    
    float latitude = self.map.centerCoordinate.latitude;
    float longitude = self.map.centerCoordinate.longitude;
    float latitudeSpan = self.map.region.span.latitudeDelta;
    float longitudeSpan = self.map.region.span.longitudeDelta;
    
    [prefs setFloat:latitude forKey:LatitudeKey];
    [prefs setFloat:longitude forKey:LongitudeKey];
    [prefs setFloat:latitudeSpan forKey:LatitudeSpanKey];
    [prefs setFloat:longitudeSpan forKey:LongitudeSpanKey];
    
    [prefs synchronize];
    
    Trace(@"Saved anchor: %f x %f / %f x %f", latitude, longitude, latitudeSpan, longitudeSpan);
}

#pragma mark - UITableView delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_sortedEvents count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EventTableCell *cell = [tableView dequeueReusableCellWithIdentifier:sEventCellIdentifier forIndexPath:indexPath];
    [cell fillWithEvent:_sortedEvents[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Event * event = _sortedEvents[indexPath.item];
    [self goToEventDetails:event];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

#pragma mark - internal methods

- (void)locate
{
    if (self.map.userLocation)
    {
        //[self.map setCenterCoordinate:self.map.centerCoordinate animated:YES];
        [self.map setCenterCoordinate:self.map.userLocation.coordinate animated:YES];
    }
    [[LocationController sharedController] startLocationTracking];
}

@end
