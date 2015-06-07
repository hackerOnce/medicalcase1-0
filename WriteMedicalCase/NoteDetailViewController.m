//
//  NoteDetailViewController.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/6/5.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "NoteDetailViewController.h"
#import "RecordNoteCreateCellTableViewCell.h"
#import "RecordNoteWarningViewController.h"
#import "SelectedShareRangeViewController.h"
#import "CaseContent.h"
#import "NoteShowViewController.h"
#import "TakePhotoViewController.h"
#import "ContainerViewCell.h"

@interface NoteDetailViewController ()<RecordNoteCreateCellTableViewCellDelegate,RecordNoteWarningViewControllerDelegate,SelectedShareRangeViewControllerDelegate,NoteShowViewControllerDelegate,UITextFieldDelegate,TakePhotoViewControllerDelegate
>
@property (nonatomic) CGFloat keyboardOverlap;
@property (nonatomic,strong) UITextView *currentTextView;
@property (nonatomic,strong) NSIndexPath *currentIndexPath;
@property (nonatomic) BOOL keyboardShow;

@property (nonatomic,strong) NSString *noteContent;
@property (nonatomic,strong) NSString *noteType;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) UITextField *titeTextField;
@property (nonatomic,strong) UILabel *titleLabel;
//prepare for save note
@property (nonatomic,strong) NSDictionary *sharedUser;
@property (nonatomic,strong) NSDictionary *warningDict;

@property (nonatomic,strong) IHMsgSocket *socket;

@property (nonatomic,strong) CoreDataStack *coreDataStack;
@property (nonatomic) NoteBook *note;

@property (nonatomic,strong) NSArray *keyArray;

@property (nonatomic,strong) NSMutableDictionary *mediaDict;
@property (nonatomic,strong) NSMutableArray *mediasArray;

@end

@implementation NoteDetailViewController

#pragma mask - core data stack
-(CoreDataStack *)coreDataStack
{
    _coreDataStack = [[CoreDataStack alloc] init];
    return _coreDataStack;
}
- (IBAction)sharedButton:(UIButton *)sender
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"CreateTemplateStoryboard" bundle:nil];
    
    UINavigationController *shareRangeVC = [storyBoard instantiateViewControllerWithIdentifier:@"SelectedShareRangeNav"];
    SelectedShareRangeViewController *rangeVC = (SelectedShareRangeViewController*)[shareRangeVC.viewControllers firstObject];
    rangeVC.isForOthers = YES;
    rangeVC.delegate = self;
    
    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:shareRangeVC];
    
    UIBarButtonItem *barButtonItem =[[UIBarButtonItem alloc] initWithCustomView:sender];
    [popover presentPopoverFromBarButtonItem:barButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}
- (IBAction)save:(UIButton *)sender
{
    TempDoctor *doctor = [TempDoctor setSharedDoctorWithDict:nil];
    if ([StringValue(self.noteContent) isEqualToString:@""] ) {
        //笔记内容不允许为空
        return;
    }
    
    NSDictionary *dict = [NSDictionary dictionaryWithDictionary:[self prepareForSave]];
    
    
    [MessageObject messageObjectWithUsrStr:doctor.dID pwdStr:@"test"iHMsgSocket:self.socket optInt:1509 sync_version:1.0 dictionary:dict block:^(IHSockRequest *request) {
        
    } failConection:^(NSError *error) {
        
    }];
}
- (IBAction)cancel:(UIBarButtonItem *)sender
{
    
}

