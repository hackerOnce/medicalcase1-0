//
//  RecordManagedViewController.m
//  MedicalCase
//
//  Created by ihefe-JF on 15/4/23.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import "RecordManagedViewController.h"
#import "HeadView.h"
#import "RecordManagedCellTableViewCell.h"
//#import "WriteMedicalRecordVCViewController.h"
#import "Patient.h"
#import "Doctor.h"
#import "RecordNavagationViewController.h"
//#import "AdmissionRecordsViewController.h"
#import "TempRecord.h"
#import "WriteCaseSaveViewController.h"


@interface RecordManagedViewController ()<UITableViewDataSource,UITableViewDelegate,HeadViewDelegate,RecordManagedCellTableViewCellDelegate,RecordNavagationViewControllerDelegate>

@property (nonatomic,strong) NSMutableArray *classficationArray;
@property (nonatomic,strong) NSMutableDictionary *dataDic;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) CoreDataStack *coreDataStack;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic,strong) NSArray *recordCases;

@property (nonatomic,strong) NSMutableArray *arry1;
@property (nonatomic,strong) NSMutableArray *arry2;
@property (nonatomic,strong) NSMutableArray *arry3;
@property (nonatomic,strong) NSMutableArray *arry4;
@property (nonatomic,strong) NSMutableArray *arry5;
@property (nonatomic,strong) NSMutableArray *arry6;

@property (nonatomic,strong) NSMutableArray *sumArray;

@property (nonatomic,strong) RecordBaseInfo *recordBaseInfo;

@property (nonatomic,strong) IHMsgSocket *socket;

@property (nonatomic,strong) RecordBaseInfo *resultCaseInfo;

@property (nonatomic,strong) NSMutableArray *recordCaseArray;


@property (nonatomic,strong) TempPatient *patient;
@end

