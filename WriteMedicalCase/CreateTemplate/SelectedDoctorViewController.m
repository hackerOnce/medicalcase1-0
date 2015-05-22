//
//  SelectedDoctorViewController.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/14.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "SelectedDoctorViewController.h"
#import "HeadView.h"
#import "Department.h"

@interface SelectedDoctorViewController ()<HeadViewDelegate,UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>
@property (nonatomic,strong) NSMutableArray *headViewArray;

@property (nonatomic) NSInteger currentRow;
@property (nonatomic) NSInteger currentSection;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftLabelWidthConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightLabelWidthConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *countLabelWidthCOnstraints;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UILabel *leftLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UIView *subContainerView;

@property (nonatomic,strong) NSMutableArray *selectedArray;
@property (nonatomic,strong) NSMutableOrderedSet *orderSet;

@property (nonatomic,strong) IHMsgSocket *socket;

@property (nonatomic,strong) NSMutableArray *departments;
@property (nonatomic,strong) NSMutableDictionary *doctorsDict;

@property (nonatomic) BOOL isOnlySelectedDepartment;
@end

@implementation SelectedDoctorViewController
- (IBAction)confirm:(UIButton *)sender
{
    for (NSIndexPath *inde in [self.tableView indexPathsForSelectedRows]) {
        NSLog(@" %@ - %@",@(inde.section),@(inde.row));
    }
    
    NSMutableArray *sharedUsers = [[NSMutableArray alloc] init];
    
    if(self.isOnlySelectedDepartment){
        for (NSIndexPath *indexPath in [self.tableView indexPathsForSelectedRows]) {
            Department *department = [self.departments objectAtIndex:indexPath.row];
            [sharedUsers addObject:department.departmentID];
        }
    }else {
        
        for (NSIndexPath *indexPath in [self.tableView indexPathsForSelectedRows]) {
            HeadView* headView = [self.headViewArray objectAtIndex:indexPath.section];
            
            NSArray *tempA = [self.doctorsDict objectForKey:headView.backBtn.titleLabel.text];
            Doctor *doctor = [tempA objectAtIndex:indexPath.row];
            [sharedUsers addObject:doctor.dID];
        }
    }
    
    
    NSString *doctorID = [[NSUserDefaults standardUserDefaults] objectForKey:@"dID"];
    NSString *sharedStyle = [self refrenceStyleWith:self.selectedSharedStyle];
    TemplateModel *template =[[TemplateModel alloc] initWithTemplate:(TemplateModel*)[self.selectedTemplates firstObject]];
    
    NSLog(@"%@",template.content);
    [MessageObject messageObjectWithUsrStr:@"2225" pwdStr:@"test" iHMsgSocket:self.socket optInt:2005 dictionary:@{@"did":doctorID,@"uid":sharedUsers,@"style":@([sharedStyle integerValue]),@"id":template.templateID} block:^(IHSockRequest *request) {
        NSInteger count = request.resp;
        
        switch (count) {
            case 0:{
                //成功
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"成功分享模板" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                });
                break;
            }
            case -1:{
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"没有分享权限" message:nil delegate:nil cancelButtonTitle:@"OK"otherButtonTitles:nil];
                    [alert show];
                });
                break;
            }
            case -2:{
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"模板不存在" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                });
                break;
            }
            default:
                break;
        }
    } failConection:^(NSError *error) {
        
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShouldEndShareTemplate" object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)cancelButton:(UIBarButtonItem *)sender {
    
    self.orderSet = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setSelectedSharedStyle:(NSString *)selectedSharedStyle
{
    _selectedSharedStyle = selectedSharedStyle;
    if ([_selectedSharedStyle isEqualToString:@"科室分享"]){
        self.isOnlySelectedDepartment = YES;
    }else {
        self.isOnlySelectedDepartment = NO;
    }
    
    [self loadDataFromServer];

}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.preferredContentSize = CGSizeMake(300, 300);
    
    [self.tableView setEditing:YES animated:NO];
    

}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
     self.orderSet = nil;

}
-(void)setUpTableView
{
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
}

