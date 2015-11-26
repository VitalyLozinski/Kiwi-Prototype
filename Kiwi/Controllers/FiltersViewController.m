//
//  FiltersViewController.m
//  Kiwi
//
//  Created by Crackman on 25.05.14.
//  Copyright (c) 2014 Diversido. All rights reserved.
//

#import "FiltersViewController.h"
#import "UIFont+AppFonts.h"
#import "UIColor+AppColors.h"
#import "UIButton+App.h"
#import "UIView+App.h"
#import "PLSCalendarDate.h"
#import "EventsFilter.h"
#import "TrainersList.h"
#import "Trainer.h"
#import "InstructorTableCell.h"
#import "TimeFilterTableCell.h"
#import "TimeSpan.h"
#import "User.h"
#import "NSObject+GoogleAnalytics.h"



static NSString * const sInstructorCellIdentifier = @"FilterInstructorCell";
static NSString * const sTimeFilterCellIdentifier = @"FilterTimeCell";

typedef enum
{
    TimeFilter_None,
    TimeFilter_From,
    TimeFilter_To,
} TimeFilterState;

@interface FiltersViewController()
{
    BOOL _categoryVisible;
    BOOL _instructorVisible;
    BOOL _dateTimeVisible;
    NSInteger _height;
    
    EventsFilter * _filter;
    TrainersList * _trainersList;
    NSMutableArray * _instructors;
    NSMutableArray * _selectedInstructors;
    
    NSMutableArray * _timeSpans;
    TimeFilterState _timeState;
    DatePickerViewController *_DataPickerViewController;
    
}

@property (weak, nonatomic) IBOutlet UIView *categoryHeader;
@property (weak, nonatomic) IBOutlet UIView *categoryColor;
@property (weak, nonatomic) IBOutlet UIButton *categoryFilterButton;
@property (weak, nonatomic) IBOutlet UILabel *categoryFilterLabel;

@property (weak, nonatomic) IBOutlet UIView *categoryFilter;
@property (weak, nonatomic) IBOutlet UIButton *burnButton;
@property (weak, nonatomic) IBOutlet UIButton *buildButton;
@property (weak, nonatomic) IBOutlet UIButton *bodyMindButton;

@property (weak, nonatomic) IBOutlet UIView *instructorHeader;
@property (weak, nonatomic) IBOutlet UIView *instructorColor;
@property (weak, nonatomic) IBOutlet UIButton *instructorFilterButton;
@property (weak, nonatomic) IBOutlet UILabel *instructorFilterLabel;
@property (weak, nonatomic) IBOutlet UIView *instructorFilter;
@property (weak, nonatomic) IBOutlet UITableView *instructorsTable;
@property (weak, nonatomic) IBOutlet UITableView *instructorsTableShort;
@property (weak, nonatomic) IBOutlet UITableView *instructorsTableLong;

@property (weak, nonatomic) IBOutlet UIView *dateTimeHeader;
@property (weak, nonatomic) IBOutlet UIView *dateTimeColor;
@property (weak, nonatomic) IBOutlet UIButton *dateTimeFilterButton;
@property (weak, nonatomic) IBOutlet UIView *dateTimeFilter;
@property (weak, nonatomic) IBOutlet UILabel *dateTimeLabel;
@property (weak, nonatomic) IBOutlet UITableView *dateTimeTable;
@property (weak, nonatomic) IBOutlet UIView *dateTimeNew;
@property (weak, nonatomic) IBOutlet UILabel *dateTimeNewLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *fromPicker;
@property (weak, nonatomic) IBOutlet UIView *fromBackground;
@property (weak, nonatomic) IBOutlet UIButton *fromButton;
@property (weak, nonatomic) IBOutlet UIDatePicker *toPicker;
@property (weak, nonatomic) IBOutlet UIView *toBackground;
@property (weak, nonatomic) IBOutlet UIButton *toButton;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIView *spaceView;

@property (weak, nonatomic) IBOutlet UIButton *spaceButton;



