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


@interface RecordManagedViewController ()<UITableViewDataSource,UITableViewDelegate,HeadViewDelegate,RecordManagedCellTableViewCellDelegate,RecordNavagationViewControllerDelegate,WriteCaseSaveViewControllerDelegate>

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
        [_classficationArray addObject:@"提交未审核"];
        [_classficationArray addObject:@"主治医师审核"];
        [_classficationArray addObject:@"（副）主任医师审核"];
        [_classficationArray addObject:@"主治医师审核未通过"];
        [_classficationArray addObject:@"副主任医师审核通过"];
        [_classficationArray addObject:@"副主任医师审核未通过"];
        [_classficationArray addObject:@"归档"];
        [_classficationArray addObject:@"撤回"];
//        [_classficationArray addObject:@"已审核"];
//        [_classficationArray addObject:@"审核未通过"];
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
    [self loadModel];
    [self setUpTableView];
    
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
    
    }
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
    self.dataDic = nil;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self loadRecordCaseFromServerWithPatient:self.patient];
    });
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
    [MessageObject messageObjectWithUsrStr:@"2216" pwdStr:@"test" iHMsgSocket:self.socket optInt:2016 dictionary:@{@"syxh":[NSString stringWithFormat:@"%@",patient.pID]} block:^(IHSockRequest *request) {
        NSMutableDictionary *patientDict = [[NSMutableDictionary alloc] init];
        
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
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",patient.pID] forKey:@"pID"];
        [[NSUserDefaults standardUserDefaults] setObject:patient.pName forKey:@"pName"];

        [patientDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"dID"] forKey:@"dID"];
        [patientDict setObject:patient.pID forKey:@"pID"];
       // [self.coreDataStack patientFetchWithDict:patientDict];
        
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
        dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl endRefreshing];
                [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
                
                [self.tableView reloadData];
        });
        
    } failConection:^(NSError *error) {
        [self connectServerFailWithMessage:@"2016,从服务器端获取病人信息，服务器断开连接"];
        
    }];
}
-(void)didSelectedPatient:(TempPatient *)patient
{
    self.patient = patient;
    self.dataDic = nil;
    [self.refreshControl beginRefreshing];
    [self.tableView setContentOffset:CGPointMake(0, -100) animated:YES];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self loadRecordCaseFromServerWithPatient:patient];
    });
}
-(void)loadRecordCaseFromServerWithPatient:(TempPatient*)patient
{
    NSString *dID = [[NSUserDefaults standardUserDefaults] objectForKey:@"dID"];
    
    NSDictionary *dict = @{@"pid":patient.pID,@"did":dID};
    
    self.recordCaseArray = [[NSMutableArray alloc] init];
    
    [MessageObject messageObjectWithUsrStr:dID pwdStr:@"test" iHMsgSocket:self.socket optInt:2013 dictionary:dict block:^(IHSockRequest *request) {
        
        if ([request.responseData isKindOfClass:[NSArray class]]) {
            NSArray *tempArray = (NSArray*)request.responseData;
            
            //只有服务器端没有保存，本地的缓存才有效，否则服务器端的病历将覆盖本地的缓存
            if (tempArray.count == 0) {
                [self loadPatientInfoWithPatientID:patient];
                
            }else {
                for (NSDictionary *recordDict in tempArray) {
                    NSDictionary *dict = [self parseCaseInfoWithDic:recordDict];
                    RecordBaseInfo *recordBaseInfo = [self.coreDataStack fetchRecordWithDict:dict];
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
        }
        
        
    } failConection:^(NSError *error) {
        
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
    NSDictionary *tempDict= @{@"0":@"保存未提交",@"1":@"提交未审核",@"2":@"主治医师审核",@"3":@"（副）主任医师审核",@"4":@"主治医师审核未通过",@"5":@"副主任医师审核通过",@"6":@"副主任医师审核未通过",@"7":@"归档"   ,@"8":@"撤回"};
    if ([tempDict.allKeys containsObject:caseStatusInt]) {
        return tempDict[caseStatusInt];
    }else {
        return @"未创建";
    }
}
-(NSString *)transformCaseStatusString:(NSString*)caseStatusString
{
    NSDictionary *tempDict= @{@"保存未提交":@"0",@"提交未审核":@"1",@"主治医师审核":@"2",@"（副）主任医师审核":@"3",@"主治医师审核未通过":@"4",@"副主任医师审核通过":@"5",@"副主任医师审核未通过":@"6",@"归档":@"7",@"撤回":@"8"};
    
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
    
    if ([record.caseStatus isEqualToString:@"未创建"] || [record.caseStatus isEqualToString:@"保存未提交"]) {
        cell.remainTimeLabel.text = [self remainTimeFromAdmitDate:record.patient.pAdmitDate];
    }else {
        cell.remainTimeLabel.text = [NSString stringWithFormat:@"病历状态：%@",record.caseStatus];
    }
    return cell;
}
-(NSString *)remainTimeFromAdmitDate:(NSString *)admitDateStr
{
    if (admitDateStr) {
        
        NSString *remainTime = @"";
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss "];
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
    }
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"WriteCaseStoryboard" bundle:nil];
    UINavigationController *nav = [storyBoard instantiateViewControllerWithIdentifier:@"writeNav"];
    
    WriteCaseSaveViewController *saveVC = (WriteCaseSaveViewController*)[nav.viewControllers firstObject];
    
    saveVC.recordBaseInfo = record;
    saveVC.delegate =  self;
    saveVC.tempPatient = self.patient;
    saveVC.isHideRetreatButton = YES;
    
    [self presentViewController:nav animated:YES completion:nil];

}
#pragma mask -WriteCaseSaveViewControllerDelegate
-(void)didExitEditRecordCaseWithCurrentPatient:(TempPatient*)patient;
{
    self.dataDic = nil;

    [self loadRecordCaseFromServerWithPatient:patient];
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        return YES;
    }
    return NO;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        HeadView* view = [self.headViewArray objectAtIndex:indexPath.section];
        NSMutableArray *tempArray = [self.dataDic objectForKey:view.backBtn.titleLabel.text];
        RecordBaseInfo *record = tempArray[indexPath.row];

        [tempArray removeObjectAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

        NSString *caseID = record.caseID;
        NSString *doctorID = [[NSUserDefaults standardUserDefaults] objectForKey:@"dID"];
        
        [MessageObject messageObjectWithUsrStr:@"2216" pwdStr:@"test" iHMsgSocket:self.socket optInt:2006 dictionary:@{@"did":doctorID,@"id":caseID} block:^(IHSockRequest *request) {
            if (request.resp == 0) {
                NSLog(@"删除成功");
            }
            
        } failConection:^(NSError *error) {
            
        }];
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
