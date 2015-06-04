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
#import "SplitViewController.h"
#import "RecordNavagationViewController.h"

@interface mainViewController ()
@property (nonatomic,strong) NSMutableArray *array;
@end

@implementation mainViewController
- (IBAction)writeCaseButton:(UIButton *)sender
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"WriteCaseStoryboard" bundle:nil];
    UINavigationController *nav = [storyBoard instantiateViewControllerWithIdentifier:@"writeNav"];
    
    //WriteCaseSaveViewController *saveVC = [storyBoard instantiateViewControllerWithIdentifier:@"saveCaseVC"];
    WriteCaseSaveViewController *saveVC = (WriteCaseSaveViewController*)[nav.viewControllers firstObject];
    
   // saveVC.currentDoctor = [CurrentDoctor currentDoctor];
    //saveVC.currentPatient = [[CurrentPatient alloc] init];
    
    [self presentViewController:nav animated:YES completion:^{
        
    }];
}
- (IBAction)textNote:(UIButton *)sender
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"RecordNote" bundle:nil];
    UIViewController *noteFirstVC = [storyBoard instantiateViewControllerWithIdentifier:@"NoteFirstVC"];
    [self presentViewController:noteFirstVC animated:YES completion:^{
        
    }];

}
- (IBAction)modelButton:(UIButton *)sender
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"CreateTemplateStoryboard" bundle:nil];
    SplitViewController *caseVC = [storyBoard instantiateViewControllerWithIdentifier:@"createTemplate"];
    [self presentViewController:caseVC animated:YES completion:^{
        
    }];
    
}
- (IBAction)auditButton:(UIButton *)sender {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"CaseManagement" bundle:nil];
    CaseManagementSplitViewController *caseVC = [storyBoard instantiateViewControllerWithIdentifier:@"splitVC"];
    
    
    UINavigationController *recordNav = (UINavigationController*)[caseVC.viewControllers firstObject];
    RecordNavagationViewController *record =(RecordNavagationViewController*) [recordNav.viewControllers firstObject];
    record.logInDoctorID = @"2120";
    [self presentViewController:caseVC animated:YES completion:^{
        
    }];
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
    
    self.array = [[NSMutableArray alloc] init];
    [self pathForTemporaryFileWithPrefix:@"XXX"];
    [self pathForTemporaryFileWithPrefix:@"XXX"];

}
- (NSString *)pathForTemporaryFileWithPrefix:(NSString *)prefix
{
    NSString *  result;
    CFUUIDRef   uuid;
    CFStringRef uuidStr;
    
    uuid = CFUUIDCreate(NULL);
    assert(uuid != NULL);
    
    uuidStr = CFUUIDCreateString(NULL, uuid);
    assert(uuidStr != NULL);
    
    result = [NSString stringWithFormat:@"%@",uuidStr];
    
    return result;
    
}

@end
