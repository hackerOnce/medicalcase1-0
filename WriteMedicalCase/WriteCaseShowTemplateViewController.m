//
//  WriteCaseShowTemplateViewController.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/4/30.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "WriteCaseShowTemplateViewController.h"
#import "WriteCaseShowTemplateCell.h"
#import "RWLabel.h"
#import "TemplateDetailViewController.h"

@interface WriteCaseShowTemplateViewController ()<NSFetchedResultsControllerDelegate,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>


@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) NSDictionary *testData;

@property (nonatomic,strong) CoreDataStack *coreDataStack;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewBottonConstraints;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,strong) NSFetchedResultsController *fetchResultController;

@property (nonatomic,strong) NSArray *dataArray;
@property (nonatomic,strong) NSString *titleStr;

@property (nonatomic,strong) Template *currentTemplate;
@end

@implementation WriteCaseShowTemplateViewController

-(NSDictionary *)testData
{
    if (!_testData) {
        _testData = @{@"content":@"猪猪书速速手术室猪猪书速速手术室猪猪书速速手术室猪猪书速速手术室猪猪书速速手术室猪猪书速速手术室猪猪书速速手术室猪猪书速速手术室猪猪书速速手术室猪猪书速速手术室猪猪书速速手术室猪猪书速速手术室猪猪书速速手术室猪猪书速速手术室猪猪书速速手术室猪猪书速速手术室猪猪书速速手术室猪猪书速速手术室猪猪书速速手术室猪猪书速速手术室猪猪书速速手术室猪猪书速速手术室猪猪书速速手术室猪猪书速速手术室猪猪书速速手术室猪猪书速速手术室猪猪书速速手术室猪猪书速速手术室猪猪书速速手术室猪猪书速速手术室猪猪书速速手术室猪猪书速速手术室猪猪书速速手术室猪猪书速速手术室猪猪书速速手术室猪猪书速速手术室",@"soucre":@"源自个人",@"create":@"张盗铃"};
    }
    return _testData;
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
-(void)setUpFetchViewControllerWithSearchText:(NSString*)searchText;
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:[Template entityName]];
   // NSPredicate *predicate = [NSPredicate predicateWithFormat:@"section = %@",self.templateName];
    NSString *dID = @"99999";
    NSString *dName = @"涨涨我";
    NSPredicate *predicate;
    if (searchText) {
        predicate = [NSPredicate predicateWithFormat:@"dID=%@ and dName = %@ and condition contains[cd] %@",dID,dName,searchText];
    }else {
        predicate = [NSPredicate predicateWithFormat:@"dID=%@ and dName = %@",dID,dName];
    }
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createDate" ascending:NO];
    
    fetchRequest.predicate = predicate;
    fetchRequest.sortDescriptors = @[sortDescriptor];
    
    self.fetchResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.coreDataStack.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    self.fetchResultController.delegate = self;
    NSError *error = nil;
    if (![self.fetchResultController performFetch:&error]) {
        NSLog(@"error: %@",error.description);
        abort();
    }else {
        [self.tableView reloadData];
    }
}
-(void)setUpTableView
{
    self.tableView.layer.shadowOffset = CGSizeMake(15, 13);
    self.tableView.layer.shadowOpacity = 1;
    self.tableView.layer.shadowRadius = 20;
    self.tableView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    
    self.tableView.layer.borderWidth = 1;
    //self.tableView.estimatedRowHeight = 55;
    //self.tableView.rowHeight = UITableViewAutomaticDimension;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSString *titleStr = [self.templateName stringByAppendingString:@"模板"];
    self.title = titleStr;
    
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createTemplateForTest];
    
    [self setUpTableView];
    
    [self setUpFetchViewControllerWithSearchText:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectedCellLabel:) name:@"didSelectedTitleLabel" object:nil];
    
    ///for test
}
-(void)createTemplateForTest
{
    NSString *dID = @"99999";
    NSString *dName = @"涨涨我";
    NSString *section = @"主诉";
    NSString *condition = @"性别男  心内科 心绞痛";
    NSString *content = @"性别男  心内科 心绞痛创建于2015年10月";
    NSString *updatedTime =[NSString stringWithFormat:@"%@",[self getSystemCurrentTime]];
    NSString *createDate = [NSString stringWithFormat:@"%@",[self getSystemCurrentTime]];
    NSString *sourceType = @"个人";
    NSString *createPeople = @"网意商";
    NSDictionary *dic = NSDictionaryOfVariableBindings(dID,dName,section,content,condition,updatedTime,sourceType,createPeople,createDate);
    
    [self.coreDataStack createTemplateManagedObjectWithDataDic:dic successfulCreated:^{
        
    } failedToCreated:^(NSError *error, NSString *errorInfo) {
        
    }];
    condition = @"网意商科室现病史";
    sourceType = @"科室";
    section = @"现病史";
    NSDictionary *dict = NSDictionaryOfVariableBindings(dID,dName,section,content,condition,updatedTime,sourceType,createPeople,createDate);
    [self.coreDataStack createTemplateManagedObjectWithDataDic:dict successfulCreated:^{
        
    } failedToCreated:^(NSError *error, NSString *errorInfo) {
        
    }];

}
-(NSDate*)getSystemCurrentTime
{
    NSDate *newDate = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSTimeInterval interval = [zone secondsFromGMTForDate:newDate];
    NSDate *localDate = [newDate dateByAddingTimeInterval:interval];
    
    return localDate;
}

