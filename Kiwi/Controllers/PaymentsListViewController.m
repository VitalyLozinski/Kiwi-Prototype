#import "PaymentsListViewController.h"
#import "PaymentHistoryCell.h"
#import "MyClasses.h"
#import "PaymentHistoryCell.h"
#import "ClassDetailsController.h"
#import "NSObject+GoogleAnalytics.h"

static NSString * const sPaymentHistoryCellIdentifier = @"PaymentHistoryCell";

@implementation PaymentsListViewController
{
    NSMutableArray * _payments;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = InterfaceString(@"PaymentsListTitle");
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(myClassesUpdated:)
                                                     name:MyClassesDidUpdateNotification
                                                   object:[MyClassesList sharedInstance]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self gaiScreen:GaiMyPayments];
    
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([PaymentHistoryCell class]) bundle:nil] forCellReuseIdentifier:sPaymentHistoryCellIdentifier];
   
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    [self myClassesUpdated:nil];
    [[MyClassesList sharedInstance] update];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)myClassesUpdated:(NSNotification*)ntf
{
    if (ntf && ntf.userInfo[@"error"])
    {
        return;
    }

    _payments = [[MyClassesList sharedInstance].events mutableCopy];
    [_payments sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
    {
        return [((Event*)obj2).start compare:((Event*)obj1).start];
    }];
    
    dispatch_async(dispatch_get_main_queue(),^
    {
        [self.tableView reloadData];
    });
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _payments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PaymentHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:sPaymentHistoryCellIdentifier forIndexPath:indexPath];
    [cell fillWithEvent:_payments[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ClassDetailsController *classDetailsController = [ClassDetailsController new];
    classDetailsController.event = _payments[indexPath.row];
    [self.navigationController pushViewController:classDetailsController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

@end
