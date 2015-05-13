//
//  SelectASharedTemplateViewController.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/13.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "SelectASharedTemplateViewController.h"
#import "SelectedASharedTemplateTableViewCell.h"

@interface SelectASharedTemplateViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation SelectASharedTemplateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


#pragma mask - tableView delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SelectedASharedTemplateTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SelectASharedTemplateCell"];
    
    
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}
-(void)configureCell:(SelectedASharedTemplateTableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    cell.contentLabel.text = @"我是一个放暑假我是一个放暑假我是一个放暑假我是一个放暑假我是一个放暑假我是一个放暑假我是一个放暑假我是一个放暑假";
    
}
-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
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
