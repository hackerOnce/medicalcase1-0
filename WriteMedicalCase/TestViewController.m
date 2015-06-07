//
//  TestViewController.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/6/3.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "TestViewController.h"

@interface TestViewController ()

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSDictionary *dict = @{@"dID":@"2343",@"dName":@"王XX"};

    [TempDoctor setSharedDoctorWithDict:dict];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

///for unwind segue 
-(IBAction)createNoteCancel:(UIStoryboardSegue*)segue
{
    
}
-(IBAction)createNoteSave:(UIStoryboardSegue*)segue
{
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