-(NSDictionary*)prepareForSave
{
    //doctor
    TempDoctor *doctor = [TempDoctor setSharedDoctorWithDict:nil];
    NSString *dID = StringValue(doctor.dID);
    NSString *dName = StringValue(doctor.dName);
    NSString *dProfessionalTitle= StringValue(doctor.dProfessionalTitle);
    NSString *dept = StringValue(doctor.dept);
    NSString *medicalTeam = StringValue(doctor.medicalTeam);
    
    NSString *sharedType;
    NSArray *sharedUser = @[];
    NSArray *sharedDept = @[];
    if (self.sharedUser.count == 0) {
        sharedType = @"";
        sharedUser = @[];
    }else {
        sharedType = [self.sharedUser objectForKey:@"sharedType"];
        if ([sharedType integerValue]) {
            sharedDept = [NSArray arrayWithArray:[self.sharedUser objectForKey:@"sharedUser"]];
        }else {
            sharedUser = [NSArray arrayWithArray:[self.sharedUser objectForKey:@"sharedUser"]];
        }
    }
    
    NSString *commit;
    NSString *detailInfoText;
    NSString *warningDate;
    if (self.warningDict) {
        commit = [self.warningDict objectForKey:@"commit"];
        detailInfoText = [self.warningDict objectForKey:@"detailInfoText"];
        warningDate = [self.warningDict objectForKey:@"warningDate"];
    }else {
        commit = @"";
        detailInfoText=@"";
        warningDate = @"";
    }
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:dID forKey:@"ih_doctor_id"];
    [dict setObject:dName forKey:@"ih_doctor_nam"];
    [dict setObject:dProfessionalTitle forKey:@"ih_doctor_pro"];
    [dict setObject:dept forKey:@"ih_doctor_dept"];
    [dict setObject:medicalTeam forKey:@"ih_doctor_med"];
    
    [dict setObject:sharedType forKey:@"ih_sharedtyp"];
    [dict setObject:sharedUser forKey:@"ih_sharedusr"];
    
    [dict setObject:warningDate forKey:@"ih_alert_time"];
    [dict setObject:detailInfoText forKey:@"ih_alert_cont"];
    [dict setObject:commit forKey:@"ih_alert_com"];
    
    [dict setObject:dID forKey:@"ih_alert_usr"];
    
    [dict setObject:self.noteType forKey:@"ih_note_type"];
    
    //NSDictionary *noteContentDict = @{@"ih_note_text":self.noteContent,@"audio":@"",@"images":@""};
    //[dict setObject:noteContentDict forKey:@"ih_contents"];
    [dict setObject:@"" forKey:@"ih_contento"];
    [dict setObject:@"" forKey:@"ih_contenta"];
    [dict setObject:@"" forKey:@"ih_contentp"];
    
    return dict;
}
#pragma mask - note show view controller delegate
-(void)didSelectedANoteWithNoteID:(NSString *)noteID andCreateDoctorID:(NSString *)dID
{
    self.note = [self.coreDataStack noteBookFetchWithDict:@{@"noteUUID":noteID,@"dID":dID}];
    for (NoteContent *content in self.note.contents) {
        NSLog(@"contentType: %@",content.contentType);
        NSLog(@"contentType: %@",content.updatedContent);

    }
    NSLog(@"note UUID:%@",self.note.noteUUID);
    [self prepareForShowNoteMedia];
    [self.tableView reloadData];
}
-(void)prepareForShowNoteMedia
{
    self.mediasArray = nil;
    self.mediaDict = nil;
    
    for (NoteContent *noteContent in self.note.contents) {
        for (MediaData *media in noteContent.medias) {
            [self.mediasArray addObject:media];
        }
    }
    if (self.mediasArray.count == 0) {
        
    }else {
      [self.mediaDict setObject:self.mediasArray forKey:@"medias"];
    }
}
#pragma mask - take photo view controller delegate
-(void)didSelectedImage:(UIImage *)image withImageData:(NSData *)imageData atIndexPath:(NSIndexPath *)indexPath
{
    NoteContent *noteContent = [self.note.contents objectAtIndex:indexPath.row];
    NSRange range = self.currentTextView.selectedRange;
    
    if (self.currentTextView.selectedTextRange) {
        
    }
    CGRect  textViewRect = [self.currentTextView caretRectForPosition:self.currentTextView.selectedTextRange.start];
    CGPoint cursorPosition = textViewRect.origin;
    
    //[self showMediaImage:imageData atLocation:cursorPosition];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self addMediaDataToNoteContent:noteContent withImage:image atLocation:range withPoint:cursorPosition];
    });
}
-(void)addMediaDataToNoteContent:(NoteContent*)noteContent withImage:(UIImage*)image atLocation:(NSRange)range withPoint:(CGPoint)point
{
    NSData *data = UIImageJPEGRepresentation(image, 1);
    NSDictionary *dataDict = @{@"mediaNameString":[self currentDate],@"data":data,@"location":[NSString stringWithFormat:@"%@",@(range.location)],@"cursorX":[NSString stringWithFormat:@"%@",@(point.x)],@"cursorY":[NSString stringWithFormat:@"%@",@(point.y)]};
    MediaData *mediaData = [self.coreDataStack mediaDataCreateWithDict:dataDict];
    mediaData.owner = noteContent;
    
    [self.mediasArray addObject:mediaData];
    
    [self.coreDataStack saveContext];
    
    [self.mediaDict setObject:self.mediasArray forKey:@"medias"];
    NSLog(@"mediasArray:%@",@(self.mediasArray.count));
    NSLog(@"medict: %@",@(self.mediaDict.count));
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}
#pragma mask - SelectedShareRangeViewControllerDelegate
-(void)didSelectedSharedUsers:(NSDictionary *)sharedUser
{
    //分享
    self.sharedUser = [NSDictionary dictionaryWithDictionary:sharedUser];
    
}
#pragma mask - warning delegate
-(void)didSelectedDateString:(NSDictionary *)dict
{
    //提醒
    self.warningDict = [[NSDictionary alloc] initWithDictionary:dict];
    
}

