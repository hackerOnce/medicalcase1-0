//
//  ConditionTemplateViewController.m
//  MedicalCase
//
//  Created by ihefe-JF on 15/4/22.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import "ConditionTemplateViewController.h"
#import "ConditionTemplateVCTableViewCell.h"
#import "Template.h"

@interface ConditionTemplateViewController ()<NSFetchedResultsControllerDelegate,UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) CoreDataStack *coreDataStack;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,strong) NSString *selectedStr;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) NSFetchedResultsController *fetchResultController;
@end

@implementation ConditionTemplateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.autoresizesSubviews = NO;
    [self setUpTableView];
    
    [self setUpFetchViewController];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectedCellLabel:) name:@"containerToSub" object:nil];
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
    [self setUpFetchViewController];
    
}
-(void)setTemplateName:(NSString *)templateName
{
    _templateName = templateName;
    self.title = [_templateName stringByAppendingString:@"模板"];
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

-(void)setUpFetchViewController
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:[Template entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"node.nodeName = %@",self.templateName];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createDate" ascending:NO];
    
    
    //  NSSortDescriptor *sortDescriptor = nil;
    fetchRequest.predicate = predicate;
    fetchRequest.sortDescriptors = @[sortDescriptor];
    
    self.fetchResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.coreDataStack.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    self.fetchResultController.delegate = self;
    NSError *error = nil;
    if (![self.fetchResultController performFetch:&error]) {
        NSLog(@"error: %@",error.description);
        abort();
    }else {
        // Template *template = [self.fetchResultController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        // NSLog(@"template condition : %@",template.condition);
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
    // self.tableView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.tableView.estimatedRowHeight = 55;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
}

#pragma mask - table view delegate && data source
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
    ConditionTemplateVCTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellMyTemplate"];
    cell.autoresizesSubviews = NO;
    [self configureCell:cell AtIndexPath:indexPath];
    
    return cell;
}
-(void)configureCell:(ConditionTemplateVCTableViewCell*)cell AtIndexPath:(NSIndexPath*)indexPath
{
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    Template *template = [self.fetchResultController objectAtIndexPath:indexPath];
    //UILabel *cellLabel = (UILabel*)[cell viewWithTag:1001];
    UITextView *textView = (UITextView*)[cell viewWithTag:1002];
    
    textView.text = template.content;
    //textView.text = ([template.content isEqualToString:template.content]) ? @" ": template.content;
    [textView layoutIfNeeded];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Template *template = [self.fetchResultController objectAtIndexPath:indexPath];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
       
    [self.delegate didSelectedTemplateWithNode:template];
}
#pragma mask - fetch view controller delegate
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
            break;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
