//
//  TemplateDetailViewController.m
//  MedicalCase
//
//  Created by ihefe-JF on 15/4/2.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import "TemplateDetailViewController.h"
#import "Constants.h"
#import "CoreDataStack.h"
#import "ParentNode.h"
#import "Node.h"
#import "TemplateLeftDetailViewController.h"

@interface TemplateDetailViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBtn;

@property (nonatomic,strong) CoreDataStack *coreDataStack;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,strong) NSString *selectedString;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation TemplateDetailViewController

-(NSManagedObjectContext *)managedObjectContext
{
    return self.coreDataStack.managedObjectContext;
}
-(CoreDataStack *)coreDataStack
{
    _coreDataStack = [[CoreDataStack alloc] init];
    return _coreDataStack;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    BOOL didPop = [[NSUserDefaults standardUserDefaults] boolForKey:didExcutePopoverConditionSegue];

    if (!didPop) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        
        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
        [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
         self.navigationItem.leftBarButtonItem = nil;
    }else {
    }
}
-(NSMutableArray *)dataArray
{
    if (!_dataArray) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"nodeName = %@",self.fetchNodeName];
        NSArray *tempArray = [self.coreDataStack fetchNSManagedObjectEntityWithName:[ParentNode entityName] withNSPredicate:predicate setUpFetchRequestResultType:NSCountResultType isSetUpResultType:NO setUpFetchRequestSortDescriptors:nil isSetupSortDescriptors:NO];
        if ([[tempArray firstObject] isKindOfClass:[ParentNode class]]) {
            ParentNode *tempNode = (ParentNode*)[tempArray firstObject];
            
            NSArray *tempArray = tempNode.nodes.array;
            
            _dataArray = [NSMutableArray arrayWithArray:tempArray];
        }
    }
    return _dataArray;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TemplateDetailCell"];
    [self configCell:cell withIndexPath:indexPath];
    
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = (UITableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    UILabel *cellLabel = (UILabel*)[cell viewWithTag:1002];
    
    Node *tempNode = (Node*)[self.dataArray objectAtIndex:indexPath.row];
    BOOL didPop = [[NSUserDefaults standardUserDefaults] boolForKey:didExcutePopoverConditionSegue];
    if (didPop) {
        [[NSNotificationCenter defaultCenter] postNotificationName:selectedModelResultString object:tempNode];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:didExcutePopoverConditionSegue];

    }else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectedFinalTemplate object:cellLabel.text];
    }

}
-(void)configCell:(UITableViewCell*)cell withIndexPath:(NSIndexPath*)indexPath
{
    Node *tempNode = [self.dataArray objectAtIndex:indexPath.row];
    
    UILabel *celllabel =(UILabel*) [cell viewWithTag:1002];
    if(tempNode.hasSubNode){
        cell.accessoryType = UITableViewCellAccessoryDetailButton;
    }else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    celllabel.text = tempNode.nodeName;

}
-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    UILabel *celllabel =(UILabel*) [cell viewWithTag:1002];
    
    self.selectedString = celllabel.text;
    
    [self performSegueWithIdentifier:@"detail" sender:nil];

}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"detail"]){
        TemplateLeftDetailViewController *leftDetail = (TemplateLeftDetailViewController*)segue.destinationViewController;
        leftDetail.fetchNodeName = self.selectedString;
        leftDetail.title = self.selectedString;
    }else if ([segue.identifier isEqualToString:@"unwindCancel"]){
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:didExcutePopoverConditionSegue];
    }

}
@end
