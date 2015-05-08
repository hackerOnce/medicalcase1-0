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
@end

@implementation RecordManagedViewController

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
        [_classficationArray addObject:@"未提交"];
        [_classficationArray addObject:@"未完整创建"];
        [_classficationArray addObject:@"已提交未审核"];
        [_classficationArray addObject:@"已审核"];
        [_classficationArray addObject:@"撤回"];
    }
    return _classficationArray;
}
-(NSMutableDictionary *)dataDic
{
    if (!_dataDic) {
        _dataDic = [[NSMutableDictionary alloc] init];
        
      //  NSArray *testArray = @[@"入院记录",@"日常病程记录",@"上级医师查房记录"];
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
    //    _tableView.separatorColor = [UIColor clearColor];
    //    _tableView.backgroundColor = [UIColor clearColor];
    //    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
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

-(void)didSelectedPatient:(Patient *)patient
{
    self.recordCases = [NSArray arrayWithArray:patient.medicalCases.array];
    for (int i=0; i< self.classficationArray.count; i++) {
        NSString *tempStr = self.classficationArray[i];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"caseState = %@",tempStr];
        NSArray *resultA = self.sumArray[i];
        resultA = [self.recordCases filteredArrayUsingPredicate:predicate];

        [self.dataDic setObject:resultA forKey:tempStr];
    }
    
    [self.tableView reloadData];
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
//    if (!cell) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indentifier];
////        UIButton* backBtn=  [[UIButton alloc]initWithFrame:CGRectMake(0, 0, cell.frame.size.width, 45)];
////        backBtn.tag = 20000;
////        //[backBtn setBackgroundImage:[UIImage imageNamed:@"btn_on"] forState:UIControlStateHighlighted];
////        backBtn.userInteractionEnabled = NO;
////        [backBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
////        [cell.contentView addSubview:backBtn];
//        
//        
//        //        UIImageView* line = [[UIImageView alloc]initWithFrame:CGRectMake(0, 44, 340, 1)];
//        //        line.backgroundColor = [UIColor grayColor];
//        //        [cell.contentView addSubview:line];
//        //        [line release];
//        
//    }
   // UIButton* backBtn = (UIButton*)[cell.contentView viewWithTag:20000];
    HeadView* view = [self.headViewArray objectAtIndex:indexPath.section];
    //[backBtn setBackgroundImage:[UIImage imageNamed:@"btn_2_nomal"] forState:UIControlStateNormal];
    
    if (view.open) {
        if (indexPath.row == _currentRow) {
            // [backBtn setBackgroundImage:[UIImage imageNamed:@"btn_nomal"] forState:UIControlStateNormal];
        }
    }
    
    
    ///config cell
    
    
    NSArray *tempA = self.dataDic[view.backBtn.titleLabel.text];
    
    RecordBaseInfo *rec = (RecordBaseInfo*)tempA[indexPath.row];
    
    if (rec.createdTime && rec.lastModifyTime) {
        cell.remainTimeLabel.text = [self timeIntervalBetweenTimes:rec.createdTime date2:rec.lastModifyTime];
    }
    
    cell.caseTypeLabel.text = rec.caseType;
    [cell.cellButton setTitle:@"编辑" forState:UIControlStateNormal];
   // cell.textLabel.text = tempA[indexPath.row];
    //cell.textLabel.backgroundColor = [UIColor clearColor];
    //cell.textLabel.textColor = [UIColor whiteColor];
    
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
