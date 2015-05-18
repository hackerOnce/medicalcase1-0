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

#pragma  mask - property
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kDidCompletedAsyncInitEntity) name:kDidCompletedAsyncInitEntity object:nil];
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


- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadModel];
    [self setUpTableView];
    // Do any additional setup after loading the view.
    [self addNotificationObserver];
    
    self.isFirstAppear = YES;
    
    
}
-(void)setUpTableView
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
//    _tableView.separatorColor = [UIColor clearColor];
//    _tableView.backgroundColor = [UIColor clearColor];
//    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.isFirstAppear) {
        [self kDidCompletedAsyncInitEntity];
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

    NSArray *tempA = self.dataDic[headView.backBtn.titleLabel.text];
    
    
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
        
        
//        UIImageView* line = [[UIImageView alloc]initWithFrame:CGRectMake(0, 44, 340, 1)];
//        line.backgroundColor = [UIColor grayColor];
//        [cell.contentView addSubview:line];
//        [line release];
        
    }
    UIButton* backBtn = (UIButton*)[cell.contentView viewWithTag:20000];
    HeadView* view = [self.headViewArray objectAtIndex:indexPath.section];
    //[backBtn setBackgroundImage:[UIImage imageNamed:@"btn_2_nomal"] forState:UIControlStateNormal];
    
    if (view.open) {
        if (indexPath.row == _currentRow) {
           // [backBtn setBackgroundImage:[UIImage imageNamed:@"btn_nomal"] forState:UIControlStateNormal];
        }
    }
    
    NSArray *tempA = self.dataDic[view.backBtn.titleLabel.text];
    Patient *patient = (Patient*)tempA[indexPath.row];
    cell.textLabel.text = patient.pName;
    //cell.textLabel.backgroundColor = [UIColor clearColor];
    //cell.textLabel.textColor = [UIColor whiteColor];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    HeadView* view = [self.headViewArray objectAtIndex:indexPath.section];

    if (view.open) {
        _currentRow = indexPath.row;
        [_tableView reloadData];
    }
    NSArray *tempA = self.dataDic[view.backBtn.titleLabel.text];
    Patient *patient = (Patient*)tempA[indexPath.row];
    [self.delegate didSelectedPatient:patient];
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
