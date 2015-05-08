//
//  TemplateLeftDetailFirstViewController.m
//  MedicalCase
//
//  Created by ihefe-JF on 15/4/7.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import "TemplateLeftDetailFirstViewController.h"
#import "Constants.h"
#import "CoreDataStack.h"
#import "Node.h"
#import "ParentNode.h"

#import "TemplateLeftDetailSecondViewController.h"


@interface TemplateLeftDetailFirstViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) CoreDataStack *coreDataStack;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,strong) NSString *selectedString;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation TemplateLeftDetailFirstViewController

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
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    BOOL didPop = [[NSUserDefaults standardUserDefaults] boolForKey:didExcutePopoverConditionSegue];
    if (!didPop) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        
        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
        [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TemplateDetailLeftFirstCell"];
    [self configCell:cell withIndexPath:indexPath];
    
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    UITableViewCell *cell = (UITableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    UILabel *cellLabel = (UILabel*)[cell viewWithTag:1002];
    //    if(cell.accessoryType == UITableViewCellAccessoryNone){
    //        [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectedFinalTemplate object:nil userInfo:@{selectedTemplateClassification:cellLabel.text}];
    //    }else {
    //        [self performSegueWithIdentifier:@"Detail" sender:nil];
    //    }
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
    
    [self performSegueWithIdentifier:@"detail2" sender:nil];
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"detail2"]){
        TemplateLeftDetailSecondViewController *leftDetail2 = (TemplateLeftDetailSecondViewController*)segue.destinationViewController;
        leftDetail2.fetchNodeName = self.selectedString;
        leftDetail2.title = self.selectedString;
    }
    
}

@end
