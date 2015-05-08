//
//  mainViewController.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/7.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "mainViewController.h"
#import "WriteCaseSaveViewController.h"
#import "CaseManagementSplitViewController.h"

@interface mainViewController ()

@end

@implementation mainViewController
- (IBAction)writeCaseButton:(UIButton *)sender
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"WriteCaseStoryboard" bundle:nil];
    WriteCaseSaveViewController *saveVC = [storyBoard instantiateViewControllerWithIdentifier:@"saveCaseVC"];
    
    saveVC.currentDoctor = [CurrentDoctor currentDoctor];
    saveVC.currentPatient = [[CurrentPatient alloc] init];
    
    [self.navigationController pushViewController:saveVC animated:YES];
}
- (IBAction)modelButton:(UIButton *)sender
{
    
}
- (IBAction)managedCase:(UIButton *)sender
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"CaseManagement" bundle:nil];
    CaseManagementSplitViewController *caseVC = [storyBoard instantiateViewControllerWithIdentifier:@"splitVC"];
    
    [self presentViewController:caseVC animated:YES completion:^{
        
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}


@end