@implementation RecordManagedViewController
- (IBAction)cancel:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
-(IHMsgSocket *)socket
{
    if (!_socket) {
        _socket = [IHMsgSocket sharedRequest];
        [_socket connectToHost:@"192.168.10.106" onPort:2323];
    }
    return _socket;
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

#pragma  mask - property
-(NSMutableArray *)classficationArray
{
    if (!_classficationArray) {
        _classficationArray = [[NSMutableArray alloc] init];
        [_classficationArray addObject:@"未创建"];
        [_classficationArray addObject:@"保存未提交"]; //0
        [_classficationArray addObject:@"提交未审核"];
        [_classficationArray addObject:@"主治医师审核"];
        [_classficationArray addObject:@"（副）主任医师审核"];
        [_classficationArray addObject:@"主治医师审核未通过"];
        [_classficationArray addObject:@"副主任医师审核通过"];
        [_classficationArray addObject:@"副主任医师审核未通过"];
        [_classficationArray addObject:@"归档"];
        [_classficationArray addObject:@"撤回"];
    }
    return _classficationArray;
}
-(NSMutableDictionary *)dataDic
{
    if (!_dataDic) {
        _dataDic = [[NSMutableDictionary alloc] init];
        
        for (NSString *key in self.classficationArray) {
            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
            [_dataDic setObject:tempArray forKey:key];
        }
    }
    return _dataDic;
}
//-(void)setRecordCaseArray:(NSMutableArray *)recordCaseArray
//{
//    _recordCaseArray = recordCaseArray;
//    
//    for (int i=0; i < self.classficationArray.count; i++) {
//        NSString *key = self.classficationArray[i];
//        RecordBaseInfo *recordCaseInfo = [_recordCaseArray objectAtIndex:i];
//        if ([recordCaseInfo.caseStatus isEqualToString:key]) {
//            [self.dataDic setObject:recordCaseInfo forKey:key];
//        }
//    }
//    [self.tableView reloadData];
//}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadModel];
    [self setUpTableView];
    //Do any additional setup after loading the view.
    UIViewController *rec = [self.splitViewController.viewControllers objectAtIndex:0];
    
    UINavigationController *nac = (UINavigationController*)rec;
    RecordNavagationViewController *recNav = (RecordNavagationViewController*)[nac.viewControllers firstObject];
    
    recNav.delegate = self;
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   
    
    NSString *patientID = [[NSUserDefaults standardUserDefaults] objectForKey:@"pID"];
    NSString *patientName = [[NSUserDefaults standardUserDefaults] objectForKey:@"pName"];
    if ([patientID isEqualToString:@""] && [patientName isEqualToString:@""]) {
    
    }else {
        TempPatient *patient1 = [[TempPatient alloc] initWithPatientID:@{@"pID":patientID,@"pName":patientName}];
        [self loadRecordCaseFromServerWithPatient:patient1];
    }
    
    
}
-(void)setUpTableView
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}
-(void)loadModel
{
    _currentRow = -1;
    self.headViewArray = [[NSMutableArray alloc]init ];
    for(int i = 0;i< self.classficationArray.count ;i++)
    {
        HeadView* headview = [[HeadView alloc] init];
        headview.delegate = self;
        headview.section = i;
        [headview.backBtn setTitle:[self.classficationArray objectAtIndex:i] forState:UIControlStateNormal];
        [self.headViewArray addObject:headview];
    }
    
}
#pragma mask - RecordNavagationViewControllerDelegate
-(void)loadPatientInfoWithPatientID:(TempPatient*)patient
{
    
    self.dataDic = nil;
    [MessageObject messageObjectWithUsrStr:@"2216" pwdStr:@"test" iHMsgSocket:self.socket optInt:2016 dictionary:@{@"syxh":[NSString stringWithFormat:@"%@",patient.pID]} block:^(IHSockRequest *request) {
        NSMutableDictionary *patientDict = [[NSMutableDictionary alloc] init];
        
        if ([request.responseData isKindOfClass:[NSDictionary class]]) {
            NSDictionary *tempDict  = (NSDictionary*)request.responseData;
            if ([tempDict.allKeys containsObject:@"csd_s"]) {
                [patientDict setObject:[NSString stringWithFormat:@"%@", tempDict[@"csd_s"]]forKey:@"pProvince"];
            }
            if ([tempDict.allKeys containsObject:@"hyzk"]) {
                [patientDict setObject:[NSString stringWithFormat:@"%@", tempDict[@"hyzk"]]forKey:@"pMaritalStatus"];
            }
            if ([tempDict.allKeys containsObject:@"mzbm"]) {
                [patientDict setObject:[NSString stringWithFormat:@"%@",tempDict[@"mzbm"]]forKey:@"pNation"];
            }
            //            if ([tempDict.allKeys containsObject:@"patid"]) {
            //                [patientDict setObject:[NSString stringWithFormat:@"%@",tempDict[@"patid"]]forKey:@"pID"];
            //            }
            
            if ([tempDict.allKeys containsObject:@"sex"]) {
                [patientDict setObject:[NSString stringWithFormat:@"%@", tempDict[@"sex"]]forKey:@"pGender"];
            }
            if ([tempDict.allKeys containsObject:@"hzxm"]) {
                [patientDict setObject:[NSString stringWithFormat:@"%@",tempDict[@"hzxm"]]forKey:@"pName"];
            }
            if ([tempDict.allKeys containsObject:@"ksdm"]) {
                [patientDict setObject:[NSString stringWithFormat:@"%@",tempDict[@"ksdm"]]forKey:@"pProvince"];
            }
            if ([tempDict.allKeys containsObject:@"csd_s"]) {
                [patientDict setObject:[NSString stringWithFormat:@"%@",tempDict[@"csd_s"]] forKey:@"pDept"];
            }
            if ([tempDict.allKeys containsObject:@"cwdm"]) {
                [patientDict setObject:[NSString stringWithFormat:@"%@",tempDict[@"cwdm"]] forKey:@"pBedNum"];
            }
            if ([tempDict.allKeys containsObject:@"lxr"]) {
                [patientDict setObject:[NSString stringWithFormat:@"%@",tempDict[@"lxr"]]forKey:@"pLinkman"];
            }
            if ([tempDict.allKeys containsObject:@"lxrdh"]) {
                [patientDict setObject:[NSString stringWithFormat:@"%@",tempDict[@"lxrdh"]]forKey:@"pLinkmanMobileNum"];
            }
            if ([tempDict.allKeys containsObject:@"zycs"]) {
                [patientDict setObject:[NSString stringWithFormat:@"%@", tempDict[@"zycs"]]forKey:@"pCountOfHospitalized"];
            }
            if ([tempDict.allKeys containsObject:@"ryrq"]) {
                [patientDict setObject:[NSString stringWithFormat:@"%@", tempDict[@"ryrq"]]forKey:@"pAdmitDate"];
            }
            
        }
        
      //  NSString *patientID = [[NSUserDefaults standardUserDefaults] objectForKey:@"pID"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",patient.pID] forKey:@"pID"];
        [[NSUserDefaults standardUserDefaults] setObject:patient.pName forKey:@"pName"];

        [patientDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"dID"] forKey:@"dID"];
        [patientDict setObject:patient.pID forKey:@"pID"];
        [self.coreDataStack patientFetchWithDict:patientDict];
        
        NSString *dID = [[NSUserDefaults standardUserDefaults] objectForKey:@"dID"];

        [patientDict setObject:dID forKey:@"dID"];
        [patientDict setObject:@"入院记录" forKey:@"caseType"];
        [patientDict setObject:@"未创建" forKey:@"caseStatus"];
        RecordBaseInfo *recordCaseInfo = [self.coreDataStack fetchRecordWithDict:patientDict];
        [self.recordCaseArray addObject:recordCaseInfo];
        
        for (RecordBaseInfo *record in self.recordCaseArray) {
            
            if ([self.classficationArray containsObject:record.caseStatus]) {
                NSMutableArray *arr = [self.dataDic objectForKey:record.caseStatus];
                [arr addObject:record];
                [self.dataDic setObject:arr forKey:record.caseStatus];
            }
                
        }
        
        [self.tableView reloadData];
    } failConection:^(NSError *error) {
        
    }];
}
-(void)didSelectedPatient:(TempPatient *)patient
{
    [self loadRecordCaseFromServerWithPatient:patient];
}
-(void)loadRecordCaseFromServerWithPatient:(TempPatient*)patient
{
    [[NSUserDefaults standardUserDefaults] setObject:patient.pID forKey:@"pID"];
    [[NSUserDefaults standardUserDefaults] setObject:patient.pName forKey:@"pName"];
    
    
    NSString *dID = [[NSUserDefaults standardUserDefaults] objectForKey:@"dID"];
    
    NSDictionary *dict = @{@"pid":patient.pID,@"did":dID};
    
    self.recordCaseArray = [[NSMutableArray alloc] init];
    
    [MessageObject messageObjectWithUsrStr:dID pwdStr:@"test" iHMsgSocket:self.socket optInt:2013 dictionary:dict block:^(IHSockRequest *request) {
        
        if ([request.responseData isKindOfClass:[NSArray class]]) {
            NSArray *tempArray = (NSArray*)request.responseData;
            if (tempArray.count == 0) {
                
                [self loadPatientInfoWithPatientID:patient];
                
            }else {
                for (NSDictionary *recordDict in tempArray) {
                    NSDictionary *dict = [self parseCaseInfoWithDic:recordDict];
                    RecordBaseInfo *recordBaseInfo = [self.coreDataStack fetchRecordWithDict:dict];
                    [self.recordCaseArray addObject:recordBaseInfo];
                }
                self.dataDic = nil;
                
                for (RecordBaseInfo *record in self.recordCaseArray) {
                    
                    if ([self.classficationArray containsObject:record.caseStatus]) {
                        NSMutableArray *arr = [self.dataDic objectForKey:record.caseStatus];
                        [arr addObject:record];
                        [self.dataDic setObject:arr forKey:record.caseStatus];
                    }
                    
                }
                [self.tableView reloadData];
                
                
            }
        }
        
        
    } failConection:^(NSError *error) {
        
    }];
}
-(NSString*)transformCaseStatue:(NSString*)caseStatusInt
{
    NSDictionary *tempDict= @{@"0":@"保存未提交",@"1":@"提交未审核",@"2":@"主治医师审核",@"3":@"（副）主任医师审核",@"4":@"主治医师审核未通过",@"5":@"副主任医师审核通过",@"6":@"副主任医师审核未通过",@"7":@"归档"   ,@"8":@"撤回"};
    if ([tempDict.allKeys containsObject:caseStatusInt]) {
        return tempDict[caseStatusInt];
    }else {
        return @"保存未提交";
    }
}
-(NSDictionary*)caseKeyDic
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"dID"]   forKey:@"did"];
    [dict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"pID"]   forKey:@"pid"];
    return dict;
}

