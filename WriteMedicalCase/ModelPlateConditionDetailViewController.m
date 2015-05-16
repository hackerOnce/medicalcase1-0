//
//  ModelPlateConditionDetailViewController.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/15.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "ModelPlateConditionDetailViewController.h"

@interface ModelPlateConditionDetailViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic) BOOL isHideSearchBar;
@property (nonatomic,strong) IHMsgSocket *socket;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchBarHeightConstraints;
@property (nonatomic,strong) CoreDataStack *coreDataStack;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,strong) NSArray *dataArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation ModelPlateConditionDetailViewController
#pragma mask - socket
-(IHMsgSocket *)socket
{
    if (!_socket) {
        _socket = [IHMsgSocket sharedRequest];
        [_socket connectToHost:@"192.168.10.106" onPort:2323];
    }
    return _socket;
}
- (IBAction)canceClicked:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)saveClicked:(UIBarButtonItem *)sender
{
    
}
-(NSArray *)dataArray
{
    if ([self.selectedNode.nodeEnglish isEqualToString:@"gender"]) {
        _dataArray = @[@"男",@"女"];
        self.searchBarHeightConstraints.constant = 0;
    }
    return _dataArray;
}

-(NSManagedObjectContext *)managedObjectContext
{
    return self.coreDataStack.managedObjectContext;
}
-(CoreDataStack *)coreDataStack
{
    _coreDataStack = [[CoreDataStack alloc] init];
    return _coreDataStack;
}
#pragma mask - view life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    

    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
   // self.preferredContentSize = CGSizeMake(300, 300);
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = [NSString stringWithFormat:@"选择%@",self.selectedNode.nodeName];
}
#pragma mask -table view data source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   return self.dataArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"conditionsCell"];
    UIView *selectedbackgroundView = [[UIView alloc] initWithFrame:cell.bounds];
    selectedbackgroundView.backgroundColor = [UIColor orangeColor];
    [cell setSelectedBackgroundView:selectedbackgroundView];
    
    cell.textLabel.text = [self.dataArray objectAtIndex:indexPath.row];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *selectedItem = [self.dataArray objectAtIndex:indexPath.row];
    self.selectedNode.nodeContent = selectedItem;
    
    [self.coreDataStack saveContext];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
