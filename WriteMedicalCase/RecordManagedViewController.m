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

@property (nonatomic,strong) RecordBaseInfo *didSelectedRecord;

@property (nonatomic,strong) IHMsgSocket *socket;

@property (nonatomic,strong) RecordBaseInfo *resultCaseInfo;

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
        [_classficationArray addObject:@"保存未提交"];
        [_classficationArray addObject:@"提交未审核"];
        [_classficationArray addObject:@"主治医师审核"];
        [_classficationArray addObject:@"（副）主任医师审核"];
        [_classficationArray addObject:@"撤回"];
    }
    return _classficationArray;
}
-(NSMutableDictionary *)dataDic
{
    if (!_dataDic) {
        _dataDic = [[NSMutableDictionary alloc] init];
        
        self.arry1 = [[NSMutableArray alloc] init];
        self.arry2 = [[NSMutableArray alloc] init];
        self.arry3 = [[NSMutableArray alloc] init];

        self.arry4 = [[NSMutableArray alloc] init];
        self.arry5 = [[NSMutableArray alloc] init];
        self.arry6 = [[NSMutableArray alloc] init];

        self.sumArray =[NSMutableArray arrayWithArray:@[self.arry1,self.arry2,self.arry3,self.arry4,self.arry5,self.arry6]];
        
        for (int i=0; i< self.classficationArray.count; i++) {
            NSString *tempStr = self.classficationArray[i];

            [_dataDic setObject:self.sumArray[i] forKey:tempStr];
            
            
        }
    }
    return _dataDic;
}
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

-(void)didSelectedPatient:(NSString *)patientID
{

    NSString *dID = [[NSUserDefaults standardUserDefaults] objectForKey:@"dID"];

    NSDictionary *dict = @{@"pid":patientID,@"did":dID};

    [MessageObject messageObjectWithUsrStr:@"1" pwdStr:@"test" iHMsgSocket:self.socket optInt:2014 dictionary:dict block:^(IHSockRequest *request) {
        
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        if (request.resp == -1) {
            TempRecord *tempRecord = [[TempRecord alloc] initWithDic:nil];
            tempRecord.caseType = @"入院病历";
            tempRecord.caseStatus = @"未创建";
            [tempArray addObject:tempRecord];
            
        }else {
            for (NSDictionary *tempDict in request.responseData) {
                TempRecord *tempRecord = [[TempRecord alloc] initWithDic:nil];

                if ([tempDict.allKeys containsObject:@"caseType"]) {
                    tempRecord.caseType = tempDict[@"caseType"];
                }
                if ([tempDict.allKeys containsObject:@"caseStatus"]) {
                    tempRecord.caseStatus = tempDict[@"caseStatus"];
                }
                [tempArray addObject:tempRecord];
            }
        }
        
        for (int i=0; i< self.classficationArray.count; i++) {
            NSString *tempStr = self.classficationArray[i];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"caseStatus = %@",tempStr];
            NSArray *resultA = self.sumArray[i];
            resultA = [tempArray filteredArrayUsingPredicate:predicate];
            
            [self.dataDic setObject:resultA forKey:tempStr];
        }
        
        [self.tableView reloadData];
        
        
        
        
    } failConection:^(NSError *error) {
        
    }];

    
    

//    NSDictionary *tempDict= @{@"0":@"保存未提交",@"1":@"提交未审核",@"2":@"主治医师审核",@"3":@"（副）主任医师审核",@"4":@"主治医师审核未通过",@"5":@"副主任医师审核通过",@"6":@"副主任医师审核未通过",@"7":@"归档"   ,@"8":@"撤回"};
    
 // self.recordCases = [NSArray arrayWithArray:patient.medicalCases.array];
    
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
    TempRecord *record = tempArray[indexPath.row];
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
    
    if (view.open) {
        _currentRow = indexPath.row;
        [_tableView reloadData];
    }
    
    RecordManagedCellTableViewCell *cell = (RecordManagedCellTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];

    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"WriteCaseStoryboard" bundle:nil];
    UINavigationController *nav = [storyBoard instantiateViewControllerWithIdentifier:@"writeNav"];
    
    WriteCaseSaveViewController *saveVC = (WriteCaseSaveViewController*)[nav.viewControllers firstObject];
    
    saveVC.currentDoctor = [CurrentDoctor currentDoctor];
    saveVC.currentPatient = [[CurrentPatient alloc] init];
    saveVC.isRemoveLeftButton = YES;
    saveVC.caseType = cell.caseTypeLabel.text;
    
    [self.navigationController pushViewController:saveVC animated:YES];
    
    
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

#pragma mask - cell delegate
-(void)didSelectedCellButton:(UIButton *)button inCell:(RecordManagedCellTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    HeadView* view = [self.headViewArray objectAtIndex:indexPath.section];
    NSArray *tempA = self.dataDic[view.backBtn.titleLabel.text];
    
    self.didSelectedRecord = (RecordBaseInfo*)tempA[indexPath.row];

    [self performSegueWithIdentifier:@"EditCaseSegue" sender:nil];
}
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    if ([segue.identifier isEqualToString:@"EditCaseSegue"]) {
//        
//        UINavigationController *nav = (UINavigationController*)segue.destinationViewController;
//        
//       // AdmissionRecordsViewController *writeVC = (AdmissionRecordsViewController*)[nav.viewControllers firstObject];
//        writeVC.recordCase = self.didSelectedRecord;
//    }
}


@end
