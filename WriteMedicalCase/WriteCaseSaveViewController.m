//
//  WriteCaseSaveViewController.m
//  WriteMedicalCase
//
//  Created by GK on 15/4/29.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "WriteCaseSaveViewController.h"
#import "WriteCaseSaveCell.h"
#import "WriteCaseEditViewController.h"
#import "NSDate+Helper.h"
#import "writeCaseFirstItemViewController.h"
#import "IHMsgSocket.h"
#import "MessageObject+DY.h"
#import "CaseContent.h"

@interface WriteCaseSaveViewController ()<NSFetchedResultsControllerDelegate,WriteCaseSaveCellDelegate,UITableViewDelegate,UITableViewDataSource,WriteCaseEditViewControllerDelegate,writeCaseFirstItemViewControllerDelegate,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UILabel *remainTimeLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

//core data
@property (nonatomic,strong) CoreDataStack *coreDataStack;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic,strong) NSFetchedResultsController *fetchResultController;

//key board
@property (nonatomic) CGFloat keyboardOverlap;
@property (nonatomic,strong) NSIndexPath *currentIndexPath;
@property (nonatomic,strong) UITextView *currentTextView;

@property (nonatomic) BOOL keyboardShow;
@property (nonatomic,strong) NSString *selectedStr;

@property (nonatomic) BOOL isBeginEdit;

@property (nonatomic,strong) RecordBaseInfo *recordBaseInfo;
//@property (nonatomic) BOOL hasContent;
@property (nonatomic,strong) NSString *textViewContent;

///
@property (nonatomic,strong) IHMsgSocket *socket;

@property (nonatomic) BOOL doctorCreatedSucess;
@property (nonatomic) BOOL patientCreateSucess;

@property (nonatomic,strong) NSArray *caseInfoArray;

@property (nonatomic,strong) NSMutableDictionary *caseInfoDict;

@property (nonatomic,strong) RecordBaseInfo *resultCaseInfo;

@property (nonatomic,strong) NSMutableDictionary *originDict;
@end

@implementation WriteCaseSaveViewController
@synthesize tempResidentDoctor = _tempResidentDoctor;
@synthesize tempPatient = _tempPatient;
///test data

-(IHMsgSocket *)socket
{
    if (!_socket) {
        _socket = [IHMsgSocket sharedRequest];
        [_socket connectToHost:@"192.168.10.106" onPort:2323];
    }
    return _socket;
}

/// load data
-(NSString *)caseType
{
    if (!_caseType) {
        _caseType = @"入院病历";
    }
    return _caseType;
}
-(NSDictionary*)testData
{
    NSString *pID = self.currentPatient.pID;
    NSString *pName = self.currentPatient.pName;
    NSString *dID = self.currentDoctor.dID;
    NSString *dName = self.currentDoctor.dName;
    NSString *caseType;
    if (self.caseType) {
        caseType = self.caseType;
    }else {
        caseType = @"error";
    }

    return NSDictionaryOfVariableBindings(pID,pName,dID,dName);
}