@property (weak, nonatomic) IBOutlet UIView *rightHereHeader;
@property (weak, nonatomic) IBOutlet UIView *rightHereColor;
@property (weak, nonatomic) IBOutlet UIView *rightHereFullColor;
@property (weak, nonatomic) IBOutlet UIButton *rightHereFilterButton;

@property (weak, nonatomic) IBOutlet UIView *resetFilterView;
@property (weak, nonatomic) IBOutlet UIButton *resetFilterButton;

@property (weak, nonatomic) IBOutlet UIButton *filtersCloseButton;
@property (weak, nonatomic) IBOutlet UIButton *filtersSaveCloseButton;

@end

@implementation FiltersViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(userDidLogin:)
                                                     name:UserDidLoginNotification
                                                   object:[User currentUser]];
        
        _timeSpans = [NSMutableArray arrayWithArray:@[]];
        _trainersList = [TrainersList new];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(trainersListDidUpdate:)
                                                     name:TrainersListDidUpdateNotification
                                                   object:_trainersList];
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
    
    if ([UIScreen mainScreen].bounds.size.height > 500)
    {
        _instructorsTable = _instructorsTableLong;
        _instructorsTableShort.hidden = YES;
    }
    else
    {
        _instructorsTable = _instructorsTableShort;
        _instructorsTableLong.hidden = YES;
    }
    
    //[_categoryFilterButton makeTinted];
    _categoryFilterButton.imageView.tintColor = [UIColor grayMenuItemColor];
    _categoryFilterButton.titleLabel.font = [UIFont regularAppFontOfSize:18];
    _categoryFilterLabel.font = [UIFont regularAppFontOfSize:18];
    _categoryFilterLabel.tintColor = [UIColor grayMenuItemColor];
    
    {
        [_buildButton makeTinted];
        _buildButton.imageView.tintColor = [UIColor grayMenuItemColor];
        _buildButton.titleLabel.font = [UIFont boldAppFontOfSize:20];
        
        [_burnButton makeTinted];
        _burnButton.titleLabel.font = [UIFont boldAppFontOfSize:20];
        _burnButton.imageView.tintColor = [UIColor grayMenuItemColor];
        
        [_bodyMindButton makeTinted];
        _bodyMindButton.titleLabel.font = [UIFont boldAppFontOfSize:20];
        _bodyMindButton.imageView.tintColor = [UIColor grayMenuItemColor];
    }
    
//    {
//        [_spaceButton makeTinted];
//        _spaceButton.imageView.tintColor = [UIColor grayMenuItemColor];
//        _spaceButton.titleLabel.font = [UIFont boldAppFontOfSize:20];
//        
//        [_spaceButton makeTinted];
//        _spaceButton.titleLabel.font = [UIFont boldAppFontOfSize:20];
//        _spaceButton.imageView.tintColor = [UIColor grayMenuItemColor];
//        
//        [_spaceButton makeTinted];
//        _spaceButton.titleLabel.font = [UIFont boldAppFontOfSize:20];
//        _spaceButton.imageView.tintColor = [UIColor grayMenuItemColor];
//    }
    [_instructorFilterButton makeTinted];
    _instructorFilterButton.titleLabel.font = [UIFont regularAppFontOfSize:18];
    _instructorFilterButton.imageView.tintColor = [UIColor grayMenuItemColor];
    _instructorFilterLabel.font = [UIFont regularAppFontOfSize:18];
    _instructorFilterLabel.tintColor = [UIColor grayMenuItemColor];
    _instructorsTable.dataSource = self;
    _instructorsTable.delegate = self;
    [_instructorsTable registerNib:[UINib nibWithNibName:NSStringFromClass([InstructorTableCell class]) bundle:nil] forCellReuseIdentifier:sInstructorCellIdentifier];
    _instructorsTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    _dateTimeTable.dataSource = self;
    _dateTimeTable.delegate = self;
    [_dateTimeTable registerNib:[UINib nibWithNibName:NSStringFromClass([TimeFilterTableCell class]) bundle:nil] forCellReuseIdentifier:sTimeFilterCellIdentifier];
    _dateTimeTable.separatorColor = [UIColor clearColor];
    _dateTimeLabel.font = [UIFont regularAppFontOfSize:18];
    _dateTimeLabel.tintColor = [UIColor grayMenuItemColor];
    
    //[_dateTimeFilterButton makeTinted];
    _dateTimeFilterButton.titleLabel.font = [UIFont regularAppFontOfSize:18];
    _dateTimeFilterButton.imageView.tintColor = [UIColor grayMenuItemColor];
    _dateTimeNewLabel.font = [UIFont regularAppFontOfSize:17];
    _fromButton.titleLabel.font = [UIFont regularAppFontOfSize:16];
    _toButton.titleLabel.font = [UIFont regularAppFontOfSize:16];
    
   // _spaceView.backgroundColor = [[UIColor grayMenuItemColor]colorWithAlphaComponent:0.6];
