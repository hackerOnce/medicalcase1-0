//
//  RecordNavagationViewController.m
//  MedicalCase
//
//  Created by ihefe-JF on 15/4/23.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import "RecordNavagationViewController.h"
#import "HeadView.h"
#import "Doctor.h"
#import "Patient.h"
#import "RecordBaseInfo.h"

@interface RecordNavagationViewController ()<UITableViewDelegate,UITableViewDataSource,HeadViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *classficationArray;
@property (nonatomic,strong) NSMutableDictionary *dataDic;

@property (nonatomic,strong) CoreDataStack *coreDataStack;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic) BOOL isFirstAppear;

@property (nonatomic,strong) NSMutableArray *records;//该医生的病历数组

@property (nonatomic,strong) NSMutableDictionary *patientDic;

@property (nonatomic,strong) IHMsgSocket *socket;

@end

@implementation RecordNavagationViewController
-(NSManagedObjectContext *)managedObjectContext
{
    return self.coreDataStack.managedObjectContext;
}
-(CoreDataStack *)coreDataStack
{
    _coreDataStack = [[CoreDataStack alloc] init];
    return _coreDataStack;
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

-(NSString *)logInDoctorID
{
    if (!_logInDoctorID) {
        _logInDoctorID = @"11";
    }
    return _logInDoctorID;
}
#pragma  mask - property

-(NSMutableDictionary *)patientDic
{
    if (!_patientDic) {
        _patientDic = [[NSMutableDictionary alloc] init];
    }
    return _patientDic;
}

-(NSMutableArray *)classficationArray
{
    if (!_classficationArray) {
        _classficationArray = [[NSMutableArray alloc] init];
        [_classficationArray addObject:@"本次住院"];
        [_classficationArray addObject:@"已出院(未归档)"];
    }
    return _classficationArray;
}
-(NSMutableDictionary *)dataDic
{
    if (!_dataDic) {
        _dataDic = [[NSMutableDictionary alloc] init];
        for (NSString *key in self.classficationArray) {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            [_dataDic setObject:array forKey:key];
        }
    }
    return _dataDic;
}

-(void)setRecords:(NSMutableArray *)records
{
    _records = records;
    
}

#pragma mask -view life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    //[self loadModel];
    [self setUpTableView];
    
    self.isFirstAppear = YES;
    
   // [self getPatientDataByDoctorID:self.logInDoctorID];
    
    [self loadDoctorInfoWithDoctorID:@"2216"];
}
-(void)setUpTableView
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}
-(void)loadDoctorInfoWithDoctorID:(NSString*)doctorID
{
    if (!doctorID) {
        return;
    }
    [MessageObject messageObjectWithUsrStr:@"2216" pwdStr:@"test" iHMsgSocket:self.socket optInt:1111 dictionary:NSDictionaryOfVariableBindings(doctorID) block:^(IHSockRequest *request) {
        
        if ([request.responseData isKindOfClass:[NSDictionary class]]) {
            NSDictionary *tempDict = (NSDictionary*)request.responseData;
            NSString *dID,*dName,*dProfessionalTitle,*dept,*medicalCaseTeam;
            if ([tempDict.allKeys containsObject:@""]) {
                dID = [tempDict objectForKey:@"dID"];
            }
            if ([tempDict.allKeys containsObject:@""]) {
                dName = [tempDict objectForKey:@"dName"];
            }
            if ([tempDict.allKeys containsObject:@""]) {
                dProfessionalTitle = [tempDict objectForKey:@"dProfessionalTitle"];
            }
            if ([tempDict.allKeys containsObject:@""]) {
                dept = [tempDict objectForKey:@"dept"];
            }
            if ([tempDict.allKeys containsObject:@""]) {
                medicalCaseTeam = [tempDict objectForKey:@"medicalCaseTeam"];
            }
            NSDictionary *doctorDict = @{@"dID":dID,@"dName":dName,@"dProfessionalTitle":dProfessionalTitle,@"dept":dept,@"medicalCaseTeam":medicalCaseTeam};
            
            TempDoctor *doctor = [TempDoctor setSharedDoctorWithDict:doctorDict];
            NSLog(@"doctor name: %@",doctor.dName);
            
            if ([doctor.dProfessionalTitle containsString:@"住院医师"]) {
                [self loadModel];
                
                [self getPatientDataByDoctorID:doctor.dID];
                
            }else {
                
                NSMutableArray *array = [[NSMutableArray alloc] init];
                [self.classficationArray addObject:@"待审核"];
                [self.dataDic setObject:array forKey:@"待审核"];
                
                
                [self loadModel];
                
                [self patientsFromServerWithDoctor:doctor sucessLoad:^(NSArray *resultArray) {
                    if (resultArray.count == 0) {
                        [self.dataDic setObject:resultArray forKey:@"待审核"];
                    }else {
                        [self.dataDic setObject:resultArray forKey:@"待审核"];
                    }
                } failConection:^(NSError *error) {
                    
                }];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
        
    } failConection:^(NSError *error) {
        
    }];
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
        
        if (i==0) {
            headview.open = YES;
        }else {
            headview.open = NO;
        }
    }
    
    
}

#pragma mask - load doctor from server
-(void)getPatientDataByDoctorID:(NSString*)dID
{
    [[NSUserDefaults standardUserDefaults] setObject:@"2216" forKey:@"dID"];
    [[NSUserDefaults standardUserDefaults] setObject:@"张三" forKey:@"dName"];
    
    [MessageObject messageObjectWithUsrStr:@"2216" pwdStr:@"test" iHMsgSocket:self.socket optInt:2015 dictionary:@{@"did":@"2225"} block:^(IHSockRequest *request) {
        if ([request.responseData isKindOfClass:[NSArray class]]) {
            NSArray *tempArray = (NSArray*)request.responseData;
            
            if (tempArray.count == 0) {
                
            }else {
                NSMutableArray *inHospital_ids = [[NSMutableArray alloc] init];
                NSMutableArray *outOfHospital_ids = [[NSMutableArray alloc] init];

                for (NSDictionary *patientDict in tempArray) {
                    TempPatient *patient = [[TempPatient alloc] initWithPatientID:nil];
                    
                    NSString *is_in_hospital;
   
                    if ([patientDict.allKeys containsObject:@"brzt"]) {
                        patient.patientState = [patientDict[@"brzt"] integerValue] == 1? @"未出院":@"已出院";
                        is_in_hospital = patientDict[@"brzt"];
                    }
                    if ([patientDict.allKeys containsObject:@"syxh"]) {
                        patient.pID =[NSString stringWithFormat:@"%@", patientDict[@"syxh"]];
                    }
                    
                    if ([patientDict.allKeys containsObject:@"hzxm"]) {
                        patient.pName = patientDict[@"hzxm"];
                    }
                    if([is_in_hospital integerValue] == 1){
                        [inHospital_ids addObject:patient];
                    }else {
                        [outOfHospital_ids addObject:patient];
                    }
                }
                [self.patientDic setObject:inHospital_ids forKey:@"本次住院"];
                [self.patientDic setObject:outOfHospital_ids forKey:@"已出院(未归档)"];
                
               dispatch_async(dispatch_get_main_queue(), ^{
                   [self.tableView reloadData];
               });
            }
        }
        
    } failConection:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert  = [[UIAlertView alloc] initWithTitle:@"2015, 服务器断开连接" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        });
    }];
}
#pragma mark - TableViewdelegate&&TableViewdataSource

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    HeadView* headView = [self.headViewArray objectAtIndex:indexPath.section];
    
    return headView.open?45:0;
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

    NSArray *tempA = self.patientDic[headView.backBtn.titleLabel.text];
    
    
    return headView.open?tempA.count:0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.headViewArray count];
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *indentifier = @"RecordNavCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indentifier];
        UIButton* backBtn=  [[UIButton alloc]initWithFrame:CGRectMake(0, 0, cell.frame.size.width, 45)];
        backBtn.tag = 20000;
        backBtn.userInteractionEnabled = NO;
        [backBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [cell.contentView addSubview:backBtn];
        
        
    }
    HeadView* view = [self.headViewArray objectAtIndex:indexPath.section];
    
    NSArray *tempA = self.patientDic[view.backBtn.titleLabel.text];
    TempPatient *patient = (TempPatient*)tempA[indexPath.row];
    cell.textLabel.text = patient.pName;
    
    if (indexPath.row == 0) {
        [cell setSelected:YES];
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    HeadView* view = [self.headViewArray objectAtIndex:indexPath.section];

    NSArray *tempA = self.patientDic[view.backBtn.titleLabel.text];
    TempPatient *patient = (TempPatient*)tempA[indexPath.row];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",patient.pID] forKey:@"pID"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",patient.pName] forKey:@"pName"];

    [self.delegate didSelectedPatient:patient];

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
        
        if ([view.backBtn.titleLabel.text isEqualToString:@"待审核"]) {
            
            [self patientsFromServerWithDoctor:[TempDoctor setSharedDoctorWithDict:nil] sucessLoad:^(NSArray *resultArray) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.dataDic setObject:resultArray forKey:@"待审核"];
                    NSIndexSet *indexSet=[NSIndexSet indexSetWithIndex:view.section];
                    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
                    _currentSection = view.section;
                    
                });
            } failConection:^(NSError *error) {
                
            }];
            
        }else {
            [self getPatientDataByDoctorID:[TempDoctor setSharedDoctorWithDict:nil].dID];
        }
    }
}
-(void)patientsFromServerWithDoctor:(TempDoctor*)tempDoctor sucessLoad:(void (^)(NSArray *resultArray))successful failConection:(void (^)(NSError *))fail
{
    NSString *doctorID = tempDoctor.dID;
    [MessageObject messageObjectWithUsrStr:@"2216" pwdStr:@"test" iHMsgSocket:self.socket optInt:1503 dictionary:@{@"did":doctorID} block:^(IHSockRequest *request) {
        
        NSMutableArray *patientArray = [[NSMutableArray alloc] init];
        
        if([request.responseData isKindOfClass:[NSArray class]]){
            NSArray *tempArray = (NSArray*)request.responseData;
            for (NSDictionary *dict in tempArray) {
                
                NSString *pID;
                NSString *pName;
            
                if ([dict.allKeys containsObject:@"patient"]) {
                    NSDictionary *patientDict = (NSDictionary*)dict[@"patient"];
                    pID = [patientDict objectForKey:@"pID"];
                    pName = [patientDict objectForKey:@"pName"];
                }
                TempPatient *tempPatient = [[TempPatient alloc] initWithPatientID:NSDictionaryOfVariableBindings(pID,pName)];
                
                [patientArray addObject:tempPatient];
            }
        }
        successful(patientArray);
        
    } failConection:^(NSError *error) {
        fail(error);
    }];
}
- (void)reset
{
    for(int i = 0;i<[self.headViewArray count];i++)
    {
        HeadView *head = [self.headViewArray objectAtIndex:i];
        
        if(head.section == self.currentSection || head.open)
        {
            head.open = YES;
          
            
        }else {
            //[head.backBtn setBackgroundImage:[UIImage imageNamed:@"btn_momal"] forState:UIControlStateNormal];
            
            head.open = NO;
        }
        
    }
    [self.tableView reloadData];
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