#pragma mask - view controller life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpTableView];
    UISplitViewController *splitVC = self.splitViewController;
    UINavigationController *navgVC = (UINavigationController*)([[splitVC viewControllers] firstObject]);
    NoteShowViewController *showVC = (NoteShowViewController*)[navgVC.viewControllers firstObject];
    showVC.delegate = self;
//    NSMutableDictionary *createDict =[[NSMutableDictionary alloc] init];
//    [createDict setObject:@"2334" forKey:@"dID"];
//    [createDict setObject:@"" forKey:@"caseContentS"];
//    
//    for (NSString *value in @[@"S",@"O",@"A",@"P"]) {
//        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
//        [tempDict setObject:@"" forKey:@"content"];
//        [tempDict setObject:value forKey:@"contentType"];
//        [createDict setObject:tempDict forKey:[NSString stringWithFormat:@"noteContent%@",value]];
//    }
//    
//    self.note = [self.coreDataStack noteBookFetchWithDict:createDict];
//    if (self.note) {
//        [self.tableView reloadData];
//    }
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


#pragma mask - cell delegate
-(void)textViewCell:(RecordNoteCreateCellTableViewCell *)cell didChangeText:(NSString *)text
{
    NSIndexPath *indexPath = [[self tableView] indexPathForCell:cell];
    
    NoteContent *noteContent = [self.note.contents objectAtIndex:indexPath.row];
    noteContent.updatedContent = text;
    [self.coreDataStack saveContext];
    
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
    NSInteger section = self.mediaDict.count==0?1:2;
    NSLog(@"coyunt:%@",@(self.mediaDict.count));
    NSLog(@"section:%@",@(section));
    return section;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.note.contents.count;
    }else {
        return 1;
    }
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"showNoteCell";
    static NSString *mediaCellIdentifier = @"ShowNoteDetailContainerCell";

    if (indexPath.section == 0) {
        RecordNoteCreateCellTableViewCell *tableViewCell =(RecordNoteCreateCellTableViewCell*) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        tableViewCell.delegate = self;
        [self configCell:tableViewCell atIndexPath:indexPath];
        return tableViewCell;
    }else {
        ContainerViewCell *containerCell = [tableView dequeueReusableCellWithIdentifier:mediaCellIdentifier];
        
        NSArray *medias = [self.mediaDict objectForKey:@"medias"];
        
        
        [containerCell setCollectionData:medias];
        
        return containerCell;

    }
   
}
-(void)configCell:(RecordNoteCreateCellTableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UITextView *textView = (UITextView*)[cell viewWithTag:1002];
    //NSString *keyString = [self.keyArray objectAtIndex:indexPath.row];
    UITextField *placeHolder =(UITextField*)[cell viewWithTag:1001];
    NSString *placeHolderString =[self.keyArray objectAtIndex:indexPath.row];
    placeHolder.placeholder = placeHolderString;
    
    //textView.text = StringValue([self.dataSourceDict objectForKey:keyString]);
    NoteContent *noteContent = [self.note.contents objectAtIndex:indexPath.row];
    textView.text = StringValue(noteContent.updatedContent);
    
    [textView layoutSubviews];
    NSLog(@"text: %@",textView.text);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 80;
    }else {
        return 0.1;
        //        return self.mediaDict.count==0?0:20;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        CGRect headerViewFrame = CGRectMake(0, 0, tableView.frame.size.width, tableView.frame.size.height);
        UIView *headerView = [[UIView alloc] initWithFrame:headerViewFrame];
        headerView.backgroundColor = [UIColor whiteColor];
        [self addSubViewToHeaderView:headerView];
        return headerView;
    }else {
        return [[UIView alloc] initWithFrame:CGRectZero];
    }
    
}
-(void)addSubViewToHeaderView:(UIView*)headerView
{
    
    NSString *titleStr = self.note.noteTitle?self.note.noteTitle:nil;
    NSArray *titleArray = titleStr?[titleStr componentsSeparatedByString:@":"]:nil;
    NSString *titleLabelText = titleArray?[titleArray firstObject]:nil;
    NSString *textFieldText = titleArray?[titleArray lastObject]:nil;
    
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 8, 0, 21)];
    titleLabel.text = titleLabelText?titleLabelText:@"新入院";
    [titleLabel sizeToFit];
    
    self.titleLabel = titleLabel;
    
    UITextField *subTitleField = [[UITextField alloc] initWithFrame:CGRectMake(titleLabel.frame.size.width+10, 8, headerView.frame.size.width - titleLabel.frame.size.width - 8 - 8, 21)];
    subTitleField.placeholder = textFieldText?textFieldText:@"输入子标题";
    subTitleField.font = [UIFont systemFontOfSize:15];
    subTitleField.delegate = self;
    subTitleField.borderStyle = UITextBorderStyleNone;
    subTitleField.font = [UIFont systemFontOfSize:17];
    self.titeTextField = subTitleField;
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(8, 21+9, headerView.frame.size.width - 8, 1)];
    line.backgroundColor = [UIColor blueColor];
    
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, line.frame.origin.y+4, 20, 20)];
    dateLabel.textColor = [UIColor blueColor];
    dateLabel.text = [self currentDateString];
    dateLabel.font = [UIFont systemFontOfSize:14];
    [dateLabel sizeToFit];
    
    [headerView addSubview:titleLabel];
    [headerView addSubview:subTitleField];
    [headerView addSubview:line];
    [headerView addSubview:dateLabel];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showNoteWarningSegue"]) {
        
        RecordNoteWarningViewController *recordWarningVC =(RecordNoteWarningViewController*) [self expectedViewController:segue.destinationViewController];
        recordWarningVC.delegate = self;
        recordWarningVC.preferredContentSize = CGSizeMake(320, 500);
    }
    if ([segue.identifier isEqualToString:@"DetailTakePhoto"]) {
        TakePhotoViewController *takePhoto = (TakePhotoViewController*)segue.destinationViewController;
        takePhoto.delegate = self;
        
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

#pragma mask - helper
-(NSString*)currentDateString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy年MM月dd日 HH:mm"];
    
    return [formatter stringFromDate:[NSDate new]];
}
-(NSString*)currentDate
{
    NSString *dateString;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    dateString = [formatter stringFromDate:[NSDate new]];
    return dateString;
}