- (IBAction)saveButton:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请稍后，正在保存 . . ." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    
    [alertView show];

    alertView.backgroundColor = [UIColor blueColor];
    
    NSMutableDictionary *caseContent = [[NSMutableDictionary alloc] init];

    RecordBaseInfo *recordBaseInfo = [self.coreDataStack fetchRecordWithDict:[self caseKeyDic]];
    ParentNode *parentNode = [self.coreDataStack fetchParentNodeWithNodeEntityName:@"入院记录"];
    CaseContent *tempCaseContent = (CaseContent*)recordBaseInfo.caseContent;

    for (int i=0; i< parentNode.nodes.count; i++) {
        Node *tempNode = parentNode.nodes[i];
        
        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
        [tempDict setObject:tempNode.nodeContent forKey:tempNode.nodeEnglish];
        [caseContent setObject:tempDict forKey:tempNode.nodeEnglish];
        
        if ([tempNode.nodeEnglish isEqualToString:@"chiefComplaint"]) {
            tempCaseContent.chiefComplaint = tempNode.nodeContent;
        }else if([tempNode.nodeEnglish isEqualToString:@"historyOfPresentillness"]){
            tempCaseContent.historyOfPresentillness = tempNode.nodeContent;
        }else if ([tempNode.nodeEnglish isEqualToString:@"personHistory"]) {
            tempCaseContent.personHistory = tempNode.nodeContent;
        }else if ([tempNode.nodeEnglish isEqualToString:@"pastHistory"]) {
            tempCaseContent.pastHistory = tempNode.nodeContent;
        }else if ([tempNode.nodeEnglish isEqualToString:@"familyHistory"]) {
            tempCaseContent.familyHistory = tempNode.nodeContent;
        }else if ([tempNode.nodeEnglish isEqualToString:@"obstericalHistory"]) {
            tempCaseContent.obstericalHistory = tempNode.nodeContent;
        }else if([tempNode.nodeEnglish isEqualToString:@"physicalExamination"]){
            tempCaseContent.physicalExamination = tempNode.nodeContent;
        }else if([tempNode.nodeEnglish isEqualToString:@"systemsReview"]){
            tempCaseContent.systemsReview = tempNode.nodeContent;
        }else if([tempNode.nodeEnglish isEqualToString:@"specializedExamination"]){
            tempCaseContent.specializedExamination = tempNode.nodeContent;
        }else if([tempNode.nodeEnglish isEqualToString:@"tentativeDiagnosis"]){
            tempCaseContent.tentativeDiagnosis = tempNode.nodeContent;
        }else if([tempNode.nodeEnglish isEqualToString:@"admittingDiagnosis"]){
            tempCaseContent.admittingDiagnosis = tempNode.nodeContent;
        }else if([tempNode.nodeEnglish isEqualToString:@"confirmedDiagnosis"]){
            tempCaseContent.confirmedDiagnosis = tempNode.nodeContent;
        }
        

    }

    
    //alertView.title = @"保存成功";
   
    [self.originDict setObject:caseContent forKey:@"caseContent"];
    
    [MessageObject messageObjectWithUsrStr:@"1" pwdStr:@"test" iHMsgSocket:self.socket optInt:10001 dictionary:self.originDict block:^(IHSockRequest *request) {
        
        alertView.title = @"保存成功";
        
        [self.coreDataStack saveContext];
    } failConection:^(NSError *error) {
       // [self.coreDataStack saveContext];
    }];
    
}

-(NSArray *)caseInfoArray
{
    return @[@"chiefComplaint",@"historyOfPresentillness",@"personHistory",@"pastHistory",@"familyHistory",@"obstericalHistory",@"physicalExamination",@"systemsReview",@"specializedExamination",@"tentativeDiagnosis",@"admittingDiagnosis",@"confirmedDiagnosis",];
}
-(void)setRecordBaseInfo:(RecordBaseInfo *)recordBaseInfo
{
    _recordBaseInfo = recordBaseInfo;
    
    
   ParentNode *parentNode = [self.coreDataStack fetchParentNodeWithNodeEntityName:@"入院记录"];
    CaseContent *tempCaseContent = (CaseContent*)_recordBaseInfo.caseContent;
    NSArray *tempArray = @[tempCaseContent.chiefComplaint?tempCaseContent.chiefComplaint:@"",tempCaseContent.historyOfPresentillness?tempCaseContent.historyOfPresentillness:@"",tempCaseContent.personHistory?tempCaseContent.personHistory:@"",tempCaseContent.personHistory?tempCaseContent.personHistory:@"",tempCaseContent.familyHistory?tempCaseContent.familyHistory:@"",tempCaseContent.obstericalHistory?tempCaseContent.obstericalHistory:@"",tempCaseContent.physicalExamination?tempCaseContent.physicalExamination:@"",tempCaseContent.systemsReview?tempCaseContent.systemsReview:@"",tempCaseContent.specializedExamination?tempCaseContent.specializedExamination:@"",tempCaseContent.tentativeDiagnosis?tempCaseContent.tentativeDiagnosis:@"",tempCaseContent.admittingDiagnosis?tempCaseContent.admittingDiagnosis:@"",tempCaseContent.confirmedDiagnosis?tempCaseContent.confirmedDiagnosis:@""];
    
    for (int i=0; i< parentNode.nodes.count; i++) {
        Node *tempNode = parentNode.nodes[i];
        
        NSString *key = [[self caseInfoArray] objectAtIndex:i];
        if ([tempNode.nodeEnglish isEqualToString:key]) {
            tempNode.nodeContent = tempArray[i];
        }
    }
    
    [self setUpFetchViewController];
}
///core data
-(NSManagedObjectContext *)managedObjectContext
{
    return self.coreDataStack.managedObjectContext;
}
-(CoreDataStack *)coreDataStack
{
    _coreDataStack = [[CoreDataStack alloc] init];
    return _coreDataStack;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.remainTimeLabel.text =[NSString stringWithFormat:@"剩余时间:08:00:00"];
}
-(NSString*)getYearAndMonthWithDateStr:(NSDate*)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *dateStr = [formatter stringFromDate:date];
    
    NSLog(@"date : %@",dateStr);
    
    return dateStr;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setUpTableView];
    
    [self caseRecordFromServerOrLocal];
}