-(void)didSelectedCellLabel:(NSNotification*) notification
{
    id tempID = [notification object];
    if ([tempID isKindOfClass:[NSString class]]) {
        self.templateName = (NSString*)tempID;
    }else if([tempID isKindOfClass:[WLKCaseNode class]]){
        WLKCaseNode *tempNode =(WLKCaseNode*) [notification object];
        self.templateName = tempNode.nodeName;
    }
//    NSPredicate *predicate;
//    [self.coreDataStack fetchManagedObjectInContext:self.managedObjectContext WithEntityName:[Template entityName] withPredicate:predicate successfulFetched:^(NSArray *resultArray) {
//        
//        if (resultArray.count == 0) {
//            
//        }else {
//            
//        }
//    } failedToFetched:^(NSError *error, NSString *errorInfo) {
//        
//    }];
    [self setUpFetchViewControllerWithSearchText:nil];
    
    NSString *titleStr = [self.templateName stringByAppendingString:@"模板"];
    self.title = titleStr;    
}

#pragma mask - table view delegate && data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"section count %@", @(self.fetchResultController.sections.count));
    return self.fetchResultController.sections.count ;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchResultController.sections[section];
    NSLog(@"%@",@([sectionInfo numberOfObjects]));
    return [sectionInfo numberOfObjects];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  WriteCaseShowTemplateCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WriteShowTemplate"];
    [self configureCell:cell AtIndexPath:indexPath];
    
    return cell;
}
-(void)configureCell:(WriteCaseShowTemplateCell*)cell AtIndexPath:(NSIndexPath*)indexPath
{
    Template *template = [self.fetchResultController objectAtIndexPath:indexPath];
    
    cell.accessoryType  = UITableViewCellAccessoryDetailButton;

    cell.sourcelabel.text = template.sourceType;//来源个人，科室
    cell.createPeopleLabel.text = template.createPeople;
    
    NSString *content;
    if (template.content.length > 100) {
        content = [NSString stringWithFormat:@"%@...", [template.content substringToIndex:100]];
    }else {
        content = template.content;
    }

    cell.contentLabel.text  = content;
}
-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    ///查看模板的详细内容
    Template *template = [self.fetchResultController objectAtIndexPath:indexPath];
    self.currentTemplate = template;
    
    [self performSegueWithIdentifier:@"templateContent" sender:nil];

}
//- (void)setContntStrForCell:(WriteCaseShowTemplateCell *)cell withTitleString:(NSString*)contentStr {
//    
//    
//    NSString *subtitle = self.testData[@"content"];
//    
//    if (subtitle.length > 100) {
//        subtitle = [NSString stringWithFormat:@"%@...", [subtitle substringToIndex:100]];
//    }
//    
//    [cell.contentLabel setText:subtitle];
//}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Template *template = [self.fetchResultController objectAtIndexPath:indexPath];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.showTemplateDelegate didSelectedTemplateWithNode:template withTitleStr:self.templateName];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self heightForBasicCellAtIndexPath:indexPath];
}
- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath {
    static WriteCaseShowTemplateCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [self.tableView dequeueReusableCellWithIdentifier:@"WriteShowTemplate"];
    });
    
    [self configureCell:sizingCell AtIndexPath:indexPath];
    return [self calculateHeightForConfiguredSizingCell:sizingCell];
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell {
    
    sizingCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.frame), CGRectGetHeight(sizingCell.bounds));

    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height + 1.0f; // Add 1.0f for the cell separator height
}
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    if ([searchBar isFirstResponder]) {
        [searchBar resignFirstResponder];
    }
    searchBar.text = @"";
    [self.searchBar setShowsCancelButton:NO animated:YES];
    
    [self setUpFetchViewControllerWithSearchText:nil];

}
-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    [self.searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSString *searchText = searchBar.text;
    
    [self setUpFetchViewControllerWithSearchText:searchText];
}
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self setUpFetchViewControllerWithSearchText:searchText];

}
//#pragma mask - fetch view controller delegate
///// fetch result controller delegate
//-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller
//{
//    [self.tableView beginUpdates];
//}
//-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
//{
//    switch (type) {
//        case NSFetchedResultsChangeInsert:{
//            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//            break;
//        }
//        case NSFetchedResultsChangeDelete:{
//            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//            break;
//        }
//        case NSFetchedResultsChangeUpdate:{
//            break;
//        }
//            
//        default:
//            break;
//    }
//}
//-(void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
//{
//    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:sectionIndex];
//    switch (type) {
//        case NSFetchedResultsChangeInsert:
//            [self.tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
//            break;
//        case NSFetchedResultsChangeDelete:
//            [self.tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
//            break;
//        default:
//            break;
//    }
//}
//-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
//{
//    [self.tableView endUpdates];
//}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"templateContent"]) {
        TemplateDetailViewController *templateVC = (TemplateDetailViewController*)segue.destinationViewController;
        templateVC.template = self.currentTemplate;
    }
}

@end
