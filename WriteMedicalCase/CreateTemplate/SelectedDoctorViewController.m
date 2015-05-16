//
//  SelectedDoctorViewController.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/14.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "SelectedDoctorViewController.h"
#import "HeadView.h"

@interface SelectedDoctorViewController ()<HeadViewDelegate,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) NSMutableArray *headViewArray;

@property (nonatomic) NSInteger currentRow;
@property (nonatomic) NSInteger currentSection;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftLabelWidthConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightLabelWidthConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *countLabelWidthCOnstraints;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic,strong) NSMutableArray *classficationArray;

@property (nonatomic,strong) NSMutableDictionary *dataDic;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UILabel *leftLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UIView *subContainerView;

@property (nonatomic,strong) NSMutableArray *selectedArray;
@property (nonatomic,strong) NSMutableOrderedSet *orderSet;
@end

@implementation SelectedDoctorViewController
- (IBAction)confirm:(UIButton *)sender
{
    for (NSIndexPath *inde in [self.tableView indexPathsForSelectedRows]) {
        NSLog(@" %@ - %@",@(inde.section),@(inde.row));
    }
}
- (IBAction)cancelButton:(UIBarButtonItem *)sender {
    
    self.orderSet = nil;
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.preferredContentSize = CGSizeMake(300, 300);
    
    [self.tableView setEditing:YES animated:NO];
    
    [self loadModel];

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
#pragma mask - property
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
        
        NSArray *testArray = @[@"高宗明",@"陈家豪",@"沈家桢"];
        for (NSString *tempS in self.classficationArray) {
            [_dataDic setObject:testArray forKey:tempS];
        }
    }
    return _dataDic;
}
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
    for(int i = 0;i< self.classficationArray.count ;i++)
    {
        HeadView* headview = [[HeadView alloc] init];
        headview.delegate = self;
        headview.section = i;
        [headview.backBtn setTitle:[self.classficationArray objectAtIndex:i] forState:UIControlStateNormal];
        if (i==0) {
            headview.open = YES;
        }else {
            headview.open = NO;
        }
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
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert ;
}


- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    HeadView *headView = [self.headViewArray objectAtIndex:section];
    return headView;
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
    static NSString *indentifier = @"DoctorCell";
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
   // UIButton* backBtn = (UIButton*)[cell.contentView viewWithTag:20000];
    HeadView* view = [self.headViewArray objectAtIndex:indexPath.section];
//    CGRect viewFrame = view.frame;
//    view.frame = viewFrame;
    
    
    if (view.open) {
        if (indexPath.row == _currentRow) {
            
        }
    }
    NSArray *tempA = self.dataDic[view.backBtn.titleLabel.text];
    NSString *doctorName = (NSString*)tempA[indexPath.row];
    cell.textLabel.text = doctorName;
    
    return cell;
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
//        self.rightLabel.textColor = defaultColor;
//        self.leftLabel.textColor = defaultColor;
//        self.countLabel.textColor = defaultColor;
//        

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
   // [self.orderSet removeAllObjects];
    
    if (view.open) {
        view.open = NO;
        [self.orderSet addObjectsFromArray:[self.tableView indexPathsForSelectedRows]];

        NSIndexSet *indexSet=[NSIndexSet indexSetWithIndex:view.section];
        [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
        return;
    }else {
        view.open = YES;

        NSIndexSet *indexSet=[NSIndexSet indexSetWithIndex:view.section];
        [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    _currentSection = view.section;
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