//    _spaceButton.titleLabel.font = [UIFont regularAppFontOfSize:18];
//    _spaceButton.imageView.tintColor = [UIColor grayMenuItemColor];
    //[_rightHereFilterButton makeTinted];
    _rightHereFilterButton.titleLabel.font = [UIFont regularAppFontOfSize:18];
    _rightHereFilterButton.imageView.tintColor = [UIColor grayMenuItemColor];

    _resetFilterButton.titleLabel.font = [UIFont regularAppFontOfSize:18];
    _resetFilterButton.imageView.tintColor = [UIColor grayMenuItemColor];

    [_filtersCloseButton makeTinted];
    _filtersCloseButton.titleLabel.font = [UIFont regularAppFontOfSize:14];
    _filtersCloseButton.titleLabel.text = InterfaceString(@"CloseFilters");
    
    [_filtersSaveCloseButton makeTinted];
    _filtersSaveCloseButton.titleLabel.font = [UIFont regularAppFontOfSize:14];
    _filtersSaveCloseButton.titleLabel.text = InterfaceString(@"SaveAndCloseFilters");

    [self setCategories];
    [self setInstructors];
    [self setTimes:TimeFilter_None];
    
    UISwipeGestureRecognizer * closeSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    [closeSwipe setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.view addGestureRecognizer:closeSwipe];
    
    [self reset];
    
    
    _DataPickerViewController = [DatePickerViewController new];
    _DataPickerViewController.view.frame = self.view.frame;
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)swipe
{
    if (swipe.direction == UISwipeGestureRecognizerDirectionDown)
    {
        [self closeClicked:nil];
    }
}

-(void)reset
{
    _filtersSaveCloseButton.hidden = YES;
    _filtersCloseButton.hidden = NO;
    _categoryVisible = NO;
    _instructorVisible = NO;
    _dateTimeVisible = NO;
    [self setTimes:TimeFilter_None];
    [self setFilters];
    _rightHereFullColor.hidden = !_rightHereFilterButton.selected;
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self setFilters];
}

-(EventsFilter*)filter
{
    if (!_filter)
    {
        _filter = [EventsFilter new];
        [self setFilters];
    }
    return _filter;
}

-(void)modify
{
    _filtersCloseButton.hidden = YES;
    _filtersSaveCloseButton.hidden = NO;
}
- (IBAction)clickAdd:(id)sender {
//    [viewcontroller appearIn:self];
   DatePickerViewController *dataVC = [[DatePickerViewController alloc]initWithNibName:@"DatePickerViewController" bundle:nil];
    [self presentViewController:dataVC animated:YES completion:nil];
    
//     self.title = InterfaceString(@"Date and time");
//    [_DataPickerViewController appearIn:self];
    
}

- (IBAction)toggleCategoryFilter:(id)sender
{
    if (!_categoryVisible)
    {
        [self gaiScreen:GaiFilterCategory];
    }
    
    _categoryVisible = !_categoryVisible;
    _instructorVisible = NO;
    _dateTimeVisible = NO;
    [self animateFilters];
}

- (IBAction)toggleBurnCategory:(id)sender
{
    if (_burnButton.selected &&
        !_bodyMindButton.selected &&
        !_buildButton.selected)
        return;
    
    _burnButton.selected = !_burnButton.selected;
    
    [self modify];
    [self setCategories];
    [self dropRightHere];
    [self animateFilters];
}

