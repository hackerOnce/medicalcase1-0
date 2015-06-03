//
//  ReordNoteCreateViewController.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/6/1.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "ReordNoteCreateViewController.h"
#import "RecordNoteCreateCellTableViewCell.h"
#import "RecordNoteWarningViewController.h"

@interface ReordNoteCreateViewController ()<UINavigationControllerDelegate,RecordNoteCreateCellTableViewCellDelegate,RecordNoteWarningViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) CGFloat keyboardOverlap;
@property (nonatomic,strong) UITextView *currentTextView;
@property (nonatomic,strong) NSIndexPath *currentIndexPath;
@property (nonatomic) BOOL keyboardShow;

@property (nonatomic,strong) NSString *noteContent;
@property (nonatomic,strong) NSString *noteType;
@end

@implementation ReordNoteCreateViewController

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
   // NSIndexPath *indexPath = [[self tableView] indexPathForCell:cell];
    self.noteContent = text;
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
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"noteCreateCell";
    RecordNoteCreateCellTableViewCell *tableViewCell =(RecordNoteCreateCellTableViewCell*) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    tableViewCell.delegate = self;
    [self configCell:tableViewCell atIndexPath:indexPath];
    return tableViewCell;
}
-(void)configCell:(RecordNoteCreateCellTableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UITextView *textView = (UITextView*)[cell viewWithTag:1002];
    textView.text = self.noteContent;
    
    UITextField *placeHolder =(UITextField*)[cell viewWithTag:1001];
    NSString *placeHolderString = @"请输入内容";
    placeHolder.placeholder = placeHolderString;
    
    textView.text = self.noteContent;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
#pragma mask - warning delegate
-(void)didSelectedDateString:(NSDictionary *)dict
{
    
}
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"originalWarningSegue"]) {
        
        RecordNoteWarningViewController *recordWarningVC =(RecordNoteWarningViewController*) [self expectedViewController:segue.destinationViewController];
        recordWarningVC.delegate = self;
    }
}


#pragma mask - property 
-(NSString *)noteContent
{
    if (!_noteContent) {
        _noteContent = @"";
    }
    return _noteContent;
}
-(NSString *)noteType
{
    if (!_noteType) {
       _noteType = @"0";
    }
    return _noteType;
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

@end
