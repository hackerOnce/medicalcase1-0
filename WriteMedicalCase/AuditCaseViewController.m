//
//  AuditCaseViewController.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/27.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "AuditCaseViewController.h"
#import "CaseContent.h"
#import "AuditCaseCell.h"

@interface AuditCaseViewController ()<UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate,AuditCaseCellDelegate>
@property (nonatomic,strong) CoreDataStack *coreDataStack;

@property (nonatomic,strong) NSMutableDictionary *viewDict;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@property (nonatomic,strong) RecordBaseInfo *recordBaseInfo;
@property (nonatomic,strong) NSFetchedResultsController *fetchResultController;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *commitButton;

@property (nonatomic) BOOL isResidentNote; //是入院记录
@end

@implementation AuditCaseViewController

#pragma mask - core data
-(NSManagedObjectContext *)managedObjectContext
{
    return self.coreDataStack.managedObjectContext;
}
-(CoreDataStack *)coreDataStack
{
    _coreDataStack = [[CoreDataStack alloc] init];
    return _coreDataStack;
}


#pragma mask - view vontroller life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpTableView];
    
    //for test
    [self setUpFetchViewController];
    self.isResidentNote=  YES;
}

-(void)setUpTableView
{
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.title = @"住院病历";
    self.tableView.estimatedRowHeight = 55;
    self.tableView.rowHeight = UITableViewAutomaticDimension;

}
- (IBAction)cancelButton:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)commitButton:(UIBarButtonItem *)sender {
    
    
}

#pragma  mask - set methods
-(void)setRecordBaseInfo:(RecordBaseInfo *)recordBaseInfo
{
    self.isResidentNote = YES;
    
    _recordBaseInfo = recordBaseInfo;
    
    ParentNode *parentNode = [self.coreDataStack fetchParentNodeWithNodeEntityName:@"入院记录"];
    CaseContent *tempCaseContent = (CaseContent*)_recordBaseInfo.caseContent;
    NSArray *tempArray = @[tempCaseContent.chiefComplaint?tempCaseContent.chiefComplaint:@"",tempCaseContent.historyOfPresentillness?tempCaseContent.historyOfPresentillness:@"",tempCaseContent.personHistory?tempCaseContent.personHistory:@"",tempCaseContent.pastHistory?tempCaseContent.pastHistory:@"",tempCaseContent.familyHistory?tempCaseContent.familyHistory:@"",tempCaseContent.obstericalHistory?tempCaseContent.obstericalHistory:@"",tempCaseContent.physicalExamination?tempCaseContent.physicalExamination:@"",tempCaseContent.systemsReview?tempCaseContent.systemsReview:@"",tempCaseContent.specializedExamination?tempCaseContent.specializedExamination:@"",tempCaseContent.tentativeDiagnosis?tempCaseContent.tentativeDiagnosis:@"",tempCaseContent.admittingDiagnosis?tempCaseContent.admittingDiagnosis:@"",tempCaseContent.confirmedDiagnosis?tempCaseContent.confirmedDiagnosis:@""];
    
    for (int i=0; i< parentNode.nodes.count; i++) {
        Node *tempNode = parentNode.nodes[i];
        
        NSString *key = [[self caseInfoArray] objectAtIndex:i];
        if ([tempNode.nodeEnglish isEqualToString:key]) {
            tempNode.nodeContent = tempArray[i];
        }
    }
    
   // [self setUpFetchViewController];
}
-(void)setUpFetchViewController
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:[Node entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"parentNode.nodeName = %@",@"入院记录"];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"nodeIndex" ascending:YES];
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
-(NSArray *)caseInfoArray
{
    return @[@"chiefComplaint",@"historyOfPresentillness",@"personHistory",@"pastHistory",@"familyHistory",@"obstericalHistory",@"physicalExamination",@"systemsReview",@"specializedExamination",@"tentativeDiagnosis",@"admittingDiagnosis",@"confirmedDiagnosis",];
}