- (IBAction)toggleBuildCategory:(id)sender
{
    if (!_burnButton.selected &&
        !_bodyMindButton.selected &&
        _buildButton.selected)
        return;
    
    _buildButton.selected = !_buildButton.selected;

    [self modify];
    [self setCategories];
    [self dropRightHere];
    [self animateFilters];
}

- (IBAction)toggleBodyMindCategory:(id)sender
{
    if (!_burnButton.selected &&
        _bodyMindButton.selected &&
        !_buildButton.selected)
        return;
    
    _bodyMindButton.selected = !_bodyMindButton.selected;

    [self modify];
    [self setCategories];
    [self dropRightHere];
    [self animateFilters];
}

- (IBAction)toggleInstructorFilter:(id)sender
{
    if (!_instructorVisible)
    {
        [self gaiScreen:GaiFilterTrainer];
    }
    
    _categoryVisible = NO;
    _instructorVisible = !_instructorVisible;
    _dateTimeVisible = NO;
    [self animateFilters];
}

- (IBAction)toggleDateTimeFilter:(id)sender
{
    if (!_dateTimeVisible)
    {
        [self gaiScreen:GaiFilterTime];
    }

    _categoryVisible = NO;
    _instructorVisible = NO;
    _dateTimeVisible = !_dateTimeVisible;
    [self animateFilters];
}

-(void)dropRightHere
{
    [self filter].hereAndNow = _rightHereFilterButton.selected = NO;
}

- (IBAction)toggleRightHereFilter:(id)sender
{
    [self gaiScreen:GaiRightHereRightNow];
    
    [self filter].hereAndNow = YES;
    [self modify];
    [self filter].timeSpans = @[];
    [_timeSpans removeAllObjects];
    [_dateTimeTable reloadData];
    [self setTimes:TimeFilter_None];
    
    [_selectedInstructors removeAllObjects];
    [_instructorsTable reloadData];
    [self setInstructors];
    
    _buildButton.selected = true;
    _burnButton.selected = true;
    _bodyMindButton.selected = true;
    [self setCategories];

    [self animateFilters];
    [self closeClicked:_filtersSaveCloseButton];
}

- (IBAction)closeClicked:(id)sender
{
    if (sender == _filtersSaveCloseButton)
    {
        if (_delegate)
        {
            [_delegate applyFilter:_filter];
        }
        _filtersCloseButton.hidden = NO;
        _filtersSaveCloseButton.hidden = YES;
    }
    [self disappear];
}

- (IBAction)resetFiltersClicked:(id)sender
{
    [self modify];
    [[self filter] reset];
    
    [_timeSpans removeAllObjects];
    [_dateTimeTable reloadData];
    [self setTimes:TimeFilter_None];
    
    [_selectedInstructors removeAllObjects];
    [_instructorsTable reloadData];
    [self setInstructors];
    
    _buildButton.selected = true;
    _burnButton.selected = true;
    _bodyMindButton.selected = true;
    [self setCategories];
    
    [self animateFilters];
    [self closeClicked:_filtersSaveCloseButton];
}

-(void)appearIn:(UIViewController*)parent
{
    [_trainersList update];
    
    [parent addChildViewController:self];
    [parent.view addSubview:self.view];
    [self reset];
    
    NSInteger bottom = [UIScreen mainScreen].bounds.size.height;
    [self.view valign:bottom];
    [UIView animateWithDuration:0.5f animations:^
    {
         [self.view valign:0];
    }];
}

-(void)disappear
{
    dispatch_async(dispatch_get_main_queue(),^
{
    NSInteger bottom = [UIScreen mainScreen].bounds.size.height;
    [UIView animateWithDuration:0.5f animations:^
    {
        [self.view valign:bottom];
    }
    completion:^(BOOL finished)
    {
        if (finished)
        {
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
        }
    }];
});
}

-(NSInteger)height
{
    return _height;
}

-(void)animateFilters
{
    [UIView animateWithDuration:0.5f animations:^
     {
         [self setFilters];
         
     }];
}