#pragma mark - TableViewdelegate&&TableViewdataSource

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    HeadView* headView = [self.headViewArray objectAtIndex:indexPath.section];
    
    return headView.open?67:0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 45;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}


- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [self.headViewArray objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    HeadView* headView = [self.headViewArray objectAtIndex:section];
    
    NSArray *tempA = self.dataDic[headView.backBtn.titleLabel.text];
    return headView.open?tempA.count:0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.headViewArray count];
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *indentifier = @"managementCell";
    RecordManagedCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    cell.delegate = self;

    HeadView* view = [self.headViewArray objectAtIndex:indexPath.section];
    NSArray *tempArray = [self.dataDic objectForKey:view.backBtn.titleLabel.text];
    RecordBaseInfo *record = tempArray[indexPath.row];
    cell.caseTypeLabel.text = record.caseType;
    return cell;
}

-(NSString*)timeIntervalBetweenTimes:(NSDate*)date1 date2:(NSDate*)data2
{
  NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *senddate=date1;
    NSDate *endDate = data2;
    NSDate *senderDate = [dateFormatter dateFromString:[dateFormatter stringFromDate:senddate]];
    NSDate *enderDate = [dateFormatter dateFromString:[dateFormatter stringFromDate:endDate]];

    NSTimeInterval time=[enderDate timeIntervalSinceDate:senderDate];
    int days = ((int)time)/(3600*24);
    int hours = ((int)time)%(3600*24)/3600;
    int minute = ((int)time)%(3600*24)*600/60;
    NSString *dateContent=[[NSString alloc] initWithFormat:@"%i天%i小时%i分钟",days,hours,minute];
    return dateContent;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    HeadView* view = [self.headViewArray objectAtIndex:indexPath.section];
    NSArray *tempArray = [self.dataDic objectForKey:view.backBtn.titleLabel.text];
    RecordBaseInfo *record = tempArray[indexPath.row];
    
    if (view.open) {
        _currentRow = indexPath.row;
       // [_tableView reloadData];
    }
    
    RecordManagedCellTableViewCell *cell = (RecordManagedCellTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];

    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"WriteCaseStoryboard" bundle:nil];
    UINavigationController *nav = [storyBoard instantiateViewControllerWithIdentifier:@"writeNav"];
    
    WriteCaseSaveViewController *saveVC = (WriteCaseSaveViewController*)[nav.viewControllers firstObject];
    
    //saveVC.currentDoctor = [CurrentDoctor currentDoctor];
    //saveVC.currentPatient = [[CurrentPatient alloc] init];
    //saveVC.isRemoveLeftButton = YES;
    //saveVC.caseType = cell.caseTypeLabel.text;
    saveVC.recordBaseInfo = record;
    
    [self presentViewController:nav animated:YES completion:nil];
  //  [self.navigationController pushViewController:saveVC animated:YES];
    
    
}

