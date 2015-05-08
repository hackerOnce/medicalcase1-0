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
#import "TemplateDetailViewController.h"

@interface TemplateManagementViewController () <UITableViewDataSource,UITableViewDelegate,UISplitViewControllerDelegate>
@property (nonatomic,strong) NSMutableArray *dataArray;

@property (nonatomic,strong) CoreDataStack *coreDataStack;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,strong) NSString *selectedString;


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

-(NSMutableDictionary *)dataDic
{
    if(!_dataDic){
        _dataDic = [[NSMutableDictionary alloc] init];
        
        for (NSString *str in self.dataArray) {
            [_dataDic setObject:@"没数据" forKey:str];
        }
        //[_dataDic setObject:self.dataArray forKey:@"现病史"];
    }
    return _dataDic;
}
-(NSMutableArray *)dataArray
{
    if (!_dataArray) {
        
        NSString *fetchName = @"模板";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"nodeName = %@",fetchName];
        NSArray *tempArray = [self.coreDataStack fetchNSManagedObjectEntityWithName:[ParentNode entityName] withNSPredicate:predicate setUpFetchRequestResultType:NSCountResultType isSetUpResultType:NO setUpFetchRequestSortDescriptors:nil isSetupSortDescriptors:NO];
        if ([[tempArray firstObject] isKindOfClass:[ParentNode class]]) {
            ParentNode *tempNode = (ParentNode*)[tempArray firstObject];
            
            NSArray *tempArray = tempNode.nodes.array;
            
            _dataArray = [NSMutableArray arrayWithArray:tempArray];
        }
    }
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
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

    Node *tempNode = [self.dataArray objectAtIndex:indexPath.row];

    if (tempNode.hasSubNode) {
        [self performSegueWithIdentifier:@"showDetail" sender:nil];
    }

//    UITableViewCell *cell x= [tableView cellForRowAtIndexPath:indexPath];
//    if(cell.accessoryType == UITableViewCellAccessoryNone){
//        [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectedFinalTemplate object:self.title];
//    }else {
//        [self performSegueWithIdentifier:@"showDetail" sender:nil];
//    }
    
}
-(void)configCell:(UITableViewCell*)cell withIndexPath:(NSIndexPath*)indexPath
{
    Node *tempNode = [self.dataArray objectAtIndex:indexPath.row];
    
//    if(tempNode.hasSubNode){
//        cell.accessoryType = UITableViewCellAccessoryDetailButton;
//    }else {
//        cell.accessoryType = UITableViewCellAccessoryNone;
//    }
    if (tempNode.hasSubNode) {
        cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;

    }else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    UILabel *celllabel =(UILabel*) [cell viewWithTag:1002];
    
    celllabel.text = tempNode.nodeContent;
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    
//    UILabel *celllabel =(UILabel*) [cell viewWithTag:1002];
//    
//    self.selectedString = celllabel.text;
    
    
  //  [self performSegueWithIdentifier:@"showDetail" sender:nil];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showDetail"]) {
        TemplateDetailViewController *tempDetail = (TemplateDetailViewController*)segue.destinationViewController;
        tempDetail.fetchNodeName = self.selectedString;
        tempDetail.title = self.selectedString;
    }
}

//- (IBAction)unwindSegueFromCreateTemplateVCToSplitViewController:(UIStoryboardSegue *)segue
//{
//    
//}
//
//- (IBAction)unwindSegueCancelCreateTemplateToSplitViewController:(UIStoryboardSegue *)segue
//{
//    
//}


@end