-(void)setFilters
{
    NSInteger screen = [[UIScreen mainScreen] bounds].size.height;
    
    NSInteger category = _categoryVisible ? 176 : 0;
    NSInteger instructor = _instructorVisible ? (screen - 290 - 64) : 0;
    NSInteger dateTime = _dateTimeVisible ? 176 : 0;
    NSInteger shortColor = 8;
    NSInteger longColor = 49;
    
 //  NSInteger off = screen - (290 + category + instructor + dateTime);ƒ
    [_categoryHeader valign:  0 + 64];
    [_categoryFilter valign: 50 + 64 height:category];
    [_categoryColor halign:0 width:_categoryVisible ? longColor : shortColor];
    
    [_instructorHeader valign:  50 + category + 64];
    [_instructorFilter valign: 100 + category + 64 height:instructor];
    [_instructorColor halign:0 width:_instructorVisible ? longColor : shortColor];
    
    [_dateTimeHeader valign: 100 + category + instructor + 64];
    [_dateTimeFilter valign: 150 + category + instructor + 64 height: dateTime];
    [_dateTimeColor halign:0 width:_dateTimeVisible ? longColor : shortColor];

   // [_spaceView valign: 150 + category + instructor + dateTime + 64];
    [_spaceView valign: 150 + category + instructor + dateTime + 64 height: screen- 250 - 64 - category - instructor - dateTime];
    [_dateTimeColor halign:0 width:_dateTimeVisible ? longColor : shortColor];

    
        [_rightHereHeader valign: screen - 150 + 11];
        [_rightHereColor halign:0 width:_rightHereFilterButton.selected ? longColor : shortColor];
        [_rightHereFullColor halign:0 width:_rightHereFilterButton.selected ? longColor : shortColor];
    
        [_resetFilterView valign: screen - 100 + 11];
    
        [_filtersCloseButton valign: screen - 50 + 11];
        [_filtersSaveCloseButton valign: screen - 50 + 11];

}

//-(void)setFilters
//{
//    NSInteger screen = [[UIScreen mainScreen] bounds].size.height;
//
//    NSInteger category = _categoryVisible ? 176 : 0;
//    NSInteger instructor = _instructorVisible ? 88 : 0;
//    NSInteger dateTime = _dateTimeVisible ? 176 : 0;
//    NSInteger shortColor = 8;
//    NSInteger longColor = 49;
//
//    //NSInteger off = category + instructor + dateTime;
////    NSInteger off = screen - (568 - 64 + category + instructor + dateTime);
//    [_categoryHeader valign:  64];
//    [_categoryFilter valign: 50 + 64 height:category];
//    [_categoryColor halign:0 width:_categoryVisible ? longColor : shortColor];
//
//    [_instructorHeader valign:  50 + 64 + category ];
//    [_instructorFilter valign: 100 + 64 + category  height:instructor];
//    [_instructorColor halign:0 width:_instructorVisible ? longColor : shortColor];
//
//    [_dateTimeHeader valign: 100 + 64 + category + instructor ];
//    [_dateTimeFilter valign: 150 + 64 + category + instructor height: dateTime];
//    [_dateTimeColor halign:0 width:_dateTimeVisible ? longColor : shortColor];
//
//    [_rightHereHeader valign: screen - 150 ];
//    [_rightHereColor halign:0 width:_rightHereFilterButton.selected ? longColor : shortColor];
//    [_rightHereFullColor halign:0 width:_rightHereFilterButton.selected ? longColor : shortColor];
//
//    [_resetFilterView valign: screen - 100];
//
//    [_filtersCloseButton valign: screen - 50 ];
//    [_filtersSaveCloseButton valign: screen - 50];
//}


-(void)setCategories
{
    NSInteger categories = 0;
    [[self filter] setEventTypes:[NSMutableArray arrayWithArray:@[]]];
    if (_buildButton.selected)
    {
        categories++;
    }
    if (_burnButton.selected)
    {
        categories++;
    }
    if (_bodyMindButton.selected)
    {
        categories++;
    }

    if (categories == 3 || categories == 0)
    {
        _categoryFilterLabel.text = @"Any";
    }
    else
    {
        if (_buildButton.selected)
        {
            [[self filter] addEventType:BuildEvent];
        }
        if (_burnButton.selected)
        {
            [[self filter] addEventType:BurnEvent];
        }
        if (_bodyMindButton.selected)
        {
            [[self filter] addEventType:BodyMindEvent];
        }

        _categoryFilterLabel.text = [NSString stringWithFormat:@"%ld", (long)categories];
    }
}

