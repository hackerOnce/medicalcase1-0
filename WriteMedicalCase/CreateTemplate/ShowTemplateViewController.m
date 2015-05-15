//
//  ShowTemplateViewController.m
//  MedicalCase
//
//  Created by ihefe-JF on 15/4/3.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import "ShowTemplateViewController.h"
#import "Constants.h"
#import "CoreDataStack.h"
#import "ParentNode.h"
#import "Node.h"
#import "Template.h"
#import "ShowTemplateDetailViewController.h"
#import "SelectedShareRangeViewController.h"

#import "ShowTemplateTableViewCell.h"

@interface ShowTemplateViewController ()<UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate,ShowTemplateTableViewCellDelegate>
@property (nonatomic,strong) CoreDataStack *coreDataStack;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) CGFloat keyboardOverlap;

@property (nonatomic,strong) NSFetchedResultsController *fetchResultController;

@property (nonatomic, strong) NSMutableArray *cellsCurrentlyEditing;

@property (nonatomic) BOOL isNewsPage;

@property (nonatomic) NSInteger test;
@end
@implementation ShowTemplateViewController

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
- (IBAction)cancelBtn:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.cellsCurrentlyEditing = [NSMutableArray array];

    [self setUpTableView];
    [self addKVOObserver];
}
-(void)setUpTableView
{
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.title = @"病历模板展示";
    
    
}
-(void)addKVOObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTableView:) name:kDidSelectedFinalTemplate object:nil];
}

-(void)updateTableView:(NSNotification*)info
{
    
    NSString *tempStr = (NSString*)[info object];
//    NSString *tempStr = [info.userInfo objectForKey:selectedTemplateClassification];
    NSLog(@"%@",tempStr);
    if ([tempStr isEqualToString:@"消息"]) {
        tempStr = @"主诉";
        self.isNewsPage = YES;
    }else {
        self.isNewsPage = NO;

    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:[Template entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"node.nodeName = %@",tempStr];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createDate" ascending:NO];
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
        [self.tableView reloadData];

    }
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
    return [sectionInfo numberOfObjects] ;
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   // if (indexPath.row == self.test-1) {
        ShowTemplateTableViewCell *cell = (ShowTemplateTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"swipeCell"];
        cell.delegate = self;
        cell.isNewsPage = self.isNewsPage;

        [self configCell:cell withIndexPath:indexPath];
        
        if ([self.cellsCurrentlyEditing containsObject:indexPath]) {
            [cell openCell];
        }

        return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"templateDetail" sender:nil];
}

///table view delete
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Template *template =(Template*) [self.fetchResultController objectAtIndexPath:indexPath];
        [self.managedObjectContext deleteObject:template];
        [self.coreDataStack saveContext];
    }
}
-(void)configCell:(ShowTemplateTableViewCell*)cell withIndexPath:(NSIndexPath*)indexPath
{
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    Template *template =(Template*) [self.fetchResultController objectAtIndexPath:indexPath];
    
    NSLog(@"template condition : %@",template.condition);
    NSLog(@"template content : %@",template.content);
    NSLog(@"template create date : %@",template.createDate);
    
    
    UILabel *conditionLabel = (UILabel*)[cell viewWithTag:1001];
    UILabel *contentLabel = (UILabel*)[cell viewWithTag:1003];
    
    conditionLabel.text = template.condition;
    
    NSString *content;
    if (template.content.length > 100) {
        content = [NSString stringWithFormat:@"%@...", [template.content substringToIndex:100]];
    }else {
        content = template.content;
    }
    
    contentLabel.text = content;

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self heightForBasicCellAtIndexPath:indexPath];
}
- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath {
    static ShowTemplateTableViewCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [self.tableView dequeueReusableCellWithIdentifier:@"swipeCell"];
    });
    sizingCell.isNewsPage = self.isNewsPage;
    [self configCell:sizingCell withIndexPath:indexPath];
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

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchResultController.sections[section];
    return sectionInfo.name;
}


- (void)cellDidOpen:(UITableViewCell *)cell
{
    NSIndexPath *currentEditingIndexPath = [self.tableView indexPathForCell:cell];
    [self.cellsCurrentlyEditing addObject:currentEditingIndexPath];
}

- (void)cellDidClose:(UITableViewCell *)cell
{
    [self.cellsCurrentlyEditing removeObject:[self.tableView indexPathForCell:cell]];
}

-(void)buttonDeleteActionClicked:(UIButton *)sender withCell:(ShowTemplateTableViewCell *)cell
{
    
}
-(void)buttonMoreActionClicked:(UIButton *)sender withCell:(ShowTemplateTableViewCell *)cell
{
    
}
-(void)buttonShareActionClicked:(UIButton *)sender withCell:(ShowTemplateTableViewCell *)cell
{
    UIStoryboard *myStoryBoard = self.storyboard;
    UINavigationController *shareRangeVC = [myStoryBoard instantiateViewControllerWithIdentifier:@"SelectedShareRangeNav"];
    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:shareRangeVC];
    [popover presentPopoverFromRect:sender.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
}
-(void)buttonIgnoreActionClicked:(UIButton *)sender withCell:(ShowTemplateTableViewCell *)cell
{
    
}
-(void)buttonAcceptActionClicked:(UIButton *)sender withCell:(ShowTemplateTableViewCell *)cell
{
    
}
-(void)buttonCancellationOfShareActionClicked:(UIButton *)sender withCell:(ShowTemplateTableViewCell *)cell
{
    
}
-(void)dealloc
{
   
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    [formatter setDateFormat:@"EEE"];
//[formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    monthStr = [formatter stringFromDate:date];
    return monthStr;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"templateDetail"]) {
        ShowTemplateDetailViewController *templateDetailVC = (ShowTemplateDetailViewController*)segue.destinationViewController;
        //
    }
}
@end
