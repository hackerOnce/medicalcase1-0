//
//  RecordNoteCreateForCaseViewController.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/6/1.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "RecordNoteCreateForCaseViewController.h"
#import "RecordNoteCreateCellTableViewCell.h"
#import "RecordNoteWarningViewController.h"

@interface RecordNoteCreateForCaseViewController ()<RecordNoteCreateCellTableViewCellDelegate,UITableViewDataSource,UITableViewDelegate,RecordNoteWarningViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) NSMutableDictionary *dataSourceDict;
@property (nonatomic,strong) NSArray *keyArray;

@property (nonatomic) CGFloat keyboardOverlap;
@property (nonatomic,strong) UITextView *currentTextView;
@property (nonatomic,strong) NSIndexPath *currentIndexPath;
@property (nonatomic) BOOL keyboardShow;

@property (nonatomic,strong) NSString *noteType;

@end

@implementation RecordNoteCreateForCaseViewController

#pragma mask - view controller life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpTableView];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self addKeyboardObserver];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)addKeyboardObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
-(void)setUpTableView
{
    self.tableView.estimatedRowHeight = 1000;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
}

-(void)keyboardWillShow:(NSNotification*)notificationInfo
{
    if (self.keyboardShow) {
        return;
    }
    self.keyboardShow = YES;
    // Get the keyboard size
    UIScrollView *tableView;
    if([self.tableView.superview isKindOfClass:[UIScrollView class]])
        tableView = (UIScrollView *)self.tableView.superview;
    else
        tableView = self.tableView;
    
    NSDictionary *userInfo = [notificationInfo userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    //[self.delegate keyboardShow:[aValue CGRectValue].size.height];
    CGRect keyboardRect = [tableView.superview convertRect:[aValue CGRectValue] fromView:nil];
    
    
    // [self.delegate keyboardShow:keyboardRect.size.height];
    // Get the keyboard's animation details
    NSTimeInterval animationDuration;
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    UIViewAnimationCurve animationCurve;
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    
    // Determine how much overlap exists between tableView and the keyboard
    CGRect tableFrame = tableView.frame;
    CGFloat tableLowerYCoord = tableFrame.origin.y + tableFrame.size.height;
    self.keyboardOverlap = tableLowerYCoord - keyboardRect.origin.y;
    if(self.currentTextView && self.keyboardOverlap>0)
    {
        CGFloat accessoryHeight = self.currentTextView.frame.size.height;
        self.keyboardOverlap -= accessoryHeight;
        
        tableView.contentInset = UIEdgeInsetsMake(0, 0, accessoryHeight, 0);
        tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, accessoryHeight, 0);
    }
    
    if(self.keyboardOverlap < 0)
        self.keyboardOverlap = 0;
    
    if(self.keyboardOverlap != 0)
    {
        tableFrame.size.height -= self.keyboardOverlap;
        
        NSTimeInterval delay = 0;
        if(keyboardRect.size.height)
        {
            delay = (1 - self.keyboardOverlap/keyboardRect.size.height)*animationDuration;
            animationDuration = animationDuration * self.keyboardOverlap/keyboardRect.size.height;
        }
        
        [UIView animateWithDuration:animationDuration delay:delay
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{ tableView.frame = tableFrame; }
                         completion:^(BOOL finished){ [self tableAnimationEnded:nil finished:nil contextInfo:nil]; }];
    }
    
}
-(void)keyboardWillHide:(NSNotification*)notificationInfo
{
    if (!self.keyboardShow) {
        return;
    }
    self.keyboardShow = NO;
    
    UIScrollView *tableView;
    if([self.tableView.superview isKindOfClass:[UIScrollView class]])
        tableView = (UIScrollView *)self.tableView.superview;
    else
        tableView = self.tableView;
    if(self.currentTextView)
    {
        tableView.contentInset = UIEdgeInsetsZero;
        tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
    }
    
    if(self.keyboardOverlap == 0)
        return;
    
    // Get the size & animation details of the keyboard
    NSDictionary *userInfo = [notificationInfo userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [tableView.superview convertRect:[aValue CGRectValue] fromView:nil];
    
    NSTimeInterval animationDuration;
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    UIViewAnimationCurve animationCurve;
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    
    CGRect tableFrame = tableView.frame;
    tableFrame.size.height += self.keyboardOverlap;
    
    if(keyboardRect.size.height)
        animationDuration = animationDuration * self.keyboardOverlap/keyboardRect.size.height;
    
    [UIView animateWithDuration:animationDuration delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{ tableView.frame = tableFrame; }
                     completion:^(BOOL finished){ [self tableAnimationEnded:nil finished:nil contextInfo:nil]; }];
    
    
}
- (void) tableAnimationEnded:(NSString*)animationID finished:(NSNumber *)finished contextInfo:(void *)context
{
    // Scroll to the active cell
    UITableView *tableView = self.tableView;
    if(self.currentIndexPath)
    {
        [tableView scrollToRowAtIndexPath:self.currentIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        [tableView selectRowAtIndexPath:self.currentIndexPath animated:NO scrollPosition:UITableViewScrollPositionBottom];
        
    }
}
#pragma mask - cell delegate
-(void)textViewCell:(RecordNoteCreateCellTableViewCell *)cell didChangeText:(NSString *)text
{
    NSIndexPath *indexPath = [[self tableView] indexPathForCell:cell];
    NSString *keyString = [self.keyArray objectAtIndex:indexPath.row];
    [self.dataSourceDict setObject:text forKey:keyString];
}
-(void)textViewDidBeginEditing:(UITextView *)textView withCellIndexPath:(NSIndexPath *)indexPath
{
    self.currentTextView = textView;
    self.currentIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
}
-(void)textViewShouldBeginEditing:(UITextView *)textView withCellIndexPath:(NSIndexPath *)indexPath
{
   
}
#pragma mask - table view delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   return self.dataSourceDict.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"noteCreatePatientCell";
    RecordNoteCreateCellTableViewCell *tableViewCell =(RecordNoteCreateCellTableViewCell*) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    tableViewCell.delegate = self;
    [self configCell:tableViewCell atIndexPath:indexPath];
    return tableViewCell;
}
-(void)configCell:(RecordNoteCreateCellTableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UITextView *textView = (UITextView*)[cell viewWithTag:1002];
    NSString *keyString = [self.keyArray objectAtIndex:indexPath.row];
    UITextField *placeHolder =(UITextField*)[cell viewWithTag:1001];
    NSString *placeHolderString =[self.keyArray objectAtIndex:indexPath.row];
    placeHolder.placeholder = placeHolderString;

    textView.text = StringValue([self.dataSourceDict objectForKey:keyString]);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 80;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect headerViewFrame = CGRectMake(0, 0, tableView.frame.size.width, tableView.frame.size.height);
    UIView *headerView = [[UIView alloc] initWithFrame:headerViewFrame];
    headerView.backgroundColor = [UIColor whiteColor];
    [self addSubViewToHeaderView:headerView];
    return headerView;
}
-(void)addSubViewToHeaderView:(UIView*)headerView
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 8, 0, 21)];
    titleLabel.text = @"新入院";
    [titleLabel sizeToFit];
    
    UITextField *subTitleField = [[UITextField alloc] initWithFrame:CGRectMake(titleLabel.frame.size.width+10, 8, headerView.frame.size.width - titleLabel.frame.size.width - 8 - 8, 21)];
    subTitleField.placeholder = @"输入子标题";
    subTitleField.font = [UIFont systemFontOfSize:15];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(8, 21+9, headerView.frame.size.width - 8, 1)];
    line.backgroundColor = [UIColor blueColor];
    
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, line.frame.origin.y+4, 20, 20)];
    dateLabel.textColor = [UIColor blueColor];
    dateLabel.text = @"2015年12月18号 11:37";
    dateLabel.font = [UIFont systemFontOfSize:14];
    [dateLabel sizeToFit];
    
    [headerView addSubview:titleLabel];
    [headerView addSubview:subTitleField];
    [headerView addSubview:line];
    [headerView addSubview:dateLabel];
}

