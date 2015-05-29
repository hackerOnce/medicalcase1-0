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
#import "SelectCommitDoctorViewController.h"

@interface AuditCaseViewController ()<UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate,AuditCaseCellDelegate,UIAlertViewDelegate,SelectCommitDoctorViewControllerDelegate>
@property (nonatomic,strong) CoreDataStack *coreDataStack;

@property (nonatomic,strong) NSMutableDictionary *viewDict;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *auditButton;


@property (nonatomic,strong) NSFetchedResultsController *fetchResultController;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *commitButton;
@property (nonatomic,strong) IHMsgSocket *socket;
@property (nonatomic) BOOL isResidentNote; //是入院记录

@property (nonatomic,strong) NSMutableArray *auditCaseArray;

@property (nonatomic) NSInteger resp;
@property (nonatomic) NSInteger selectedSection;
@end

@implementation AuditCaseViewController
-(IHMsgSocket *)socket
{
    if (!_socket) {
        _socket = [IHMsgSocket sharedRequest];
        if (![[_socket IHGCDSocket].asyncSocket isConnected]) {
            [_socket connectToHost:@"192.168.10.106" onPort:2323];
        }
    }
    return _socket;
}
-(void)setAuditCaseArray:(NSMutableArray *)auditCaseArray
{
    _auditCaseArray = auditCaseArray;
    
    
}
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
-(void)setTempCaseInfo:(TempCaseBaseInfo *)tempCaseInfo
{
    _tempCaseInfo = tempCaseInfo;
    
    TempDoctor *doctor = [TempDoctor setSharedDoctorWithDict:nil];
    self.auditCaseArray = [[NSMutableArray alloc] init];
    [MessageObject messageObjectWithUsrStr:doctor.dID pwdStr:@"test" iHMsgSocket:self.socket optInt:1503 dictionary:@{@"did":doctor.dID,@"pid":tempCaseInfo.pID} block:^(IHSockRequest *request) {
        
        if (request.resp == 0) {
            if ([request.responseData isKindOfClass:[NSArray class]]) {
                NSArray *tempArray = (NSArray*)request.responseData;
                
                for (NSDictionary *recordDict in tempArray) {
                    NSDictionary *dict = [self parseCaseInfoWithDic:recordDict];
                    NSArray *recordCases = [self.coreDataStack fetchRecordWithDict:dict isReturnNil:NO];
                    RecordBaseInfo *recordBaseInfo = [recordCases firstObject];
                    [self.auditCaseArray addObject:recordBaseInfo];
                }
                
                for (RecordBaseInfo *recordBaseInfo in self.auditCaseArray) {
                    if ([recordBaseInfo.caseType isEqualToString:@"入院记录"]) {
                        self.recordBaseInfo = recordBaseInfo;
                        break;
                    }
                }
            }
        }
    } failConection:^(NSError *error) {
        
    }];
}
#pragma mask - load record from server
-(void)loadRecordFromServerWithDict:(NSDictionary*)dict
{
    
}
#pragma mask - set record base info
-(void)setRecordBaseInfo:(RecordBaseInfo *)recordBaseInfo
{
    _recordBaseInfo = recordBaseInfo;
    
    if ([_recordBaseInfo.caseType isEqualToString:@"入院记录"]) {
        [self saveResidentRecordCaseContentToCoreData:_recordBaseInfo withSection:0];
        self.isResidentNote = YES;
    }
}
-(void)saveResidentRecordCaseContentToCoreData:(RecordBaseInfo*)recordBaseInfo withSection:(NSUInteger)section
{
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
   
    [self setUpFetchViewControllerWithSection:section];
}
-(void)setUpFetchViewControllerWithSection:(NSUInteger)section
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

