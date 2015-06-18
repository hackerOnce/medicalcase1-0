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
#import "AuditCaseViewController.h"


@interface RecordManagedViewController ()<UITableViewDataSource,UITableViewDelegate,HeadViewDelegate,RecordManagedCellTableViewCellDelegate,RecordNavagationViewControllerDelegate,WriteCaseSaveViewControllerDelegate,AuditCaseViewControllerDelegate>

@property (nonatomic,strong) NSMutableArray *classficationArray;
@property (nonatomic,strong) NSMutableDictionary *dataDic;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) CoreDataStack *coreDataStack;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic,strong) NSArray *recordCases;
@property (weak, nonatomic) IBOutlet UILabel *remainTime;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (nonatomic,strong) NSMutableArray *sumArray;


@property (nonatomic,strong) RecordBaseInfo *recordBaseInfo;

@property (nonatomic,strong) IHMsgSocket *socket;
@property (nonatomic,strong) UIRefreshControl *refreshControl;

@property (nonatomic,strong) NSMutableArray *recordCaseArray;
@property (nonatomic,strong) NSMutableArray *auditCaseArray;

@property (nonatomic,strong) TempPatient *patient;

@property (nonatomic) BOOL isAuditCase; //待审核病历
@property (nonatomic,strong) TempCaseBaseInfo *selectedCaseInfo;
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
        if (![[_socket IHGCDSocket].asyncSocket isConnected]) {
            [_socket connectToHost:@"192.168.10.106" onPort:2323];
        }
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
        [_classficationArray addObject:@"住院医师提交（审核）"];
        [_classficationArray addObject:@"主治医师提交（审核）"];
        [_classficationArray addObject:@"主任医师审核（提交）通过"];
        [_classficationArray addObject:@"归档"];
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
- (void)viewDidLoad {
    [super viewDidLoad];
  //  [self loadModel];
    [self setUpTableView];
    
    UIViewController *rec = [self.splitViewController.viewControllers objectAtIndex:0];
    
    UINavigationController *nac = (UINavigationController*)rec;
    RecordNavagationViewController *recNav = (RecordNavagationViewController*)[nac.viewControllers firstObject];
    
    recNav.delegate = self;
    
}