#pragma mask - warning delegate
-(void)didSelectedDateString:(NSDictionary *)dict
{
    
}
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"patientWarningSegue"]) {
        
        RecordNoteWarningViewController *recordWarningVC =(RecordNoteWarningViewController*) [self expectedViewController:segue.destinationViewController];
        recordWarningVC.delegate = self;
    }
}
-(UIViewController*)expectedViewController:(UIViewController*)viewController
{
    UIViewController *expectedViewController = viewController;
    if ([expectedViewController isMemberOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController*)viewController;
        expectedViewController =(UIViewController*) [nav.viewControllers firstObject];
    }
    return expectedViewController;
}
#pragma mask - property
-(NSArray *)keyArray
{
    if (!_keyArray) {
        _keyArray = @[@"主观性资料",@"客观性资料",@"评估",@"治疗方案"];
    }
    return _keyArray;
}
-(NSMutableDictionary *)dataSourceDict
{
    if (!_dataSourceDict) {
        _dataSourceDict = [[NSMutableDictionary alloc] init];
        for (NSString *key in self.keyArray) {
            NSString *dataString = @"";
            [_dataSourceDict setObject:dataString forKey:key];
        }
    }
    return _dataSourceDict;
}
-(NSString *)noteType
{
    if (!_noteType) {
        _noteType = @"0";
    }
    return _noteType;
}
@end