-(IHMsgSocket *)socket
{
    if (!_socket) {
        _socket = [IHMsgSocket sharedRequest];
        [_socket connectToHost:@"192.168.10.106" onPort:2323];
    }
    return _socket;
}
-(NSMutableArray *)departments
{
    if (!_departments) {
        _departments = [[NSMutableArray alloc] init];
    }
    return _departments;
}
-(NSMutableDictionary *)doctorsDict
{
    if (!_doctorsDict) {
        _doctorsDict = [[NSMutableDictionary alloc] init];
        
        for (Department *department in self.departments) {
            [_doctorsDict setObject:@"" forKey:department.departmentName];
           // [_doctorsDict setObject:@"" forKey:department.departmentID];

        }
    }
    return _doctorsDict;
}
-(void)loadDataFromServer
{
    [MessageObject messageObjectWithUsrStr:@"1" pwdStr:@"test" iHMsgSocket:self.socket optInt:2010 dictionary:@{} block:^(IHSockRequest *request) {
        
        if ([request.responseData isKindOfClass:[NSArray class]]) {
            NSArray *tempArray = (NSArray*)request.responseData;
            
            for (NSDictionary *tempDict in tempArray) {
                Department *department = [[Department alloc] initWithDepartmentDict:tempDict];
                [self.departments addObject:department];
            }
            
            if (self.isOnlySelectedDepartment) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.tableView reloadData];
                    
                });
            }else {
                [self loadModel];
                
                Department *firstDepartment = [self.departments firstObject];
                
                [self doctorsFromServerWithDepartmentID:firstDepartment sucessLoad:^(NSArray *resultArray) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self.doctorsDict setObject:resultArray forKey:firstDepartment.departmentName];
                        [self.tableView reloadData];
                        
                    });
                    
                } failConection:^(NSError *error) {
                    
                }];
            }
            
        }
        
    } failConection:^(NSError *error) {
        
    }];
}
-(void)doctorsFromServerWithDepartmentID:(Department*)department sucessLoad:(void (^)(NSArray *resultArray))successful failConection:(void (^)(NSError *))fail
{
    NSString *departmentID = department.departmentID;
    [MessageObject messageObjectWithUsrStr:@"11" pwdStr:@"test" iHMsgSocket:self.socket optInt:2011 dictionary:@{@"ks_id":departmentID} block:^(IHSockRequest *request) {
        
        NSMutableArray *doctorArray = [[NSMutableArray alloc] init];
        
        if([request.responseData isKindOfClass:[NSArray class]]){
            NSArray *tempArray = (NSArray*)request.responseData;
            for (NSDictionary *dict in tempArray) {
                TempDoctor *doctor = [[TempDoctor alloc] initWithTempDoctorDic:dict];
                [doctorArray addObject:doctor];
            }
        }
        successful(doctorArray);
       
    } failConection:^(NSError *error) {
        
    }];
}
#pragma mask - property
-(NSMutableArray *)selectedArray
{
    if (!_selectedArray) {
        _selectedArray = [[NSMutableArray alloc] init];
    }
    return _selectedArray;
}
-(NSMutableOrderedSet *)orderSet
{
    if (!_orderSet) {
        _orderSet = [[NSMutableOrderedSet alloc] init];
    }
    
    return _orderSet;
}
-(void)loadModel
{
    _currentRow = -1;
    self.headViewArray = [[NSMutableArray alloc]init ];
    for(int i = 0;i< self.departments.count ;i++)
    {
        HeadView* headview = [[HeadView alloc] init];
        headview.delegate = self;
        headview.section = i;
        Department *department = [self.departments objectAtIndex:i];
        [headview.backBtn setTitle:department.departmentName forState:UIControlStateNormal];
        
        if ([self.selectedSharedStyle isEqualToString:@"科室分享"]) {
            headview.open = NO;
           // headview.backBtn.enabled = NO;
        }else {
            if (i==0) {
                headview.open = YES;
            }else {
                headview.open = NO;
            }
        }
        [self.headViewArray addObject:headview];
    }
}
-(NSString*)refrenceStyleWith:(NSString*)selectedString
{
    NSDictionary *dict = @{@"个人分享":@"1",@"科室分享":@"2",@"全院分享":@"3"};
    return [dict objectForKey:selectedString];
}


#pragma mark - TableViewdelegate&&TableViewdataSource

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.isOnlySelectedDepartment) {
        return 45;
    }else {
        HeadView* headView = [self.headViewArray objectAtIndex:indexPath.section];
        
        return headView.open?45:0;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.isOnlySelectedDepartment) {
        return 0.1;
    }else {
        return 45;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert ;
}


- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if (self.isOnlySelectedDepartment) {
        return nil;
    }else {
        HeadView *headView = [self.headViewArray objectAtIndex:section];
        return headView;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.isOnlySelectedDepartment) {
        
        return self.departments.count;
    }else {
        HeadView* headView = [self.headViewArray objectAtIndex:section];
        
        NSArray *tempA = [self.doctorsDict objectForKey:headView.backBtn.titleLabel.text];
        
        return headView.open?tempA.count:0;

    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.isOnlySelectedDepartment) {
        return 1;
    }else {
        return [self.headViewArray count];
    }
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    if (!cell) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indentifier];
//        UIButton* backBtn=  [[UIButton alloc]initWithFrame:CGRectMake(0, 0, cell.frame.size.width, 45)];
//        backBtn.tag = 20000;
//       
//        backBtn.userInteractionEnabled = NO;
//        [backBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
//        [cell.contentView addSubview:backBtn];
//    }
 
    if (self.isOnlySelectedDepartment) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"departmentCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"departmentCell"];
        }
        Department *department = (Department*)self.departments[indexPath.row];

        cell.textLabel.text = department.departmentName;
        
        return cell;

    }else {
        
        static NSString *indentifier = @"DoctorCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
        HeadView* view = [self.headViewArray objectAtIndex:indexPath.section];
        
        if (view.open) {
            if (indexPath.row == _currentRow) {
                
            }
        }
        // NSArray *tempA = self.dataDic[view.backBtn.titleLabel.text];
        NSArray *tempA = [self.doctorsDict objectForKey:view.backBtn.titleLabel.text];
        
        Doctor *doctor = (Doctor*)tempA[indexPath.row];
        
        cell.textLabel.text = doctor.dName;
        
        return cell;
    }
   
    
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.orderSet containsObject:indexPath]) {
        [self.orderSet removeObject:indexPath];

    }else {
    }
    [self setLabelColor];

}
-(void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.orderSet containsObject:indexPath]) {
        [self.orderSet removeObject:indexPath];
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [self setLabelColor];

}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.orderSet containsObject:indexPath]) {
        [cell setSelected:YES];
    }
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.orderSet containsObject:indexPath]) {
        
    }else {
        [self.orderSet addObject:indexPath];
    }
    
    [self setLabelColor];
    
}
-(void)setLabelColor
{
    NSInteger count = self.orderSet.count;
    UIColor *selectedColor = [UIColor greenColor];
    UIColor *defaultColor = [UIColor colorWithRed:74/255.0 green:171.0/255 blue:247.0/255 alpha:1];
    if (count == 0) {
        
        [self.confirmButton setTitleColor:defaultColor forState:UIControlStateNormal];
        self.rightLabelWidthConstraints.constant = 0;
        self.leftLabelWidthConstraints.constant  = 6;
        self.countLabelWidthCOnstraints.constant = 0;
        self.countLabel.hidden = YES;
        [self.subContainerView setNeedsUpdateConstraints];
    }else {
        [self.confirmButton setTitleColor:selectedColor forState:UIControlStateNormal];
        self.rightLabel.textColor = selectedColor;
        self.leftLabel.textColor = selectedColor;
        self.countLabel.textColor = selectedColor;
        self.countLabel.text =[NSString stringWithFormat:@"%@",@(count)];
        self.countLabel.hidden = NO;
        self.rightLabelWidthConstraints.constant = 17;
        self.leftLabelWidthConstraints.constant  = 17;
        self.countLabelWidthCOnstraints.constant = 10;

        [self.subContainerView setNeedsUpdateConstraints];

    }

}
#pragma mark - HeadViewdelegate
-(void)selectedWith:(HeadView *)view{
    self.currentRow = -1;
    
    if (view.open) {
        view.open = NO;
        [self.orderSet addObjectsFromArray:[self.tableView indexPathsForSelectedRows]];

        NSIndexSet *indexSet=[NSIndexSet indexSetWithIndex:view.section];
        [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
        return;
    }else {
        view.open = YES;

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"departmentName=%@",view.backBtn.titleLabel.text];
        NSArray *departments = [self.departments filteredArrayUsingPredicate:predicate];
        Department *department =(Department*)[departments firstObject];
        [self doctorsFromServerWithDepartmentID:department sucessLoad:^(NSArray *resultArray) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.doctorsDict setObject:resultArray forKey:department.departmentName];
                NSIndexSet *indexSet=[NSIndexSet indexSetWithIndex:view.section];
                [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
                _currentSection = view.section;

            });
            
        } failConection:^(NSError *error) {
            
        }];
    }
  //  [self reset];
    
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
//     [self.tableView reloadRowsAtIndexPaths:self.orderSet.array withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView reloadData];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}


@end
