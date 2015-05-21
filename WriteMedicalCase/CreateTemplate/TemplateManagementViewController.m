//
//  TemplateManagementViewController.m
//  MedicalCase
//
//  Created by ihefe-JF on 15/4/1.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import "TemplateManagementViewController.h"
#import "CoreDataStack.h"
#import "ParentNode.h"
#import "Node.h"
#import "TemplateDetailViewControllerOne.h"

@interface TemplateManagementViewController () <UITableViewDataSource,UITableViewDelegate,UISplitViewControllerDelegate>
@property (nonatomic,strong) NSMutableArray *dataArray;

@property (nonatomic,strong) CoreDataStack *coreDataStack;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,strong) NSString *selectedString;

@property (nonatomic,strong) ParentNode *parentNode;
@end

@implementation TemplateManagementViewController
- (IBAction)createModel:(UIBarButtonItem *)sender {
    
    [self performSegueWithIdentifier:@"CreateModel" sender:nil];
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

-(ParentNode *)parentNode
{
    if (!_parentNode) {
       _parentNode = [self.coreDataStack fetchParentNodeWithNodeEntityName:@"模板"];
    }
    return _parentNode;
}
-(void)viewDidLoad {
    [super viewDidLoad];
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.parentNode.nodes.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TemplateManagementCell"];
    [self configCell:cell withIndexPath:indexPath];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    UILabel *celllabel =(UILabel*) [cell viewWithTag:1002];
    
    self.selectedString = celllabel.text;
    
   // [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectedFinalTemplate object:celllabel.text];
    
}
-(void)configCell:(UITableViewCell*)cell withIndexPath:(NSIndexPath*)indexPath
{
    Node *tempNode = [self.parentNode.nodes objectAtIndex:indexPath.row];
    
    if (tempNode.hasSubNode) {
        cell.accessoryType  = UITableViewCellAccessoryDetailButton;

    }else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    UILabel *celllabel =(UILabel*) [cell viewWithTag:1002];
    
    celllabel.text = tempNode.nodeName;
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    UILabel *celllabel =(UILabel*) [cell viewWithTag:1002];
    
    self.selectedString = celllabel.text;
    [self performSegueWithIdentifier:@"showDetail" sender:nil];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showDetail"]) {
        TemplateDetailViewControllerOne *tempDetail = (TemplateDetailViewControllerOne*)segue.destinationViewController;
        tempDetail.fetchNodeName = self.selectedString;
    }
}

@end
