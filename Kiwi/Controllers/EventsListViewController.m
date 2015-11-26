#import "EventsListViewController.h"

#import "MyClasses.h"
#import "User.h"

#import "EventTableCell.h"
#import "EventTableHeader.h"

#import "ClassDetailsController.h"
#import "NSObject+GoogleAnalytics.h"

static NSString * const sEventCellIdentifier = @"EventCell";
static NSString * const sEventHeaderIdentifier = @"EventHeader";

@interface EventsListViewController ()
{
    NSMutableArray * _sections;
    NSMutableArray * _upcomingClasses;
    NSMutableArray * _pastClasses;
}

@end

@implementation EventsListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = InterfaceString(@"ClassesListTitle");
        self.navigationItem.leftBarButtonItems = @[[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BackButton"]
                                                                                    style:UIBarButtonItemStylePlain
                                                                                   target:self
                                                                                   action:@selector(dismiss)]];
        
        _sections = [@[] mutableCopy];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(myClassesUpdated:)
                                                     name:MyClassesDidUpdateNotification
                                                   object:[MyClassesList sharedInstance]];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)dismiss
{
    if (self.navigationController)
        [self.navigationController popViewControllerAnimated:YES];
}

-(void)myClassesUpdated:(NSNotification*)ntf
{
    if (ntf && ntf.userInfo[@"error"])
        return;
    
    dispatch_async(dispatch_get_main_queue(),^
    {
        _upcomingClasses = [@[] mutableCopy];
        _pastClasses = [@[] mutableCopy];
        NSDate * now = [NSDate dateWithTimeIntervalSinceNow:0];
        for (Event * event in [MyClassesList sharedInstance].events)
        {
            if ([event.start compare:now] == NSOrderedAscending)
                [_pastClasses addObject:event];
            else
                [_upcomingClasses addObject:event];
        }
        _sections = [@[] mutableCopy];
        if (_upcomingClasses.count > 0)
        {
            [_upcomingClasses sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
            {
                return [((Event*)obj1).start compare:((Event*)obj2).start];
            }];
            [_sections addObject:_upcomingClasses];
        }
        if (_pastClasses.count > 0)
        {
            [_pastClasses sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
            {
                 return [((Event*)obj2).start compare:((Event*)obj1).start];
            }];
            [_sections addObject:_pastClasses];
        }
        [self.tableView reloadData];
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self gaiScreen:GaiMyClasses];

    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([EventTableCell class]) bundle:nil] forCellReuseIdentifier:sEventCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([EventTableHeader class]) bundle:nil] forHeaderFooterViewReuseIdentifier:sEventHeaderIdentifier];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    [self myClassesUpdated:nil];
    [[MyClassesList sharedInstance] update];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ((NSMutableArray*)_sections[section]).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EventTableCell *cell = [tableView dequeueReusableCellWithIdentifier:sEventCellIdentifier forIndexPath:indexPath];
    [cell fillWithEvent:((NSMutableArray*)_sections[indexPath.section])[indexPath.row]];
    
    return cell;
}

#pragma mark - Table view delegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    EventTableHeader *defaultHeader = [tableView dequeueReusableHeaderFooterViewWithIdentifier:sEventHeaderIdentifier];
    if (_sections[section] == _upcomingClasses)
        defaultHeader.titleLbl.text = InterfaceString(@"UpcomingClasses");
    else
        defaultHeader.titleLbl.text = InterfaceString(@"PastClasses");
    return defaultHeader;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ClassDetailsController *classDetailsController = [ClassDetailsController new];
    classDetailsController.event = ((NSMutableArray*)_sections[indexPath.section])[indexPath.row];
    [self.navigationController pushViewController:classDetailsController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

@end