-(void)setUpTableView
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(pullRefreshControlAction:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refresh];
    
    self.refreshControl = refresh;
    
}
-(void)pullRefreshControlAction:(UIRefreshControl*)refreshControl
{
    if (self.isAuditCase) {
        [self reloadTableViewForAuditWithDoctor:[TempDoctor setSharedDoctorWithDict:nil]];
    }else {
        self.dataDic = nil;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            if (self.patient) {
                [self loadRecordCaseFromServerWithPatient:self.patient];
            }
        });

    }
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
#pragma mask -Audit view controller delegate
-(void)didExitAuditCaseViewController
{        [self reloadTableViewForAuditWithDoctor:[TempDoctor setSharedDoctorWithDict:nil]];
}
#pragma mask - RecordNavagationViewControllerDelegate
-(void)recordCasesWithPatient:(Patient*)patient andTempPatient:(TempPatient*)tempPatient
{
    NSString *patientID = StringValue(tempPatient.pID);
    NSString *doctorID = StringValue([TempDoctor setSharedDoctorWithDict:nil].dID);
    
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
    [tempDict setObject:patientID forKey:@"pID"];
    [tempDict setObject:doctorID forKey:@"dID"];

    
    NSArray *records = [self.coreDataStack fetchRecordWithDict:tempDict isReturnNil:NO];
    
    for (RecordBaseInfo *record in records) {
        
        if ([self.classficationArray containsObject:record.caseStatus]) {
            NSMutableArray *arr = [self.dataDic objectForKey:record.caseStatus];
            record.patient = patient;
            [arr addObject:record];
            [self.dataDic setObject:arr forKey:record.caseStatus];
            
        }
    }
    [self.coreDataStack saveContext];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.refreshControl endRefreshing];
        [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
        
        [self.tableView reloadData];
    });
    
}
-(void)loadPatientInfoWithPatientID:(TempPatient*)patient
{
    NSString *patientID = StringValue(patient.pID);
    NSString *doctorID = StringValue([TempDoctor setSharedDoctorWithDict:nil].dID);
    
    Patient *coreDataPatient = [self.coreDataStack patientFetchWithDict:@{@"pID":patientID,@"dID":doctorID} isReturnNil:YES];
    
    if (coreDataPatient) {
        [self recordCasesWithPatient:coreDataPatient andTempPatient:patient];
    }else {
        [MessageObject messageObjectWithUsrStr:[TempDoctor setSharedDoctorWithDict:nil].dID pwdStr:@"test" iHMsgSocket:self.socket optInt:2016 dictionary:@{@"syxh":[NSString stringWithFormat:@"%@",patient.pID]} block:^(IHSockRequest *request) {
            NSMutableDictionary *patientDict = [[NSMutableDictionary alloc] init];
            
            [patientDict setObject:patientID forKey:@"pID"];
            [patientDict setObject:doctorID forKey:@"dID"];
            
            if ([request.responseData isKindOfClass:[NSDictionary class]]) {
                NSDictionary *tempDict  = (NSDictionary*)request.responseData;
                if ([tempDict.allKeys containsObject:@"csd_s"]) {
                    [patientDict setObject:StringValue(tempDict[@"csd_s"])forKey:@"pProvince"];
                }
                if ([tempDict.allKeys containsObject:@"hyzk"]) {
                    [patientDict setObject:StringValue(tempDict[@"hyzk"])forKey:@"pMaritalStatus"];
                }
                if ([tempDict.allKeys containsObject:@"mzbm"]) {
                    [patientDict setObject:[NSString stringWithFormat:@"%@",tempDict[@"mzbm"]]forKey:@"pNation"];
                }
                if ([tempDict.allKeys containsObject:@"lxdz"]) {
                    [patientDict setObject:[NSString stringWithFormat:@"%@",tempDict[@"lxdz"]]forKey:@"pDetailAddress"];
                }
                if ([tempDict.allKeys containsObject:@"age"]) {
                    [patientDict setObject:[NSString stringWithFormat:@"%@",tempDict[@"age"]]forKey:@"pAge"];
                }
                
                
                if ([tempDict.allKeys containsObject:@"sex"]) {
                    [patientDict setObject:[NSString stringWithFormat:@"%@", tempDict[@"sex"]]forKey:@"pGender"];
                }
                if ([tempDict.allKeys containsObject:@"hzxm"]) {
                    [patientDict setObject:[NSString stringWithFormat:@"%@",tempDict[@"hzxm"]]forKey:@"pName"];
                }
                if ([tempDict.allKeys containsObject:@"ksdm"]) {
                    [patientDict setObject:[NSString stringWithFormat:@"%@",tempDict[@"ksdm"]]forKey:@"pDept"];
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
                if ([tempDict.allKeys containsObject:@"zybm"]) {
                    [patientDict setObject:[NSString stringWithFormat:@"%@", tempDict[@"zybm"]]forKey:@"pProfession"];
                }
            }
            
            Patient *patientCore  = [self.coreDataStack patientFetchWithDict:patientDict isReturnNil:NO];
            [self recordCasesWithPatient:patientCore andTempPatient:patient];
            
        }failConection:^(NSError *error) {
            [self connectServerFailWithMessage:@"2016,从服务器端获取病人信息，服务器断开连接"];
            
        }];
    }
    
    
    
//    }else {
//        [MessageObject messageObjectWithUsrStr:[TempDoctor setSharedDoctorWithDict:nil].dID pwdStr:@"test" iHMsgSocket:self.socket optInt:2016 dictionary:@{@"syxh":[NSString stringWithFormat:@"%@",patient.pID]} block:^(IHSockRequest *request) {
//            NSMutableDictionary *patientDict = [[NSMutableDictionary alloc] init];
//            
//            if ([request.responseData isKindOfClass:[NSDictionary class]]) {
//                NSDictionary *tempDict  = (NSDictionary*)request.responseData;
//                if ([tempDict.allKeys containsObject:@"csd_s"]) {
//                    [patientDict setObject:StringValue(tempDict[@"csd_s"])forKey:@"pProvince"];
//                }
//                if ([tempDict.allKeys containsObject:@"hyzk"]) {
//                    [patientDict setObject:StringValue(tempDict[@"hyzk"])forKey:@"pMaritalStatus"];
//                }
//                if ([tempDict.allKeys containsObject:@"mzbm"]) {
//                    [patientDict setObject:[NSString stringWithFormat:@"%@",tempDict[@"mzbm"]]forKey:@"pNation"];
//                }
//                if ([tempDict.allKeys containsObject:@"lxdz"]) {
//                    [patientDict setObject:[NSString stringWithFormat:@"%@",tempDict[@"lxdz"]]forKey:@"pDetailAddress"];
//                }
//                if ([tempDict.allKeys containsObject:@"age"]) {
//                    [patientDict setObject:[NSString stringWithFormat:@"%@",tempDict[@"age"]]forKey:@"pAge"];
//                }
//                
//                
//                if ([tempDict.allKeys containsObject:@"sex"]) {
//                    [patientDict setObject:[NSString stringWithFormat:@"%@", tempDict[@"sex"]]forKey:@"pGender"];
//                }
//                if ([tempDict.allKeys containsObject:@"hzxm"]) {
//                    [patientDict setObject:[NSString stringWithFormat:@"%@",tempDict[@"hzxm"]]forKey:@"pName"];
//                }
//                if ([tempDict.allKeys containsObject:@"ksdm"]) {
//                    [patientDict setObject:[NSString stringWithFormat:@"%@",tempDict[@"ksdm"]]forKey:@"pDept"];
//                }
//                
//                if ([tempDict.allKeys containsObject:@"cwdm"]) {
//                    [patientDict setObject:[NSString stringWithFormat:@"%@",tempDict[@"cwdm"]] forKey:@"pBedNum"];
//                }
//                if ([tempDict.allKeys containsObject:@"lxr"]) {
//                    [patientDict setObject:[NSString stringWithFormat:@"%@",tempDict[@"lxr"]]forKey:@"pLinkman"];
//                }
//                if ([tempDict.allKeys containsObject:@"lxrdh"]) {
//                    [patientDict setObject:[NSString stringWithFormat:@"%@",tempDict[@"lxrdh"]]forKey:@"pLinkmanMobileNum"];
//                }
//                if ([tempDict.allKeys containsObject:@"zycs"]) {
//                    [patientDict setObject:[NSString stringWithFormat:@"%@", tempDict[@"zycs"]]forKey:@"pCountOfHospitalized"];
//                }
//                if ([tempDict.allKeys containsObject:@"ryrq"]) {
//                    [patientDict setObject:[NSString stringWithFormat:@"%@", tempDict[@"ryrq"]]forKey:@"pAdmitDate"];
//                }
//                if ([tempDict.allKeys containsObject:@"zybm"]) {
//                    [patientDict setObject:[NSString stringWithFormat:@"%@", tempDict[@"zybm"]]forKey:@"pProfession"];
//                }
//            }
//            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",patient.pID] forKey:@"pID"];
//            [[NSUserDefaults standardUserDefaults] setObject:patient.pName forKey:@"pName"];
//            
//            [patientDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"dID"] forKey:@"dID"];
//            [patientDict setObject:patient.pID forKey:@"pID"];
//            // [self.coreDataStack patientFetchWithDict:patientDict];
//            [patientDict setObject:@"" forKey:@"caseID"];
//            NSString *dID = [[NSUserDefaults standardUserDefaults] objectForKey:@"dID"];
//            
//            [patientDict setObject:dID forKey:@"dID"];
//            [patientDict setObject:@"入院记录" forKey:@"caseType"];
//            [patientDict setObject:@"未创建" forKey:@"caseStatus"];
//            RecordBaseInfo *recordCaseInfo = [self.coreDataStack fetchRecordWithDict:patientDict isReturnNil:NO];
//            [self.recordCaseArray addObject:recordCaseInfo];
//            
//            for (RecordBaseInfo *record in self.recordCaseArray) {
//                
//                if ([self.classficationArray containsObject:record.caseStatus]) {
//                    NSMutableArray *arr = [self.dataDic objectForKey:record.caseStatus];
//                    [arr addObject:record];
//                    [self.dataDic setObject:arr forKey:record.caseStatus];
//                }
//                
//            }
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.refreshControl endRefreshing];
//                [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
//                
//                [self.tableView reloadData];
//            });
//            
//        }
//    }
}

