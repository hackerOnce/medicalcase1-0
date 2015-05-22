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
        
//        NSArray *testArray = @[@"高宗明",@"陈家豪",@"沈家桢"];
//        for (NSString *tempS in self.classficationArray) {
//            [_dataDic setObject:testArray forKey:tempS];
//        }
    }
    return _dataDic;
}
-(void)addNotificationObserver
{
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kDidCompletedAsyncInitEntity) name:kDidCompletedAsyncInitEntity object:nil];
}
-(void)setRecords:(NSMutableArray *)records
{
    _records = records;
    
}
-(void)kDidCompletedAsyncInitEntity
{
//    NSArray *temp = [self.coreDataStack fetchDoctorEntityWithName:@"姓名" dID:nil];
//    if (temp.count == 0) {
//        NSLog(@"error");
//    }else {
//        Doctor *doctor =(Doctor*)[temp firstObject];
//        NSArray *temp = doctor.patients.array;
//        
//        NSMutableArray *a1 = [[NSMutableArray alloc] init];
//        NSMutableArray *a2 = [[NSMutableArray alloc] init];
//        
//        for (Patient *patient in temp) {
//            if ([patient.patientState isEqualToString:@"已出院"] ) {
//                [a2 addObject:patient];
//            }else {
//                [a1 addObject:patient];
//            }
//            NSLog(@"patient name: %@",patient);
//            
//            for (RecordBaseInfo *record in patient.medicalCases) {
//                RecordBaseInfo *rec = (RecordBaseInfo*)record;
//                NSLog(@"record : status %@,record type: %@,patient %@,doctor %@",rec.caseState,rec.caseType,patient.pName,patient.doctor.dName);
//            }
//        }
//        
//        for (NSString *tempStr in self.classficationArray) {
//            if ([tempStr isEqualToString:@"本次住院"]) {
//                [self.dataDic setObject:a1 forKey:tempStr];
//            }else {
//                [self.dataDic setObject:a2 forKey:tempStr];
//            }
//        }
//    }
//
//    
//    [self.tableView reloadData];


}
-(void)fetchRecordCase
{
    CurrentDoctor *currentDoctor = [CurrentDoctor currentDoctor];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dName = %@ and dID = %@ ",currentDoctor.dName,currentDoctor.dID];
    
//    [self.coreDataStack fetchManagedObjectInContext:self.managedObjectContext WithEntityName:[RecordBaseInfo entityName] withPredicate:predicate successfulFetched:^(NSArray *resultArray) {
//        
//        self.records = [NSMutableArray arrayWithArray:resultArray];
//        
//    } failedToFetched:^(NSError *error, NSString *errorInfo) {
//        
//    } ];
}

#pragma mask -view life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadModel];
    [self setUpTableView];
    // Do any additional setup after loading the view.
    [self addNotificationObserver];
    
    self.isFirstAppear = YES;
    
    [self getPatientDataByDoctorID:self.logInDoctorID];
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
       // [backBtn setBackgroundImage:[UIImage imageNamed:@"btn_on"] forState:UIControlStateHighlighted];
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

//    if (view.open) {
//        _currentRow = indexPath.row;
//        [_tableView reloadData];
//    }
//    
    NSArray *tempA = self.patientDic[view.backBtn.titleLabel.text];
    TempPatient *patient = (TempPatient*)tempA[indexPath.row];
    
    
//    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",patient.pID] forKey:@"pID"];
//    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",patient.pName] forKey:@"pName"];

    
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
        
        NSIndexSet *indexSet=[NSIndexSet indexSetWithIndex:view.section];
        [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
                _currentSection = view.section;
    }
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