#pragma mark - HeadViewdelegate
-(void)selectedWith:(HeadView *)view{
    self.currentRow = -1;

    if (view.open) {
//        for(int i = 0;i<[self.headViewArray count];i++)
//        {
//            HeadView *head = [self.headViewArray objectAtIndex:i];
//            head.open = NO;
//            //[head.backBtn setBackgroundImage:[UIImage imageNamed:@"btn_momal"] forState:UIControlStateNormal];
//        }
        view.open = NO;
        [_tableView reloadData];
        return;
    }
    _currentSection = view.section;
    [self reset];
    
}

//界面重置
- (void)reset
{
    for(int i = 0;i<[self.headViewArray count];i++)
    {
        HeadView *head = [self.headViewArray objectAtIndex:i];
        
        if(head.section == self.currentSection || head.open)
        {
            head.open = YES;
            //[head.backBtn setBackgroundImage:[UIImage imageNamed:@"btn_nomal"] forState:UIControlStateNormal];
            
        }else {
            //[head.backBtn setBackgroundImage:[UIImage imageNamed:@"btn_momal"] forState:UIControlStateNormal];
            
            head.open = NO;
        }
        
    }
    [self.tableView reloadData];
}

//#pragma mask - cell delegate
//-(void)didSelectedCellButton:(UIButton *)button inCell:(RecordManagedCellTableViewCell *)cell
//{
//    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
//    HeadView* view = [self.headViewArray objectAtIndex:indexPath.section];
//
//    [self performSegueWithIdentifier:@"EditCaseSegue" sender:nil];
//}
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
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
       
       NSString *caseStatus = [self transformCaseStatue:[NSString stringWithFormat:@"%@",dataDic[@"caseStatus"]]];
       
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

@end