-(void)setInstructors
{
    [self modify];
    [[self filter] setInstructors:[NSMutableArray arrayWithArray: _selectedInstructors]];
    
    if (_selectedInstructors.count == _instructors.count ||
        _selectedInstructors.count == 0)
    {
        _instructorFilterLabel.text = @"Any";
    }
    else
    {
        _instructorFilterLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)_selectedInstructors.count];
    }
}


- (IBAction)switchToFrom:(id)sender
{
    [self setTimes:TimeFilter_From];
}

- (IBAction)switchToTo:(id)sender
{
    [self setTimes:TimeFilter_To];
}

- (IBAction)currentTimeSpanChanged:(id)sender
{
    _addButton.enabled = [_toPicker.date compare:_fromPicker.date] == NSOrderedDescending;
}

-(void)setTimes:(TimeFilterState)timeState
{
    [[self filter] setTimeSpans:[NSMutableArray arrayWithArray: _timeSpans]];

    if (_timeSpans.count == 0)
    {
        _dateTimeLabel.text = @"Any";
    }
    else
    {
        _dateTimeLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)_timeSpans.count];
    }
    
    _dateTimeTable.hidden = YES;
    _dateTimeNew.hidden = NO;
    [_dateTimeTable halign:0];
    [_dateTimeNew halign:320];
    
    [UIView animateWithDuration:0.5f animations:^
     {
         [_dateTimeTable halign:-320];
         [_dateTimeNew halign:0];
     }
                     completion:^ (BOOL finished)
     {
         _dateTimeTable.hidden = YES;
     }];

    
//    if (timeState == TimeFilter_None)
//    {
//        if (_timeState == TimeFilter_None || _timeState != TimeFilter_None)
//        {
//            _dateTimeTable.hidden = NO;
//            _dateTimeNew.hidden = YES;
//        }
//        else
//        {
//            _dateTimeTable.hidden = NO;
//            _dateTimeNew.hidden = NO;
//            [_dateTimeTable halign:-320];
//            [_dateTimeNew halign:0];
//            
//            [UIView animateWithDuration:0.5f animations:^
//            {
//                [_dateTimeTable halign:0];
//                [_dateTimeNew halign:320];
//            }
//            completion:^ (BOOL finished)
//            {
//                _dateTimeNew.hidden = YES;
//                [_dateTimeTable reloadData];
//            }];
//        }
//    }
//    else
//    {
//        if (_timeState == TimeFilter_None)
//        {
//            _dateTimeTable.hidden = NO;
//            _dateTimeNew.hidden = NO;
//            [_dateTimeTable halign:0];
//            [_dateTimeNew halign:320];
//            
//            [UIView animateWithDuration:0.5f animations:^
//            {
//                [_dateTimeTable halign:-320];
//                [_dateTimeNew halign:0];
//            }
//            completion:^ (BOOL finished)
//            {
//                _dateTimeTable.hidden = YES;
//            }];
//        }
//        else
//        {
//            _dateTimeTable.hidden = YES;
//            _dateTimeNew.hidden = NO;
//        }
//        
//        if (timeState == TimeFilter_From)
//        {
//            _fromBackground.backgroundColor = [UIColor appGreenColor];
//            _fromPicker.hidden = NO;
//            _toBackground.backgroundColor = [UIColor transparentWhiteColor];
//            _toPicker.hidden = YES;
//        }
//        if (timeState == TimeFilter_To)
//        {
//            _fromBackground.backgroundColor = [UIColor transparentWhiteColor];
//            _fromPicker.hidden = YES;
//            _toBackground.backgroundColor = [UIColor appGreenColor];
//            _toPicker.hidden = NO;
//        }
//    }
    _timeState = timeState;
}