#pragma mask - view dict for footer view and header view
-(NSMutableDictionary *)viewDict
{
    if (!_viewDict) {
        _viewDict = [[NSMutableDictionary alloc] init];
    }
   return  _viewDict;
}
#pragma mask - table view data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchResultController.sections[section];
        return [sectionInfo numberOfObjects];
    }else {
        return 5;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    if (self.isResidentNote) {
        AuditCaseCell *auditCell =(AuditCaseCell*)[tableView dequeueReusableCellWithIdentifier:@"auditCell"];
        
        [self configureCell:auditCell AtIndexPath:indexPath];
        return auditCell;
    }else {
        AuditCaseCell *cell = [tableView dequeueReusableCellWithIdentifier:@"auditCell"];
        UILabel *cellLabel = (UILabel*)[cell viewWithTag:1001];
        UILabel *contentLabel = (UILabel*)[cell viewWithTag:1002];
        
        cellLabel.text = [NSString stringWithFormat:@"%@",@(indexPath.row)];
        contentLabel.text = [NSString stringWithFormat:@"%@",@(indexPath.section)];
        
        return cell;
    }
    
}
-(void)configureCell:(AuditCaseCell*)cell AtIndexPath:(NSIndexPath*)indexPath
{
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    Node *tempNode = [self.fetchResultController objectAtIndexPath:indexPath];
    cell.delegate = self;
    UILabel *cellLabel = (UILabel*)[cell viewWithTag:1001];
    UITextView *textView = (UITextView*)[cell viewWithTag:1002];
    
    cell.autoresizesSubviews = NO;
    
    cellLabel.text = tempNode.nodeName;
    textView.text = ([tempNode.nodeContent isEqualToString:tempNode.nodeName]) ? @" ": tempNode.nodeContent;
    [textView layoutIfNeeded];
}
#pragma mask - WriteCaseSaveCell  delegate
-(void)textViewCell:(AuditCaseCell *)cell didChangeText:(NSString *)text
{
    if (self.isResidentNote) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        Node *tempNode = [self.fetchResultController objectAtIndexPath:indexPath];
        tempNode.nodeContent = text;
        [self.coreDataStack saveContext];
    }
}
-(void)textViewDidBeginEditing:(UITextView *)textView withCellIndexPath:(NSIndexPath *)indexPath
{
    //[self updateButtonState];
//    self.isBeginEdit = NO;
//    
//    self.currentIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
//    self.currentTextView = textView;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];

        headerView.backgroundColor = [UIColor whiteColor];
        
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 8, 200, 33)];
        headerLabel.tag = 101;
        headerLabel.text = [NSString stringWithFormat:@"入院记录"];
        headerLabel.textColor = [UIColor colorWithRed:120/255.0 green:118/255.0 blue:118/255.0 alpha:1];
        [headerView addSubview:headerLabel];
        
        UIButton *headerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        headerButton.tag = 102;
        headerButton.frame = CGRectMake(CGRectGetWidth(tableView.frame) - 33 - 8, 8, 33, 33);
        headerButton.layer.cornerRadius = CGRectGetHeight(headerButton.frame)/2;
        headerButton.titleLabel.font = [UIFont systemFontOfSize:12];
        headerButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        headerButton.layer.borderWidth = 1;
        [headerButton setTitleColor:[UIColor colorWithRed:113/255.0 green:170/255.0 blue:236/255.0 alpha:1] forState:UIControlStateNormal];
        [headerButton setTitle:@"撤销" forState:UIControlStateNormal];
        [headerView addSubview:headerButton];
        headerButton.backgroundColor = [UIColor whiteColor];
        [headerButton addTarget:self action:@selector(headerViewButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
       UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, CGRectGetWidth(tableView.frame), 1)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [headerView addSubview:lineView];
    
        [self.viewDict setObject:headerView forKey:@"headerView"];
        return headerView;
    
}
-(void)headerViewButtonTapped:(UIButton*)sender
{
    //撤销
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [self.viewDict objectForKey:@"footerView"];
    if (footerView) {
        return footerView;
    }else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"auditCell"];
        footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, 10)];
        footerView.backgroundColor = [UIColor colorWithRed:234/255.0 green:238/255.0 blue:242.0/255 alpha:1];
        
        return footerView;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 45;
}
@end
