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
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

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
@property (nonatomic,strong) NSString *textViewContent;

@property (nonatomic,strong) IHMsgSocket *socket;

@property (nonatomic) BOOL doctorCreatedSucess;
@property (nonatomic) BOOL patientCreateSucess;

@property (nonatomic,strong) NSArray *caseInfoArray;

@property (nonatomic,strong) NSMutableDictionary *caseInfoDict;

@property (nonatomic,strong) RecordBaseInfo *resultCaseInfo;
@property (weak, nonatomic) IBOutlet UIButton *retreatButton;

@property (nonatomic,strong) NSMutableDictionary *originDict;
@property (weak, nonatomic) IBOutlet personInfoView *personInfoView;

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

@property (nonatomic,strong) NSMutableDictionary *coreDataDict;
//@property (nonatomic,strong) NSMutableDictionary *caseContentDict;
@property (nonatomic) BOOL isSaveSucess;
@end

@implementation WriteCaseSaveViewController
///test data
- (IBAction)cancelButtonClicked:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self.delegate didExitEditRecordCaseWithCurrentPatient:self.tempPatient];
}

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

-(NSString *)caseType
{
    if (!_caseType) {
        _caseType = @"入院病历";
    }
    return _caseType;
}
-(void)setIsHideRetreatButton:(BOOL)isHideRetreatButton
{
    _isHideRetreatButton = isHideRetreatButton;
    
    self.retreatButton.hidden = _isHideRetreatButton;
    self.retreatButton.enabled = !_isHideRetreatButton;

}
- (void)setCaseID:(NSString *)caseID
{
    if (![caseID isEqualToString:_caseID]) {
        _caseID = caseID;
        self.recordBaseInfo.caseID = caseID;
        [self.coreDataStack saveContext];
    }
}
- (IBAction)saveButton:(UIButton *)sender {
    if ([sender.titleLabel.text isEqualToString:@"保存"]) {
        if (self.recordBaseInfo.caseID && ![self.recordBaseInfo.caseID isEqualToString:@""]) {
            //update
            [self updateCase];
        }else {
            //save
            [self saveCaseToServer];
        }
    }else if([sender.titleLabel.text isEqualToString:@"提交"]){
        [self commitCaseToServerWithSender:sender];
    }else if([sender.titleLabel.text isEqualToString:@"撤回"]){
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
    
    self.hasCompletedWriteRecord = NO;

    
    ParentNode *parentNode = [self.coreDataStack fetchParentNodeWithNodeEntityName:@"入院记录"];
    for (int i=0; i< parentNode.nodes.count; i++) {
        Node *tempNode = parentNode.nodes[i];
        if (!tempNode.nodeContent) {
            tempNode.nodeContent = @"";
        }
        if ([tempNode.nodeContent isEqualToString:@""]) {
            self.hasCompletedWriteRecord = YES;
        }
        [caseContent setObject:tempNode.nodeContent forKey:tempNode.nodeEnglish];
        NSLog(@"nodeEnglish= %@,nodeContent= %@,nodeName=%@",tempNode.nodeEnglish,tempNode.nodeContent,tempNode.nodeName);
        
    }
    self.coreDataDict = [[NSMutableDictionary alloc] initWithDictionary:caseContent];
    
    
    //保存到服务器
    [MessageObject messageObjectWithUsrStr:[TempDoctor setSharedDoctorWithDict:nil].dID pwdStr:@"test" iHMsgSocket:self.socket optInt:1999 dictionary:@{@"content":caseContent,@"id":self.recordBaseInfo.caseID} block:^(IHSockRequest *request) {
        if (request.resp == 0) {
            self.resp = request.resp;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.updateAlertView = [[UIAlertView alloc] initWithTitle:@"保存成功" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                NSLog(@"update record case ok");
                [self.updateAlertView show];
            });
            
        }
    } failConection:^(NSError *error) {
        [self connectServerFailWithMessage:@"1999,更新病历到服务器时，服务器断开连接" failType:2];
    }];
}
///fail type :保存 1，更新 2，提交 3，撤回 4
-(void)connectServerFailWithMessage:(NSString*)failMessage failType:(NSInteger)failType
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.updateAlertView = [[UIAlertView alloc] initWithTitle:failMessage?failMessage:@"服务器断开连接" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [self.updateAlertView show];
        
        //保存到本地
        switch (failType) {
            case 1:{
                [self.coreDataStack updateCaseContent:self.recordBaseInfo.caseContent dataWithDict:self.coreDataDict];
                break;
            }
            case 2:{
                [self.coreDataStack updateCaseContent:self.recordBaseInfo.caseContent dataWithDict:self.coreDataDict];
                break;
            }
            case 3:{
                
                break;
            }
            case 4:{
                
                break;
            }
            default:
                break;
        }
        
        [self.coreDataStack saveContext];

    });

}
-(void)cancelCommitCaseToServer
{
    NSString *doctorID = [[NSUserDefaults standardUserDefaults] objectForKey:@"dID"];
    NSString *caseID =[NSString stringWithFormat:@"%@",self.recordBaseInfo.caseID];
    
    [MessageObject messageObjectWithUsrStr:@"1" pwdStr:@"test" iHMsgSocket:self.socket optInt:2009 dictionary:@{@"id":caseID,@"did":doctorID} block:^(IHSockRequest *request) {
        NSInteger resp = request.resp;
        self.resp = resp;
        NSString *message;
        NSString *caseStatus;

        switch (resp) {
            case 0:{
                message = @"撤销成功";
                caseStatus = @"保存未提交";
                break;
            }
            case -1:{
                message = @"撤销失败，没有权限";
                break;
            }
            case -2:{
                message = @"撤销失败，病历未提交";
                break;
            }

            case -3:{
                message = @"提交失败，病历已在审核中";
                break;
            }
            default:
                break;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.cancelAlertView = [[UIAlertView alloc] initWithTitle:message message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [self.cancelAlertView show];
            
            if (caseStatus) {
                self.recordBaseInfo.caseStatus = caseStatus;
            }
        });
       
        
    } failConection:^(NSError *error) {
        [self connectServerFailWithMessage:@"2009,撤销提交病历时，服务器断开连接" failType:4];
    }];
}
-(void)commitCaseToServerWithSender:(UIButton*)sender
{
    [self performSegueWithIdentifier:@"commitDoctor" sender:sender];
}
-(void)didSelectedDoctor:(TempDoctor *)doctor
{
    //2138
    NSString *caseID = self.recordBaseInfo.caseID;
    NSString *doctorID = [[NSUserDefaults standardUserDefaults] objectForKey:@"dID"];
    NSString *sid = doctor.dID;
    
    [MessageObject messageObjectWithUsrStr:sid pwdStr:@"test" iHMsgSocket:self.socket optInt:2008 dictionary:@{@"id":caseID,@"did":doctorID,@"sid":sid} block:^(IHSockRequest *request) {
        
        NSString *caseStatus;
        NSInteger resp = request.resp;
        self.resp = resp;
        NSString *message;
        switch (resp) {
            case 0:{
                message = @"提交成功";
                caseStatus = @"已提交未审核";
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
            case 3:{
                message = @"提供的上级医师不存在";
                break;
            }
            default:
                break;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.commitAlertView = [[UIAlertView alloc] initWithTitle:message message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [self.commitAlertView show];
            
            if (caseStatus) {
                self.recordBaseInfo.caseStatus = caseStatus;
                [self.coreDataStack saveContext];
            }
        });
        
        
    } failConection:^(NSError *error) {
        [self connectServerFailWithMessage:@"2008,提交病历到服务器时，服务器端出错" failType:3];
    }];
    
}
-(void)saveCaseToServer
{
    NSMutableDictionary *caseContent = [[NSMutableDictionary alloc] init];
    
    self.hasCompletedWriteRecord = NO;
    
    ParentNode *parentNode = [self.coreDataStack fetchParentNodeWithNodeEntityName:@"入院记录"];
    
    for (int i=0; i< parentNode.nodes.count; i++) {
        Node *tempNode = parentNode.nodes[i];
        if (!tempNode.nodeContent) {
            tempNode.nodeContent = @"";
        }
        if ([tempNode.nodeContent isEqualToString:@""]) {
            self.hasCompletedWriteRecord = YES;
        }
        [caseContent setObject:tempNode.nodeContent forKey:tempNode.nodeEnglish];
        NSLog(@"nodeEnglish= %@,nodeContent= %@,nodeName=%@",tempNode.nodeEnglish,tempNode.nodeContent,tempNode.nodeName);
        
    }
    self.coreDataDict = [[NSMutableDictionary alloc] initWithDictionary:caseContent];
    
    self.originDict = [[NSMutableDictionary alloc] init];
    Patient *patient = self.recordBaseInfo.patient;
    
    NSMutableDictionary *pDict = [[NSMutableDictionary alloc] init];
    [pDict setObject:StringValue(patient.pID) forKey:@"pID"];
    [pDict setObject:StringValue(patient.pName) forKey:@"pName"];
    [pDict setObject:StringValue(patient.pGender) forKey:@"pGender"];
    [pDict setObject:StringValue(patient.pAge) forKey:@"pAge"];
    
    [pDict setObject:StringValue(patient.pCity) forKey:@"pCity"];
    [pDict setObject:StringValue(patient.pProvince)forKey:@"pProvince"];
    [pDict setObject:StringValue(patient.pDetailAddress) forKey:@"pDetailAddress"];
    [pDict setObject:StringValue(patient.pDept) forKey:@"pDept"];
    
    [pDict setObject:StringValue(patient.pBedNum) forKey:@"pBedNum"];
    [pDict setObject:StringValue(patient.pNation)forKey:@"pNation"];
    [pDict setObject:StringValue(patient.pProfession) forKey:@"pProfession"];
    [pDict setObject:StringValue(patient.pMaritalStatus) forKey:@"pMaritalStatus"];
    
    [pDict setObject:StringValue(patient.pBedNum) forKey:@"pMobileNum"];
    [pDict setObject:StringValue(patient.pNation) forKey:@"pLinkman"];
    [pDict setObject:StringValue(patient.pProfession)forKey:@"pLinkmanMobileNum"];
    [pDict setObject:StringValue(patient.pMaritalStatus) forKey:@"pCountOfHospitalized"];
    
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

     //保存在服务器
    [MessageObject messageObjectWithUsrStr:[TempDoctor setSharedDoctorWithDict:nil].dID pwdStr:@"test" iHMsgSocket:self.socket optInt:20001 dictionary:self.originDict block:^(IHSockRequest *request) {
        
        self.resp = request.resp;
        self.saveAlertView = [[UIAlertView alloc] initWithTitle:@"保存成功" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        NSString *archivedTime;
        NSString *createdTime;
        NSString *caseID;
        NSString *updatedTime;

        if ([request.responseData isKindOfClass:[NSArray class]] )
        {
            NSArray *tempArray = (NSArray*)request.responseData;
            NSDictionary *tempDict =(NSDictionary*)[tempArray firstObject];
            
            
            if ([tempDict.allKeys containsObject:@"_DOF"]) {
                self._DOF =StringValue(tempDict[@"_DOF"]);
                archivedTime = self._DOF;
            }
            if ([tempDict.allKeys containsObject:@"_created"]) {
                self._created = StringValue(tempDict[@"_created"]);
               
                createdTime = self._created;
            }
            if ([tempDict.allKeys containsObject:@"_id"]) {
                self.caseID = StringValue(tempDict[@"_id"]);
                
                caseID = self.caseID;
            }
            if ([tempDict.allKeys containsObject:@"_updated"]) {
                self._updated = StringValue(tempDict[@"_updated"]);
               
                updatedTime = self._updated;
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.saveAlertView show];
            
            [self.coreDataStack updateCaseContent:self.recordBaseInfo.caseContent dataWithDict:self.caseInfoDict];
            
            self.recordBaseInfo.dof = archivedTime;
            self.recordBaseInfo.caseID = caseID;
            self.recordBaseInfo.createdDate = createdTime;
            self.recordBaseInfo.updatedDate = updatedTime;
            
            [self.coreDataStack saveContext];
        });
        
    } failConection:^(NSError *error) {
        [self connectServerFailWithMessage:@"20001,保存病历到服务器时服务器出错" failType:1];
    }];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == self.saveAlertView) {
        
        if (self.resp == 0 && !self.hasCompletedWriteRecord) {
            self.resp = -6;
           [self.saveButton setTitle:@"提交" forState:UIControlStateNormal ];
        }
    }
    if (alertView == self.updateAlertView) {
        if (self.resp == 0 && !self.hasCompletedWriteRecord) {
            self.resp = -6;

            [self.saveButton setTitle:@"提交" forState:UIControlStateNormal ];
        }
    }
    if (alertView == self.commitAlertView) {
        if (self.resp == 0) {
            self.resp = -6;

            [self.saveButton setTitle:@"撤回" forState:UIControlStateNormal ];
        }
    }
    if (alertView == self.cancelAlertView) {
        if (self.resp == 0) {
            self.resp = -6;

            [self.saveButton setTitle:@"保存" forState:UIControlStateNormal ];
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
            [self.saveButton setTitle:@"保存" forState:UIControlStateNormal ];
            break;
        }
        case 1:{
            [self.saveButton setTitle:@"撤回" forState:UIControlStateNormal ];
            break;
        }
        case 2:{
            [self.saveButton setTitle:@"主治医师审核中" forState:UIControlStateNormal ];

            break;
        }
        case 3:{
            [self.saveButton setTitle:@"主治医师审核通过" forState:UIControlStateNormal ];
            break;
        }
        case 4:{
            [self.saveButton setTitle:@"主治医师审核未通过" forState:UIControlStateNormal ];
            break;
        }
        case 5:{
            [self.saveButton setTitle:@"主任医师审核通过" forState:UIControlStateNormal ];
            break;
        }
        case 6:{
            [self.saveButton setTitle:@"主任医师审核未通过" forState:UIControlStateNormal ];
            break;
        }
        case 7:{
            [self.saveButton setTitle:@"归档" forState:UIControlStateNormal ];
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
    
    if (self.isRemoveLeftButton) {
        self.navigationItem.leftBarButtonItem = nil;
    }else {
      //self.remainTimeLabel.text =[NSString stringWithFormat:@"剩余时间:08:00:00"];
    }
    
    self.hasCompletedWriteRecord = NO;
    
    self.personInfoView.patient = self.recordBaseInfo.patient;
    self.resp = -6; //初始化resp
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

    if ([self.saveButton.titleLabel.text isEqualToString:@"保存"]) {
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
    }else {
        NSString *message;
        
        if ([self.saveButton.titleLabel.text isEqualToString:@"撤回"]) {
            message = @"不能编辑病历，请先撤回";
        }else {
            message = @"病历正在审核中，不能编辑";
        }
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:message message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
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
        writeVC.recordBaseInfo = self.recordBaseInfo;

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
        if ([self.saveButton.titleLabel.text isEqualToString:@"提交"]) {
            
            [self.saveButton setTitle:@"保存" forState:UIControlStateNormal];
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