#pragma mask - record navigation view controller delegate
-(void)didSelectedPatient:(TempPatient *)patient
{
    self.patient = patient;
    self.dataDic = nil;
    [self.refreshControl beginRefreshing];
    [self.tableView setContentOffset:CGPointMake(0, -100) animated:YES];
    
    self.isAuditCase = NO;
    [self loadModel];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self loadRecordCaseFromServerWithPatient:patient];
    });
}
-(void)didSelectedAuditTitleWithTempDoctor:(TempDoctor *)tempDoctor
{
    
    [self reloadTableViewForAuditWithDoctor:tempDoctor];
}
-(void)reloadTableViewForAuditWithDoctor:(TempDoctor*)tempDoctor
{
    [self.refreshControl beginRefreshing];
    [self.tableView setContentOffset:CGPointMake(0, -100) animated:YES];
    
    NSString *did = tempDoctor.dID;
    if (!did) {
        return;
    }
    self.auditCaseArray = [[NSMutableArray alloc] init];
    self.isAuditCase = YES;
    [MessageObject messageObjectWithUsrStr:tempDoctor.dID pwdStr:@"test" iHMsgSocket:self.socket optInt:1503 dictionary:@{@"did":did,@"pid":@""} block:^(IHSockRequest *request) {
        if ([request.responseData isKindOfClass:[NSArray class]]) {
            NSArray *tempArray = (NSArray*)request.responseData;
            
            for (NSDictionary *recordDict in tempArray) {
                NSDictionary *dict = [self parseCaseInfoWithDic:recordDict];
                
                TempCaseBaseInfo *tempRecordBaseInfo = [[TempCaseBaseInfo alloc] initWithCaseInfoDic:dict];
                [self.auditCaseArray addObject:tempRecordBaseInfo];
            }
        }
            dispatch_async(dispatch_get_main_queue(), ^{
            self.isAuditCase = YES;
            [self.refreshControl endRefreshing];
            [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
            [self.tableView reloadData];
        });
        
    } failConection:^(NSError *error) {
        if (self.refreshControl.isRefreshing) {
            [self.refreshControl endRefreshing];
            [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
        }
    }];
}
-(void)loadRecordCaseFromServerWithPatient:(TempPatient*)patient
{
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
                        NSArray *recordCases = [self.coreDataStack fetchRecordWithDict:dict isReturnNil:NO];
                        RecordBaseInfo *recordBaseInfo = [recordCases firstObject];
                        [self.recordCaseArray addObject:recordBaseInfo];
                    }
                    
                    for (RecordBaseInfo *record in self.recordCaseArray) {
                        
                        if ([self.classficationArray containsObject:record.caseStatus]) {
                            NSMutableArray *arr = [self.dataDic objectForKey:record.caseStatus];
                            [arr addObject:record];
                            [self.dataDic setObject:arr forKey:record.caseStatus];
                        }
                        
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.refreshControl endRefreshing];
                        [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
                        
                        [self.tableView reloadData];
                    });
                }
  
        }else {
            
            [self connectServerFailWithMessage:[NSString stringWithFormat:@"2013, 从服务器获取病人病历，返会resp = %@",@(request.resp)]];

        }
        
        
    } failConection:^(NSError *error) {
        
//        if (self.refreshControl.isRefreshing) {
//            [self.refreshControl endRefreshing];
//            [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
//        }
        [self connectServerFailWithMessage:@"2013, 从服务器获取病人病历，服务器断开连接"];
    }];
}
-(void)connectServerFailWithMessage:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.refreshControl.isRefreshing) {
            [self.refreshControl endRefreshing];
            [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:message?message:@"服务器连接失败" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
    });
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
-(NSString *)transformCaseStatusString:(NSString*)caseStatusString
{
    NSDictionary *tempDict= @{@"保存未提交":@"0",@"住院医师提交（审核）":@"1",@"主治医师提交（审核）":@"2",@"主任医师审核（提交）通过":@"3",@"归档":@"4"};
    
    if ([tempDict.allKeys containsObject:caseStatusString]) {
        return tempDict[caseStatusString];
    }else {
        return @"0";
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
    if (self.isAuditCase) {
        return 67;
    }else {
        HeadView* headView = [self.headViewArray objectAtIndex:indexPath.section];
        return  headView.open?67:0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return self.isAuditCase?0.01:45;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}


- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return self.isAuditCase?nil:[self.headViewArray objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (self.isAuditCase) {
        return self.auditCaseArray.count;
    }else {
        HeadView* headView = [self.headViewArray objectAtIndex:section];
        
        NSArray *tempA = self.dataDic[headView.backBtn.titleLabel.text];
        return headView.open?tempA.count:0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.isAuditCase) {
        return 1;
    }else {
        return [self.headViewArray count];
    }
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.isAuditCase) {
        static NSString *identifier = @"PendingAuditCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        UILabel *caseTypeLabel = (UILabel*)[cell viewWithTag:1001];
        UILabel *caseSubMissionLabel = (UILabel*)[cell viewWithTag:1002];
        UILabel *patientNameLabel = (UILabel*)[cell viewWithTag:1003];
        
        TempCaseBaseInfo *recordCase = [self.auditCaseArray objectAtIndex:indexPath.row];
        caseTypeLabel.text = recordCase.caseType;
        NSString *patientStr = [NSString stringWithFormat:@"患者姓名: %@",recordCase.pName];
        patientNameLabel.text = patientStr;
        
        NSString *tempString;
        
        TempDoctor *doctor = [TempDoctor setSharedDoctorWithDict:nil];
        if ([doctor.dProfessionalTitle isEqualToString:@"主治医师"]) {
            tempString = [NSString stringWithFormat:@"住院医师: %@ 住院医师: %@",recordCase.residentName,recordCase.residentName];
        }else {
           tempString = [NSString stringWithFormat:@"住院医师: %@ 主治医师: %@",recordCase.residentName,recordCase.attendingPhysiciandName];
        }
        
        tempString = [tempString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        caseSubMissionLabel.text = tempString;
        return cell;
    }else {
        static NSString *indentifier = @"managementCell";
        RecordManagedCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
        cell.delegate = self;
        
        HeadView* view = [self.headViewArray objectAtIndex:indexPath.section];
        NSArray *tempArray = [self.dataDic objectForKey:view.backBtn.titleLabel.text];
        RecordBaseInfo *record = tempArray[indexPath.row];
        cell.caseTypeLabel.text = record.caseType;
        
        if ([record.caseStatus isEqualToString:@"未创建"] || [record.caseStatus isEqualToString:@"保存未提交"]) {
            cell.remainTimeLabel.text = [self remainTimeFromAdmitDate:record.patient.pAdmitDate];
        }else {
            cell.remainTimeLabel.text = [NSString stringWithFormat:@"病历状态：%@",record.caseStatus];
        }
        return cell;
    }
    
}
-(NSString *)remainTimeFromAdmitDate:(NSString *)admitDateStr
{
    if (admitDateStr) {
        
        NSString *remainTime = @"";
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyyMMddhh:mm:ss "];
        NSDate *admitDate = [formatter dateFromString:admitDateStr];
        
        NSDate *currentDate = [formatter dateFromString:[formatter stringFromDate:[NSDate date]]];
        
        NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:admitDate];
        int days = ((int)timeInterval)/(3600*24);
        int hours = ((int)timeInterval)%(3600*24)/3600;
        int minute = ((int)timeInterval)%(3600*24)%3600/60;
        remainTime=[[NSString alloc] initWithFormat:@"%i天%i小时%i分钟",days,hours,minute];
        
        if (days > 2) {
            
        }
        return remainTime;

    }else {
      return  @"";
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.isAuditCase) {
        TempCaseBaseInfo *shortRecordCase = [self.auditCaseArray objectAtIndex:indexPath.row];
        self.selectedCaseInfo = shortRecordCase;
        [self performSegueWithIdentifier:@"auditSegue" sender:nil];
    }else {
        
        HeadView* view = [self.headViewArray objectAtIndex:indexPath.section];
        NSArray *tempArray = [self.dataDic objectForKey:view.backBtn.titleLabel.text];
        RecordBaseInfo *record = tempArray[indexPath.row];
        
        if (view.open) {
            _currentRow = indexPath.row;
        }
        
        
        if ([record.caseType isEqualToString:@"入院记录"]) {
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"WriteCaseStoryboard" bundle:nil];
            UINavigationController *nav = [storyBoard instantiateViewControllerWithIdentifier:@"writeNav"];
            
            WriteCaseSaveViewController *saveVC = (WriteCaseSaveViewController*)[nav.viewControllers firstObject];
            
            saveVC.recordBaseInfo = record;
            saveVC.delegate =  self;
            saveVC.tempPatient = self.patient;
            saveVC.isHideRetreatButton = YES;
            
            [self presentViewController:nav animated:YES completion:nil];
        }else if([record.caseType isEqualToString:@"首次病程记录"]){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"首次病程记录 待续" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
        
    }

}
#pragma mask -WriteCaseSaveViewControllerDelegate
-(void)didExitEditRecordCaseWithCurrentPatient:(TempPatient*)patient;
{
    self.dataDic = nil;

    [self loadRecordCaseFromServerWithPatient:patient];
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isAuditCase) {
        return NO;
    }else {
        if (indexPath.section == 1) {
            return YES;
        }
        return NO;
    }
    
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        if (self.isAuditCase) {
            
        }else {
            HeadView* view = [self.headViewArray objectAtIndex:indexPath.section];
            NSMutableArray *tempArray = [self.dataDic objectForKey:view.backBtn.titleLabel.text];
            RecordBaseInfo *record = tempArray[indexPath.row];
            
            [tempArray removeObjectAtIndex:indexPath.row];
            
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            NSString *caseID = record.caseID;
            NSString *doctorID = [[NSUserDefaults standardUserDefaults] objectForKey:@"dID"];
            
            [MessageObject messageObjectWithUsrStr:doctorID pwdStr:@"test" iHMsgSocket:self.socket optInt:2006 dictionary:@{@"did":doctorID,@"id":caseID} block:^(IHSockRequest *request) {
                if (request.resp == 0) {
                    NSLog(@"删除成功");
                }
                
            } failConection:^(NSError *error) {
                
            }];
        }
       
    }
}
#pragma mask - segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"auditSegue"]) {
        UINavigationController *nav = (UINavigationController*)segue.destinationViewController;
        AuditCaseViewController *auditCase = (AuditCaseViewController*)[nav.viewControllers firstObject];
        auditCase.delegate = self;
        auditCase.tempCaseInfo = self.selectedCaseInfo;
    }
}
#pragma mark - HeadViewdelegate
-(void)selectedWith:(HeadView *)view{
    self.currentRow = -1;

    if (view.open) {
        view.open = NO;
        
        NSIndexSet *indexSet=[NSIndexSet indexSetWithIndex:view.section];
        [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
        return;
    }else {
        view.open = YES;
        
        NSIndexSet *indexSet=[NSIndexSet indexSetWithIndex:view.section];
        [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
        _currentSection = view.section;
        
       _currentSection = view.section;
    }
    
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

@end