-(void)setUpTableView
{
    self.tableView.layer.shadowOffset = CGSizeMake(15, 13);
    self.tableView.layer.shadowOpacity = 1;
    self.tableView.layer.shadowRadius = 20;
    self.tableView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    
    self.tableView.layer.borderWidth = 1;
    self.tableView.estimatedRowHeight = 55;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}
-(NSDictionary*)caseKeyDic
{
    return @{@"did":@"11",@"pid":@"5536",@"caseType":@"入院病历"};
}
-(void)caseRecordFromServerOrLocal
{
    NSDictionary *dict = [NSDictionary dictionaryWithDictionary:[self caseKeyDic]];
    
     self.recordBaseInfo = [self.coreDataStack fetchRecordWithDict:dict];
    [MessageObject messageObjectWithUsrStr:@"1" pwdStr:@"test" iHMsgSocket:self.socket optInt:1500 dictionary:dict block:^(IHSockRequest *request) {
        
        if(request.resp == -1){
            
            self.recordBaseInfo = [self.coreDataStack fetchRecordWithDict:dict];
        
        }else {
            if ([request.responseData isKindOfClass:[NSDictionary class]]) {
                
                NSDictionary *tempDict =(NSDictionary*) request.responseData;
                self.originDict = [[NSMutableDictionary alloc] initWithDictionary:tempDict];
                
                self.caseInfoDict = [[NSMutableDictionary alloc] initWithDictionary:[self parseCaseInfoWithDic:tempDict]];
                
                self.recordBaseInfo = [self.coreDataStack fetchRecordWithDict:self.caseInfoDict];
            }
        }
        
    } failConection:^(NSError *error) {
        self.recordBaseInfo = [self.coreDataStack fetchRecordWithDict:dict];
    }];
}
-(NSDictionary*)parseCaseInfoWithDic:(NSDictionary*)dataDic
{
    NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
    
    if ([dataDic.allKeys containsObject:@"_DOF"]) {
        [tempDic setObject:dataDic[@"_DOF"] forKey:@"archivedTime"];
    }
    if ([dataDic.allKeys containsObject:@"_created"]) {
        [tempDic setObject:dataDic[@"_created"] forKey:@"createdTime"];
    }
    if ([dataDic.allKeys containsObject:@"_id"]) {
        [tempDic setObject:dataDic[@"_id"] forKey:@"caseID"];
    }
    
    if ([dataDic.allKeys containsObject:@"_updated"]) {
        [tempDic setObject:dataDic[@"_updated"] forKey:@"updatedTime"];
    }
    if ([dataDic.allKeys containsObject:@"caseBaseInfo"]) {
        
        NSDictionary *dic = dataDic[@"caseBaseInfo"];
        
        if ([dic.allKeys containsObject:@"casePresenter"]) {
            [tempDic setObject:dic[@"casePresenter"]forKey:@"casePresenter"];
        }
        if ([dic.allKeys containsObject:@"caseEditStatus"]) {
            [tempDic setObject:dic[@"caseEditStatus"]forKey:@"caseEditStatus"];
        }
        if ([dic.allKeys containsObject:@"caseStatus"]) {
            [tempDic setObject:dic[@"caseStatus"]forKey:@"caseStatus"];
        }
    }
    if ([dataDic.allKeys containsObject:@"caseContent"]) {
        NSDictionary *dic = dataDic[@"caseContent"];
        
        if ([dic.allKeys containsObject:@"chiefComplaint"]) {
            [tempDic setObject:dic[@"chiefComplaint"] forKey:@"chiefComplaint"];
        }
        if ([dic.allKeys containsObject:@"historyOfPresentillness"]) {
            [tempDic setObject:dic[@"historyOfPresentillness"] forKey:@"historyOfPresentillness"];
        }
        if ([dic.allKeys containsObject:@"personHistory"]) {
            [tempDic setObject:dic[@"personHistory"] forKey:@"personHistory"];
        }
        if ([dic.allKeys containsObject:@"pastHistory"]) {
            [tempDic setObject:dic[@"pastHistory"] forKey:@"pastHistory"];
        }

        if ([dic.allKeys containsObject:@"familyHistory"]) {
            [tempDic setObject:dic[@"familyHistory"] forKey:@"familyHistory"];
        }
        if ([dic.allKeys containsObject:@"obstericalHistory"]) {
            [tempDic setObject:dic[@"obstericalHistory"] forKey:@"obstericalHistory"];
        }
        if ([dic.allKeys containsObject:@"physicalExamination"]) {
            [tempDic setObject:dic[@"physicalExamination"] forKey:@"physicalExamination"];
        }

        if ([dic.allKeys containsObject:@"systemsReview"]) {
            [tempDic setObject:dic[@"systemsReview"] forKey:@"systemsReview"];
        }
        if ([dic.allKeys containsObject:@"specializedExamination"]) {
            [tempDic setObject:dic[@"specializedExamination"] forKey:@"specializedExamination"];
        }
        
        if ([dic.allKeys containsObject:@"tentativeDiagnosis"]) {
            [tempDic setObject:dic[@"tentativeDiagnosis"] forKey:@"tentativeDiagnosis"];
        }
        if ([dic.allKeys containsObject:@"obstericalHistory"]) {
            [tempDic setObject:dic[@"obstericalHistory"] forKey:@"obstericalHistory"];
        }
        if ([dic.allKeys containsObject:@"admittingDiagnosis"]) {
            [tempDic setObject:dic[@"admittingDiagnosis"] forKey:@"admittingDiagnosis"];
        }
        
        if ([dic.allKeys containsObject:@"confirmedDiagnosis"]) {
            [tempDic setObject:dic[@"confirmedDiagnosis"] forKey:@"confirmedDiagnosis"];
        }

    }
    if ([dataDic.allKeys containsObject:@"caseType"]) {
        [tempDic setObject:dataDic[@"caseType"] forKey:@"caseType"];
    }
    
    if ([dataDic.allKeys containsObject:@"resident"]) {
        NSDictionary *doctor = dataDic[@"resident"];
        if ([doctor.allKeys containsObject:@"dID"]) {
            [tempDic setObject:doctor[@"dID"] forKey:@"residentdID"];
        }
        if ([doctor.allKeys containsObject:@"dName"]) {
            [tempDic setObject:doctor[@"dName"] forKey:@"residentdID"];
        }
    }
    if ([dataDic.allKeys containsObject:@"attendingPhysician"]) {
        NSDictionary *doctor = dataDic[@"attendingPhysician"];
        if ([doctor.allKeys containsObject:@"dID"]) {
            [tempDic setObject:doctor[@"dID"] forKey:@"attendingPhysiciandID"];
        }
        if ([doctor.allKeys containsObject:@"dName"]) {
            [tempDic setObject:doctor[@"dName"] forKey:@"attendingPhysiciandName"];
        }
    }
    if ([dataDic.allKeys containsObject:@"chiefPhysician"]) {
        NSDictionary *doctor = dataDic[@"chiefPhysician"];
        if ([doctor.allKeys containsObject:@"dID"]) {
            [tempDic setObject:doctor[@"dID"] forKey:@"chiefPhysiciandID"];
        }
        if ([doctor.allKeys containsObject:@"dName"]) {
            [tempDic setObject:doctor[@"dName"] forKey:@"chiefPhysiciandName"];
        }
    }

    if ([dataDic.allKeys containsObject:@"patient"]) {
        NSDictionary *patient = dataDic[@"patient"];
        
        if ([patient.allKeys containsObject:@"pAge"]) {
            [tempDic setObject:patient[@"pAge"] forKey:@"pAge"];
        }
        if ([patient.allKeys containsObject:@"pBedNum"]) {
            [tempDic setObject:patient[@"pBedNum"] forKey:@"pBedNum"];
        }
        if ([patient.allKeys containsObject:@"pCity"]) {
            [tempDic setObject:patient[@"pCity"] forKey:@"pCity"];
        }
        if ([patient.allKeys containsObject:@"pCountOfHospitalized"]) {
            [tempDic setObject:patient[@"pCountOfHospitalized"] forKey:@"pCountOfHospitalized"];
        }
        
        if ([patient.allKeys containsObject:@"pDept"]) {
            [tempDic setObject:patient[@"pDept"] forKey:@"pDept"];
        }
        if ([patient.allKeys containsObject:@"pDetailAddress"]) {
            [tempDic setObject:patient[@"pDetailAddress"] forKey:@"pDetailAddress"];
        }
        if ([patient.allKeys containsObject:@"pGender"]) {
            [tempDic setObject:patient[@"pGender"] forKey:@"pGender"];
        }
        if ([patient.allKeys containsObject:@"pID"]) {
            [tempDic setObject:patient[@"pID"] forKey:@"pID"];
        }
        
        if ([patient.allKeys containsObject:@"pLinkman"]) {
            [tempDic setObject:patient[@"pLinkman"] forKey:@"pLinkman"];
        }
        if ([patient.allKeys containsObject:@"pLinkmanMobileNum"]) {
            [tempDic setObject:patient[@"pLinkmanMobileNum"] forKey:@"pLinkmanMobileNum"];
        }
        if ([patient.allKeys containsObject:@"pMaritalStatus"]) {
            [tempDic setObject:patient[@"pMaritalStatus"] forKey:@"pMaritalStatus"];
        }
        
        if ([patient.allKeys containsObject:@"pMobileNum"]) {
            [tempDic setObject:patient[@"pMobileNum"] forKey:@"pMobileNum"];
        }
        if ([patient.allKeys containsObject:@"pName"]) {
            [tempDic setObject:patient[@"pName"] forKey:@"pName"];
        }
        if ([patient.allKeys containsObject:@"pNation"]) {
            [tempDic setObject:patient[@"pNation"] forKey:@"pNation"];
        }
        
        if ([patient.allKeys containsObject:@"pProfession"]) {
            [tempDic setObject:patient[@"pProfession"] forKey:@"pProfession"];
        }
        if ([patient.allKeys containsObject:@"pProvince"]) {
            [tempDic setObject:patient[@"pProvince"] forKey:@"pProvince"];
        }
        if ([patient.allKeys containsObject:@"patientState"]) {
            [tempDic setObject:patient[@"patientState"] forKey:@"patientState"];
        }
        
        if ([patient.allKeys containsObject:@"presenter"]) {
            [tempDic setObject:patient[@"presenter"] forKey:@"presenter"];
        }
        
    }
    
    return tempDic;
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
    WriteCaseSaveCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WriteCaseSaveCell"];
    cell.autoresizesSubviews = NO;
    [self configureCell:cell AtIndexPath:indexPath];
    
    return cell;
}
-(void)configureCell:(WriteCaseSaveCell*)cell AtIndexPath:(NSIndexPath*)indexPath
{
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    Node *tempNode = [self.fetchResultController objectAtIndexPath:indexPath];
    cell.textViewDelegate = self;
    UILabel *cellLabel = (UILabel*)[cell viewWithTag:1001];
    UITextView *textView = (UITextView*)[cell viewWithTag:1002];
    
    
    cellLabel.text = tempNode.nodeName;
    textView.text = ([tempNode.nodeContent isEqualToString:tempNode.nodeName]) ? @" ": tempNode.nodeContent;
    [textView layoutIfNeeded];
}
#pragma mask - WriteCaseSaveCell  delegate
-(void)textViewCell:(WriteCaseSaveCell *)cell didChangeText:(NSString *)text
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    Node *tempNode = [self.fetchResultController objectAtIndexPath:indexPath];
    tempNode.nodeContent = text;
    [self.coreDataStack saveContext];
}
-(void)textViewDidBeginEditing:(UITextView *)textView withCellIndexPath:(NSIndexPath *)indexPath
{
    //[self updateButtonState];
    self.isBeginEdit = NO;

    self.currentIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    self.currentTextView = textView;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    WriteCaseSaveCell *cell =(WriteCaseSaveCell*) [tableView cellForRowAtIndexPath:indexPath];
    UILabel *label =(UILabel*) [cell viewWithTag:1001];
    UITextView *textView = (UITextView*)[cell viewWithTag:1002];
    self.selectedStr = label.text;
    self.textViewContent = textView.text;
    self.currentIndexPath = indexPath;
    
    if ([label.text isEqualToString:@"主诉"]) {
        [self performSegueWithIdentifier:@"firstSegue" sender:nil];

    }else{
        [self performSegueWithIdentifier:@"EditCaseSegue" sender:nil];
    }
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
            
            if (self.isBeginEdit) {
                WriteCaseSaveCell *cell =(WriteCaseSaveCell*) [self.tableView cellForRowAtIndexPath:indexPath];
                [self configureCell:cell AtIndexPath:indexPath];
            }
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"EditCaseSegue"]) {
        self.isBeginEdit = YES;
        
        UINavigationController *nav = (UINavigationController*)segue.destinationViewController;
        
        WriteCaseEditViewController *writeVC = (WriteCaseEditViewController*)[nav.viewControllers firstObject];
        writeVC.labelString = self.selectedStr;
        writeVC.Editdelegate = self;
        writeVC.textViewContent = self.textViewContent;
        writeVC.tempPatient = self.tempPatient;
    
    }else if([segue.identifier isEqualToString:@"firstSegue"]){
        self.isBeginEdit = YES;

        UINavigationController *nav = (UINavigationController*)segue.destinationViewController;
        
        writeCaseFirstItemViewController *firstItem = (writeCaseFirstItemViewController*)[nav.viewControllers firstObject];
        firstItem.titleString = self.selectedStr;
        firstItem.delegate = self;
        firstItem.textViewContent = self.textViewContent;
    }
}
#pragma mask - write delegate
-(void)didWriteStringToMedicalRecord:(NSString *)writeString withKeyStr:(NSString *)keyStr
{
    
    Node *tempNode = [self.fetchResultController objectAtIndexPath:self.currentIndexPath];
    tempNode.nodeContent = writeString;
    [self.coreDataStack saveContext];
    
}
-(void)didWriteWithString:(NSString *)writeString
{
    
    Node *tempNode = [self.fetchResultController objectAtIndexPath:self.currentIndexPath];
    tempNode.nodeContent = writeString;
    [self.coreDataStack saveContext];


}

///helper method
#pragma mask - parase to json data
-(NSData*)convertToJSONDataFromList:(id)listData
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:listData options:NSJSONWritingPrettyPrinted error:&error];
    if ([jsonData length] > 0 && error == nil) {
        return jsonData;
    }else {
        return nil;
    }
}
-(NSString*)convertJSONDataToString:(NSData*)jsonData
{
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}
#pragma mask - parse to list
-(NSData*)convertStringToJSONData:(NSString*)jsonString
{
    return [jsonString dataUsingEncoding:NSUTF8StringEncoding];
}
-(id)convertJSONDataToList:(NSData*)jsonData
{
    NSError *error = nil;
    id list = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
    if (list != nil && error == nil) {
        return list;
    }else {
        NSLog(@"parse error");
    }
    return nil;
}


@end
