//
//  DatePickerViewController.m
//  Kiwi
//
//  Created by admin on 13/03/15.
//  Copyright (c) 2015 Diversido. All rights reserved.
//

#import "DatePickerViewController.h"
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

@interface DatePickerViewController ()
{
    
 }

@end

@implementation DatePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  //  [self.view setba];    // Do any additional setup after loading the view from its nib.
   // UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 560)];
   // label.text = @"TEETETETET";
   // [self.view addSubview:label];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)appearIn:(UIViewController*)parent
{
     
    [parent addChildViewController:self];
    [parent.view addSubview:self.view];
    
//    NSInteger bottom = [UIScreen mainScreen].bounds.size.height;
//    [self.view valign:bottom];
//    [UIView animateWithDuration:0.5f animations:^
//     {
//         [self.view valign:0];
//     }];
}

- (IBAction)BackBtn:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)onAddClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