#pragma mask - view vontroller life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpTableView];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    TempDoctor *doctor = [TempDoctor setSharedDoctorWithDict:nil];
    
    if ([doctor.dProfessionalTitle containsString:@"主治"]) {
        [self.auditButton setTitle:@"提交"];
    }else {
        [self.auditButton setTitle:@"审核"];
    }
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.delegate didExitAuditCaseViewController];
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
    
    
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    for (RecordBaseInfo *recordCase in self.auditCaseArray) {
        if ([recordCase.caseType isEqualToString:@"入院记录"]) {
            NSMutableDictionary *dict =[NSMutableDictionary dictionaryWithDictionary:[self auditNSDictionarForServer:YES isForReturn:NO]];
            [tempArray addObject:dict];
 
        }
    }
    
    if ([sender.title  isEqualToString:@"提交"]) {
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"WriteCaseStoryboard" bundle:nil];
        SelectCommitDoctorViewController *commitDoctorVC = [storyBoard instantiateViewControllerWithIdentifier:@"selecteCommitDoctor"];
        commitDoctorVC.delegate = self;
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:commitDoctorVC];
        [popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
    }else if([sender.title  isEqualToString:@"审核"]) {
        [MessageObject messageObjectWithUsrStr:[TempDoctor setSharedDoctorWithDict:nil].dID pwdStr:@"test" iHMsgSocket:self.socket optInt:1507 dictionary:@{@"key":tempArray} block:^(IHSockRequest *request){
            
            if (request.resp == 0) {
                
                [self dismissViewControllerAnimated:YES completion:nil];
                
            }else {
            }
            
        } failConection:^(NSError *error) {
            [self connectServerFailWithMessage:@"提交审核失败，服务器断开连接"];
        }];
    }
    
}
#pragma mask -select a doctor to commit
-(void)didSelectedDoctor:(TempDoctor *)doctor
{
    //住院医师提交多个病历到主任医师
    
    
}
#pragma mask - alert view delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.resp == 0) {
        
        [self.auditCaseArray removeObjectAtIndex:self.selectedSection];
        
        if (self.auditCaseArray.count == 0) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }else {
            [self.tableView reloadData];
        }
    }
}
-(void)headerViewButtonTapped:(UIButton*)sender
{
    //撤销
    UIView *headerView = sender.superview;
    
    RecordBaseInfo *recordBaseInfo = [self.auditCaseArray objectAtIndex:headerView.tag-1];
    self.selectedSection = headerView.tag - 1;

    NSDictionary *dict;
    if([recordBaseInfo.caseType isEqualToString:@"入院记录"]){
        dict =[NSMutableDictionary dictionaryWithDictionary:[self auditNSDictionarForServer:YES isForReturn:YES]];

    }
    [MessageObject messageObjectWithUsrStr:[TempDoctor setSharedDoctorWithDict:nil].dID pwdStr:@"test" iHMsgSocket:self.socket optInt:1504 dictionary:dict block:^(IHSockRequest *request){
        
        NSString *message;
            if (request.resp == 0) {
                 self.resp = 0;
                 message = @"退回成功";
            }else {
                 message = @"退回失败，服务器返回错误";
            }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:message message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        } failConection:^(NSError *error) {
            [self connectServerFailWithMessage:@"退回失败，服务器断开连接"];
        }];
}
-(void)connectServerFailWithMessage:(NSString *)message
{
   static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:message?message:@"服务器连接失败" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            
        });
    });
    
}
-(NSDictionary*)auditNSDictionarForServer:(BOOL)isForServer isForReturn:(BOOL)isForReturn
{
    NSString *caseID = StringValue(self.recordBaseInfo.caseID);
    NSString *doctorID =StringValue([TempDoctor setSharedDoctorWithDict:nil].dID);
    NSMutableDictionary *caseContentDict = [[NSMutableDictionary alloc] init];
    ParentNode *parentNode = [self.coreDataStack fetchParentNodeWithNodeEntityName:@"入院记录"];
    for (int i=0; i< parentNode.nodes.count; i++) {
        Node *tempNode = parentNode.nodes[i];
        if (!tempNode.nodeContent) {
            tempNode.nodeContent = @"";
        }
        [caseContentDict setObject:tempNode.nodeContent forKey:tempNode.nodeEnglish];
        NSLog(@"nodeEnglish= %@,nodeContent= %@,nodeName=%@",tempNode.nodeEnglish,tempNode.nodeContent,tempNode.nodeName);
    }
    NSMutableDictionary *dict;
    if (isForServer) {
        dict =[NSMutableDictionary dictionaryWithDictionary:@{@"id":caseID,@"did":doctorID,@"content":caseContentDict,@"style":isForReturn?@(1):@(0)}];
    }else {
        dict = [NSMutableDictionary dictionaryWithDictionary:caseContentDict];
    }
    return dict;
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
    return self.auditCaseArray.count;
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
    
    headerView.tag = section+1;
    RecordBaseInfo *recordBaseInfo = [self.auditCaseArray objectAtIndex:section];
    
        headerView.backgroundColor = [UIColor whiteColor];
        
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 8, 200, 33)];
        headerLabel.tag = 101;
        headerLabel.text = recordBaseInfo.caseType;
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
        [headerButton setTitleColor:[UIColor colorWithRed:234/255.0 green:238/255.0 blue:242/255.0 alpha:1] forState:UIControlStateHighlighted];
    
        [headerView addSubview:headerButton];
        headerButton.backgroundColor = [UIColor whiteColor];
        [headerButton addTarget:self action:@selector(headerViewButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
       UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, CGRectGetWidth(tableView.frame), 1)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [headerView addSubview:lineView];
    
        [self.viewDict setObject:headerView forKey:@"headerView"];
        return headerView;
    
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

#pragma mask -helper
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
    if ([dataDic.allKeys containsObject:@"caseStatus"]) {
        
        NSString *caseStatus = [self transformCaseStatus:[NSString stringWithFormat:@"%@",dataDic[@"caseStatus"]]];
        
        [tempDic setObject:caseStatus forKey:@"caseStatus"];
    }
    if ([dataDic.allKeys containsObject:@"caseType"]) {
        [tempDic setObject:dataDic[@"caseType"] forKey:@"caseType"];
    }
    
    if ([dataDic.allKeys containsObject:@"caseBaseInfo"]) {
        
        NSDictionary *dic = dataDic[@"caseBaseInfo"];
        
        if ([dic.allKeys containsObject:@"casePresenter"]) {
            [tempDic setObject:dic[@"casePresenter"]forKey:@"casePresenter"];
        }
        if ([dic.allKeys containsObject:@"caseEditStatus"]) {
            [tempDic setObject:dic[@"caseEditStatus"]forKey:@"caseEditStatus"];
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
    
    
    if ([dataDic.allKeys containsObject:@"resident"]) {
        NSDictionary *doctor = dataDic[@"resident"];
        if ([doctor.allKeys containsObject:@"dID"]) {
            [tempDic setObject:doctor[@"dID"] forKey:@"residentdID"];
        }
        if ([doctor.allKeys containsObject:@"dName"]) {
            [tempDic setObject:doctor[@"dName"] forKey:@"residentdName"];
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
-(NSString*)transformCaseStatus:(NSString*)caseStatusInt
{
    NSDictionary *tempDict= @{@"0":@"保存未提交",@"1":@"住院医师提交（审核）",@"2":@"主治医师提交（审核）",@"3":@"主任医师审核（提交）通过",@"4":@"归档"};
    if ([tempDict.allKeys containsObject:caseStatusInt]) {
        return tempDict[caseStatusInt];
    }else {
        return @"未创建";
    }
}

@end