#pragma mask - property
-(NSArray *)keyArray
{
    if (!_keyArray) {
        _keyArray = @[@"主观性资料",@"客观性资料",@"评估",@"治疗方案"];
    }
    return _keyArray;
}
//-(NSMutableDictionary *)dataSourceDict
//{
//    if (!_dataSourceDict) {
//        _dataSourceDict = [[NSMutableDictionary alloc] init];
//        for (NSString *key in self.keyArray) {
//            NSString *dataString = @"";
//            [_dataSourceDict setObject:dataString forKey:key];
//        }
//    }
//    return _dataSourceDict;
//}
-(NSMutableDictionary *)mediaDict
{
    if (!_mediaDict) {
        _mediaDict = [[NSMutableDictionary alloc] init];
        //        [_mediaDict setObject:nil forKey:@"Audio"];
        //        [_mediaDict setObject:nil forKey:@"Image"];
    }
    return _mediaDict;
}
-(NSMutableArray *)mediasArray
{
    if (!_mediasArray) {
        _mediasArray = [[NSMutableArray alloc] init];
    }
    return _mediasArray;
}
-(NSString *)noteType
{
    if (!_noteType) {
        _noteType = @"0";
    }
    return _noteType;
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

-(NSArray*)noteKeyArray
{
    return @[@"noteContentS",@"noteContentO",@"noteContentP",@"noteContentA"];
}
#pragma mask - keyboard handle
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
@end