- (IBAction)addTimeSpan:(id)sender
{
    [_timeSpans addObject:[[TimeSpan alloc]
                           initFrom:[[PLSCalendarDate alloc] initWithDate:_fromPicker.date]
                           to:[[PLSCalendarDate alloc] initWithDate:_toPicker.date]]];
    [self modify];
    [[self filter] setTimeSpans:_timeSpans];
    dispatch_async(dispatch_get_main_queue(),^
    {
        [self setTimes:TimeFilter_None];
        [self dropRightHere];
        [self animateFilters];
    });
}



-(void)setInstructors:(TrainersList*)trainers
{
    NSMutableSet * added = [NSMutableSet new];
    NSMutableArray * instructors = [NSMutableArray arrayWithArray:@[]];
    for (Trainer * t in trainers.trainers)
    {
        NSString * i = t.trainerId;
        if ([added containsObject:i])
            continue;
        [added addObject:i];
        [instructors addObject:t];
    }

    NSMutableArray * selectedInstructors = [NSMutableArray arrayWithArray:@[]];
    for (NSString * s in _selectedInstructors)
    {
        if ([added containsObject:s])
            [selectedInstructors addObject:s];
    }

    _instructors = instructors;
    _selectedInstructors = selectedInstructors;
    
    Trace(@"Loaded %i instructors", (int)_instructors.count);
    
    [_instructorsTable reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _instructorsTable)
    {
        return _instructors.count;
    }
    else if (tableView == _dateTimeTable)
    {
        return _timeSpans.count + 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _instructorsTable)
    {
        Trainer * trainer = _instructors[indexPath.row];
        BOOL selected = [_selectedInstructors containsObject:trainer.trainerId];
    
        InstructorTableCell * cell = [tableView dequeueReusableCellWithIdentifier:sInstructorCellIdentifier forIndexPath:indexPath];
        [cell fillWithTrainer:trainer selected:selected];
    
        return cell;
    }
    else if (tableView == _dateTimeTable)
    {
        TimeFilterTableCell * cell = [tableView dequeueReusableCellWithIdentifier:sTimeFilterCellIdentifier forIndexPath:indexPath];
        if (indexPath.row < _timeSpans.count)
        {
            [cell fillWithTimeSpan:_timeSpans[indexPath.row] removeHandler:^
            {
                [_timeSpans removeObjectAtIndex:indexPath.row];
                [_dateTimeTable reloadData];
                [self modify];
                [[self filter] setTimeSpans:_timeSpans];
                [self setTimes:TimeFilter_None];
            }];
        }
        else
        {
            [cell fillWithAddHandler:^
            {
                dispatch_async(dispatch_get_main_queue(),^
                {
                    _fromPicker.date = [NSDate dateWithTimeIntervalSinceNow:0];
                    _toPicker.date = [NSDate dateWithTimeIntervalSinceNow:30 * 60];
                    [self setTimes:TimeFilter_From];
                });
            }];
        }
        
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _instructorsTable)
    {
        Trainer * trainer = _instructors[indexPath.item];
        NSString * instructor = trainer.trainerId;
        if ([_selectedInstructors containsObject:instructor])
        {
            [_selectedInstructors removeObject:instructor];
        }
        else
        {
            [_selectedInstructors addObject:instructor];
        }
    
        [self dropRightHere];
        [self setInstructors];
        [_instructorsTable reloadData];
        [self animateFilters];
    }
}

- (void)setLatitude:(float)latitude
          longitude:(float)longitude
              range:(float)range
{
    [_trainersList setLatitude:latitude longitude:longitude range:range];
    if ([User currentUser].loggedIn)
    {
        [_trainersList update];
    }
}

- (void)userDidLogin:(NSNotification *)ntf
{
    if (ntf.userInfo)
    {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(),
    ^{
        [_trainersList update];
    });
}

- (void)trainersListDidUpdate:(NSNotification *)ntf
{
    Trace(@"Trainers list updated");
    
    dispatch_async(dispatch_get_main_queue(),^
    {
        [self setInstructors:_trainersList];
    });
}

@end
