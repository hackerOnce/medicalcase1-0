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
#import "SelectCommitDoctorViewController.h"

@interface WriteCaseSaveViewController ()<NSFetchedResultsControllerDelegate,WriteCaseSaveCellDelegate,UITableViewDelegate,UITableViewDataSource,WriteCaseEditViewControllerDelegate,writeCaseFirstItemViewControllerDelegate,UIAlertViewDelegate,SelectCommitDoctorViewControllerDelegate>
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

//@property (nonatomic,strong) RecordBaseInfo *recordBaseInfo;
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

@property (nonatomic,strong) NSString *_DOF;
@property (nonatomic,strong) NSString *_created;
@property (nonatomic,strong) NSString *caseID;
@property (nonatomic,strong) NSString *_updated;


@property (nonatomic,strong) UIAlertView *saveAlertView;
@property (nonatomic,strong) UIAlertView *commitAlertView;
@property (nonatomic,strong) UIAlertView *cancelAlertView;
@property (nonatomic,strong) UIAlertView *updateAlertView;

@property (nonatomic) NSInteger resp;
@property (nonatomic) BOOL hasCompletedWriteRecord; //
@property (nonatomic) BOOL hasEditedRecord;
@end

@implementation WriteCaseSaveViewController
///test data
- (IBAction)cancelButtonClicked:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

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
- (IBAction)saveButton:(UIBarButtonItem *)sender {
    if ([sender.title isEqualToString:@"保存"]) {
        if (self.recordBaseInfo.caseID) {
            //update
            [self updateCase];
        }else {
            //save
            [self saveCaseToServer];
        }
    }else if([sender.title isEqualToString:@"提交"]){
        [self commitCaseToServerWithSender:sender];
    }else if([sender.title isEqualToString:@"撤回"]){
        [self cancelCommitCaseToServer];
    }
}
-(void)updateCase
{
    NSString *caseID = self.recordBaseInfo.caseID;
    if (caseID) {
        
    }else {
        abort();
    }
    NSMutableDictionary *caseContent = [[NSMutableDictionary alloc] init];
    
    ParentNode *parentNode = [self.coreDataStack fetchParentNodeWithNodeEntityName:@"入院记录"];
    for (int i=0; i< parentNode.nodes.count; i++) {
        Node *tempNode = parentNode.nodes[i];
        if ([tempNode.nodeContent isEqualToString:@""]) {
            self.hasCompletedWriteRecord = YES;
        }
        [caseContent setObject:tempNode.nodeContent forKey:tempNode.nodeEnglish];
        NSLog(@"nodeEnglish= %@,nodeContent= %@,nodeName=%@",tempNode.nodeEnglish,tempNode.nodeContent,tempNode.nodeName);
        
    }

    [MessageObject messageObjectWithUsrStr:@"2216" pwdStr:@"test" iHMsgSocket:self.socket optInt:1999 dictionary:@{@"content":caseContent,@"id":self.recordBaseInfo.caseID} block:^(IHSockRequest *request) {
        if (request.resp == 0) {
            self.resp = request.resp;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.updateAlertView = [[UIAlertView alloc] initWithTitle:@"保存成功" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                NSLog(@"update record case ok");
                [self.updateAlertView show];
            });
            
        }
    } failConection:^(NSError *error) {
        
    }];
}
-(void)cancelCommitCaseToServer
{
    NSString *doctorID = [[NSUserDefaults standardUserDefaults] objectForKey:@"dID"];
    NSString *caseID =[NSString stringWithFormat:@"%@",self.recordBaseInfo.caseID];
    
    [MessageObject messageObjectWithUsrStr:@"1" pwdStr:@"test" iHMsgSocket:self.socket optInt:2009 dictionary:@{@"id":caseID,@"did":doctorID} block:^(IHSockRequest *request) {
        NSInteger resp = request.resp;
        self.resp = resp;
        NSString *message;
        switch (resp) {
            case 0:{
                message = @"撤销成功";
                break;
            }
            case -1:{
                message = @"撤销失败，没有权限";
                break;
            }
            case -3:{
                message = @"提交失败，病历未提交";
                break;
            }
            default:
                break;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.cancelAlertView = [[UIAlertView alloc] initWithTitle:message message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [self.cancelAlertView show];
        });
       
        
    } failConection:^(NSError *error) {
        
    }];
}
-(void)commitCaseToServerWithSender:(UIBarButtonItem*)sender
{
    [self performSegueWithIdentifier:@"commitDoctor" sender:sender];
}
-(void)didSelectedDoctor:(TempDoctor *)doctor
{
    NSString *caseID = self.recordBaseInfo.caseID;
    NSString *doctorID = [[NSUserDefaults standardUserDefaults] objectForKey:@"dID"];
    NSString *sid = doctor.dID;
    
    [MessageObject messageObjectWithUsrStr:@"2216" pwdStr:@"test" iHMsgSocket:self.socket optInt:2008 dictionary:@{@"id":caseID,@"did":doctorID,@"sid":sid} block:^(IHSockRequest *request) {
        
        NSInteger resp = request.resp;
        self.resp = resp;
        NSString *message;
        switch (resp) {
            case 0:{
                message = @"提交成功";
                break;
            }
            case -1:{
                message = @"提交失败，病历不存在";
                break;
            }
            case -3:{
                message = @"提交失败，病历已提交";
                break;
            }
            default:
                break;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.commitAlertView = [[UIAlertView alloc] initWithTitle:message message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [self.commitAlertView show];
        });
        
        
    } failConection:^(NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"服务器端出错" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
        [alert show];
    }];
    
}
-(void)saveCaseToServer
{
    NSMutableDictionary *caseContent = [[NSMutableDictionary alloc] init];
    
    ParentNode *parentNode = [self.coreDataStack fetchParentNodeWithNodeEntityName:@"入院记录"];
    
    for (int i=0; i< parentNode.nodes.count; i++) {
        Node *tempNode = parentNode.nodes[i];
        if ([tempNode.nodeContent isEqualToString:@""]) {
                self.hasCompletedWriteRecord = YES;
        }
        [caseContent setObject:tempNode.nodeContent forKey:tempNode.nodeEnglish];
    }
    
    self.originDict = [[NSMutableDictionary alloc] init];
    Patient *patient = [self.coreDataStack patientFetchWithDict:[self caseKeyDic]];
    NSMutableDictionary *pDict = [[NSMutableDictionary alloc] init];
    [pDict setObject:[NSString stringWithFormat:@"%@",patient.pID] forKey:@"pID"];
    [pDict setObject:[NSString stringWithFormat:@"%@",patient.pName] forKey:@"pName"];
    [pDict setObject:[NSString stringWithFormat:@"%@",patient.pGender] forKey:@"pGender"];
    [pDict setObject:[NSString stringWithFormat:@"%@",patient.pAge] forKey:@"pAge"];
    
    [pDict setObject:[NSString stringWithFormat:@"%@",patient.pCity] forKey:@"pCity"];
    [pDict setObject:[NSString stringWithFormat:@"%@",patient.pProvince]forKey:@"pProvince"];
    [pDict setObject:[NSString stringWithFormat:@"%@",patient.pDetailAddress] forKey:@"pDetailAddress"];
    [pDict setObject:[NSString stringWithFormat:@"%@",patient.pDept] forKey:@"pDept"];
    
    [pDict setObject:[NSString stringWithFormat:@"%@",patient.pBedNum] forKey:@"pBedNum"];
    [pDict setObject:[NSString stringWithFormat:@"%@",patient.pNation]forKey:@"pNation"];
    [pDict setObject:[NSString stringWithFormat:@"%@",patient.pProfession] forKey:@"pProfession"];
    [pDict setObject:[NSString stringWithFormat:@"%@",patient.pMaritalStatus] forKey:@"pMaritalStatus"];
    
    [pDict setObject:[NSString stringWithFormat:@"%@",patient.pBedNum] forKey:@"pMobileNum"];
    [pDict setObject:[NSString stringWithFormat:@"%@",patient.pNation] forKey:@"pLinkman"];
    [pDict setObject:[NSString stringWithFormat:@"%@",patient.pProfession]forKey:@"pLinkmanMobileNum"];
    [pDict setObject:[NSString stringWithFormat:@"%@",patient.pMaritalStatus] forKey:@"pCountOfHospitalized"];
    
    [self.originDict setObject:pDict forKey:@"patient"];
    //alertView.title = @"保存成功";
    
    [self.originDict setObject:caseContent forKey:@"caseContent"];
    [self.originDict setObject:self.recordBaseInfo.caseType forKey:@"caseType"];
    
    NSMutableDictionary *resident = [[NSMutableDictionary alloc] init];
    [resident setObject:@"" forKey:@"dID"];
    [resident setObject:@"" forKey:@"dName"];
    [resident setObject:@"" forKey:@"dProfessionalTitle"];
    [resident setObject:@"" forKey:@"dept"];

    NSMutableDictionary *attendingPhysician = [[NSMutableDictionary alloc] init];
    [attendingPhysician setObject:@"" forKey:@"dID"];
    [attendingPhysician setObject:@"" forKey:@"dName"];
    [attendingPhysician setObject:@"" forKey:@"dProfessionalTitle"];
    [attendingPhysician setObject:@"" forKey:@"dept"];
    
    NSMutableDictionary *chiefPhysician = [[NSMutableDictionary alloc] init];
    [chiefPhysician setObject:@"" forKey:@"dID"];
    [chiefPhysician setObject:@"" forKey:@"dName"];
    [chiefPhysician setObject:@"" forKey:@"dProfessionalTitle"];
    [chiefPhysician setObject:@"" forKey:@"dept"];
    
    [self.originDict setObject:resident forKey:@"resident"];
    [self.originDict setObject:attendingPhysician forKey:@"attendingPhysician"];
    [self.originDict setObject:chiefPhysician forKey:@"chiefPhysician"];
    
    [MessageObject messageObjectWithUsrStr:@"2216" pwdStr:@"test" iHMsgSocket:self.socket optInt:20001 dictionary:self.originDict block:^(IHSockRequest *request) {
        
        self.resp = request.resp;
        self.saveAlertView = [[UIAlertView alloc] initWithTitle:@"保存成功" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        if ([request.responseData isKindOfClass:[NSArray class]] )
        {
            NSArray *tempArray = (NSArray*)request.responseData;
            NSDictionary *tempDict =(NSDictionary*)[tempArray firstObject];
            if ([tempDict.allKeys containsObject:@"_DOF"]) {
                self._DOF = tempDict[@"_DOF"];
            }
            if ([tempDict.allKeys containsObject:@"_created"]) {
                self._created = tempDict[@"_created"];
            }
            if ([tempDict.allKeys containsObject:@"_id"]) {
                self.caseID = tempDict[@"_id"];
            }
            if ([tempDict.allKeys containsObject:@"_updated"]) {
                self._updated = tempDict[@"_updated"];
            }
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.saveAlertView show];

        });
        
    } failConection:^(NSError *error) {
        // [self.coreDataStack saveContext];
    }];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == self.saveAlertView) {
        [self.originDict setObject:[NSString stringWithFormat:@"%@",self._DOF] forKey:@"_DOF"];
        [self.originDict setObject:[NSString stringWithFormat:@"%@", self._created] forKey:@"_created"];
        [self.originDict setObject:[NSString stringWithFormat:@"%@", self.caseID] forKey:@"_id"];
        [self.originDict setObject:[NSString stringWithFormat:@"%@", self._updated] forKey:@"_updated"];
        
        [self.coreDataStack recordUpdatedWithDict:[self parseCaseInfoWithDic:self.originDict]];
        
        if (self.resp == 0 && !self.hasCompletedWriteRecord) {
           [self.saveButton setTitle:@"提交"];
        }
    }
    if (alertView == self.updateAlertView) {
        if (self.resp == 0 && !self.hasCompletedWriteRecord) {
            [self.saveButton setTitle:@"提交"];
        }
    }
    if (alertView == self.commitAlertView) {
        if (self.resp == 0) {
            [self.saveButton setTitle:@"撤回"];
        }
    }
    if (alertView == self.cancelAlertView) {
        if (self.resp == 0) {
            [self.saveButton setTitle:@"保存"];
        }
    }
}
-(NSArray *)caseInfoArray
{
    return @[@"chiefComplaint",@"historyOfPresentillness",@"personHistory",@"pastHistory",@"familyHistory",@"obstericalHistory",@"physicalExamination",@"systemsReview",@"specializedExamination",@"tentativeDiagnosis",@"admittingDiagnosis",@"confirmedDiagnosis",];
}
-(NSString*)transformCaseStatus:(NSString*)caseStatusString
{
    NSDictionary *tempDict= @{@"保存未提交":@"0",@"提交未审核":@"1",@"主治医师审核":@"2",@"（副）主任医师审核":@"3",@"主治医师审核未通过":@"4",@"副主任医师审核通过":@"5",@"副主任医师审核未通过":@"6",@"归档":@"7",@"撤回":@"8"};
    if ([tempDict.allKeys containsObject:caseStatusString]) {
        return tempDict[caseStatusString];
    }else {
        return @"0";
    }
}
-(void)setRecordBaseInfo:(RecordBaseInfo *)recordBaseInfo
{
    _recordBaseInfo = recordBaseInfo;
    
    NSString *caseStatusInt = [self transformCaseStatus:_recordBaseInfo.caseStatus];
    
    switch ([caseStatusInt integerValue]) {
        case 0:{
            [self.saveButton setTitle:@"保存"];
            break;
        }
        case 1:{
            [self.saveButton setTitle:@"撤回"];
            break;
        }
        case 2:{
            [self.saveButton setTitle:@"主治医师审核中"];
            break;
        }
        case 3:{
            [self.saveButton setTitle:@"主治医师审核通过"];
            break;
        }
        case 4:{
            [self.saveButton setTitle:@"主治医师审核未通过"];
            break;
        }
        case 5:{
            [self.saveButton setTitle:@"主任医师审核通过"];
            break;
        }
        case 6:{
            [self.saveButton setTitle:@"主任医师审核未通过"];
            break;
        }
        case 7:{
            [self.saveButton setTitle:@"归档"];
            break;
        }
        default:
            break;
    }
   
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
    
  //  [self caseRecordFromServerOrLocal];
    
    if (self.isRemoveLeftButton) {
        self.navigationItem.leftBarButtonItem = nil;
    }else {
        self.remainTimeLabel.text =[NSString stringWithFormat:@"剩余时间:08:00:00"];
    }
    
    self.hasCompletedWriteRecord = NO;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    
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
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"dID"]   forKey:@"dID"];
    [dict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"pID"]   forKey:@"pID"];
    
    [dict setObject:self.recordBaseInfo.caseType forKey:@"caseType"];
    return dict;
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
    if ([dataDic.allKeys containsObject:@"caseType"]) {
        [tempDic setObject:dataDic[@"caseType"] forKey:@"caseType"];
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
    if([segue.identifier isEqualToString:@"commitDoctor"]){
        UINavigationController *nav = (UINavigationController*)segue.destinationViewController;
        SelectCommitDoctorViewController *commitVC = (SelectCommitDoctorViewController*)[nav.viewControllers firstObject];
        commitVC.delegate = self;
        
    }
    
}
-(void)setHasEditedRecord:(BOOL)hasEditedRecord
{
    _hasEditedRecord  = hasEditedRecord;
    
    if (_hasEditedRecord) {
        if ([self.saveButton.title isEqualToString:@"提交"]) {
            [self.saveButton setTitle:@"保存"];
        }
    }
}
#pragma mask - write delegate
-(void)didWriteStringToMedicalRecord:(NSString *)writeString withKeyStr:(NSString *)keyStr
{
    
    Node *tempNode = [self.fetchResultController objectAtIndexPath:self.currentIndexPath];
    
    if ([tempNode.nodeContent isEqualToString:writeString]) {
        
    }else {
        self.hasEditedRecord = YES;
    }
    tempNode.nodeContent = writeString;
    [self.coreDataStack saveContext];
    
}
-(void)didWriteWithString:(NSString *)writeString
{
    Node *tempNode = [self.fetchResultController objectAtIndexPath:self.currentIndexPath];
    
    if ([tempNode.nodeContent isEqualToString:writeString]) {
        
    }else {
        self.hasEditedRecord = YES;
    }
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
