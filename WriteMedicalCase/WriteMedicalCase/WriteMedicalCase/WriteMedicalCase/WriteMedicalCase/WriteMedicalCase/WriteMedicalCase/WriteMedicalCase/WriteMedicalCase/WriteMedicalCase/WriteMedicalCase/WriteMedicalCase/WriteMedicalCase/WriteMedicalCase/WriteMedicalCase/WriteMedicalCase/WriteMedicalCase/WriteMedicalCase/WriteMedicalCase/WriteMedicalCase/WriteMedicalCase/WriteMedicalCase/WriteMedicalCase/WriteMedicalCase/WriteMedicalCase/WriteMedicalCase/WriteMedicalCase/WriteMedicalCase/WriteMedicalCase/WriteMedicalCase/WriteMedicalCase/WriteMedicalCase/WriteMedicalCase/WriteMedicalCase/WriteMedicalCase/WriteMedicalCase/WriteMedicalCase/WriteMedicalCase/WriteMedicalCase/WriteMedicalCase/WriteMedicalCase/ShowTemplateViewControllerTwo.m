//
//  ShowTemplateViewControllerTwo.m
//  MedicalCase
//
//  Created by ihefe-JF on 15/4/8.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import "ShowTemplateViewControllerTwo.h"
#import "Constants.h"
#import "CoreDataStack.h"
#import "ParentNode.h"
#import "Node.h"
#import "Template.h"

@interface ShowTemplateViewControllerTwo ()<NSFetchedResultsControllerDelegate>
@property (nonatomic,strong) CoreDataStack *coreDataStack;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) NSFetchedResultsController *fetchResultController;
@end

@implementation ShowTemplateViewControllerTwo

-(NSManagedObjectContext *)managedObjectContext
{
    return self.coreDataStack.managedObjectContext;
}
-(CoreDataStack *)coreDataStack
{
    _coreDataStack = [[CoreDataStack alloc] init];
    return _coreDataStack;
}
-(NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}
-(void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpTableView];
   // [self updateTableViewWithFetchStr:<#(NSString *)#>]
}
-(void)setFetchStr:(NSString *)fetchStr
{
    _fetchStr = fetchStr;
    [self updateTableViewWithFetchStr:fetchStr];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = [self.fetchStr stringByAppendingString:@"模板"];

}
-(void)setUpTableView
{
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.title = @"病历模板展示";

}

-(void)updateTableViewWithFetchStr:(NSString*)str
{
    
    //NSString *tempStr = [info.userInfo objectForKey:selectedTemplateClassification];
    NSLog(@"%@",str);
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:[Template entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"node.nodeName = %@",str];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createDate" ascending:YES];
    NSSortDescriptor *sectionSort = [[NSSortDescriptor alloc] initWithKey:@"section" ascending:NO];
    fetchRequest.predicate = predicate;
    fetchRequest.sortDescriptors = @[sortDescriptor,sectionSort];
    
    self.fetchResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.coreDataStack.managedObjectContext sectionNameKeyPath:@"section" cacheName:nil];
    self.fetchResultController.delegate = self;
    NSError *error = nil;
    if (![self.fetchResultController performFetch:&error]) {
        NSLog(@"error: %@",error.description);
        abort();
    }else {
        // Template *template = [self.fetchResultController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        // NSLog(@"template condition : %@",template.condition);
        
    }
    [self.tableView reloadData];

    //    NSArray *tempArray = [self.coreDataStack fetchNSmanagedObjectEntityWithName:tempStr];
    //    //if ([[tempArray firstObject] isKindOfClass:[Template class]]) {
    //    self.dataArray = [NSMutableArray arrayWithArray:tempArray];
    //   // }
    //
    //    self.title = [tempStr stringByAppendingString:@"模板展示"];
    //    [self.tableView reloadData];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"section count %@", @(self.fetchResultController.sections.count));
    return self.fetchResultController.sections.count ;
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // return self.dataArray.count;
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchResultController.sections[section];
    
    return [sectionInfo numberOfObjects];
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ShowAllTemplateCell"];
    [self configCell:cell withIndexPath:indexPath];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    Template *template =(Template*) [self.fetchResultController objectAtIndexPath:indexPath];

    [self.navigationController popViewControllerAnimated:YES];
    [self.showTempDelegate didSelectedTemplate:template];
}

///table view delete
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Template *template =(Template*) [self.fetchResultController objectAtIndexPath:indexPath];
        [self.managedObjectContext deleteObject:template];
        [self.coreDataStack saveContext];
    }
}
-(void)configCell:(UITableViewCell*)cell withIndexPath:(NSIndexPath*)indexPath
{
    Template *template =(Template*) [self.fetchResultController objectAtIndexPath:indexPath];
    
    //    Template *template = [self.dataArray objectAtIndex:indexPath.row];
    NSLog(@"template condition : %@",template.condition);
    NSLog(@"template content : %@",template.content);
    NSLog(@"template create date : %@",template.createDate);
    
    UILabel *dayLabel = (UILabel*)[cell viewWithTag:1001];
    UILabel *monthLabel = (UILabel*)[cell viewWithTag:1002];
    UILabel *conditionLabel = (UILabel*)[cell viewWithTag:1003];
    UILabel *contentLanel = (UILabel*)[cell viewWithTag:1004];
    
    monthLabel.text = [self getMonthWithDateStr:template.createDate];
    dayLabel.text = [self getDayWithDateStr:template.createDate];
    conditionLabel.text = template.condition;
    // contentLanel.text = @"男性，30-40岁，突发下腹痛男性，30-40岁，突发下腹痛男性，30-40岁，突发下腹痛";
    contentLanel.text = template.content;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchResultController.sections[section];
    return sectionInfo.name;
}


/// fetch result controller delegate
-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}
-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeInsert:{
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }
        case NSFetchedResultsChangeDelete:{
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }
        case NSFetchedResultsChangeUpdate:{
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            [self configCell:cell withIndexPath:indexPath];
        }
            
        default:
            break;
    }
}
-(void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:sectionIndex];
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        default:
            break;
    }
}
-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}
///helper
-(NSString*)getYearAndMonthWithDateStr:(NSDate*)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM"];
    
    NSString *dateStr = [formatter stringFromDate:date];
    
    NSLog(@"date : %@",dateStr);
    
    return dateStr;
}
-(NSString*)getDayWithDateStr:(NSDate*)date
{
    NSString *dayStr ;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd"];
    
    dayStr = [formatter stringFromDate:date];
    return dayStr;
}
-(NSString*)getMonthWithDateStr:(NSDate*)date
{
    NSString *monthStr ;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM"];
    
    monthStr = [formatter stringFromDate:date];
    return monthStr;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
}

@end
