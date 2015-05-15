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

#import "TemplateLeftDetailSecondViewController.h"


@interface TemplateLeftDetailFirstViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) CoreDataStack *coreDataStack;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,strong) NSString *selectedString;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) ParentNode *parentNode;

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
-(ParentNode *)parentNode
{
    if (!_parentNode) {
        _parentNode = [self.coreDataStack fetchParentNodeWithNodeEntityName:self.fetchNodeName];
    }
    return _parentNode;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = self.fetchNodeName;
    
    BOOL didPop = [[NSUserDefaults standardUserDefaults] boolForKey:didExcutePopoverConditionSegue];
    if (!didPop) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        
        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
        [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
    }

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.parentNode.nodes.count;
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
    
    Node *tempNode = (Node*)[self.parentNode.nodes objectAtIndex:indexPath.row];
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
    Node *tempNode = [self.parentNode.nodes objectAtIndex:indexPath.row];
    
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"detail2"]){
        TemplateLeftDetailSecondViewController *leftDetail2 = (TemplateLeftDetailSecondViewController*)segue.destinationViewController;
        leftDetail2.fetchNodeName = self.selectedString;
    }
    
}

@end
