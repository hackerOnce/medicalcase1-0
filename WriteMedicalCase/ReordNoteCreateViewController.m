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
#import "SelectedShareRangeViewController.h"
#import "CaseContent.h"

//for test
#import "TempDoctor.h"

@interface ReordNoteCreateViewController ()<UINavigationControllerDelegate,RecordNoteCreateCellTableViewCellDelegate,RecordNoteWarningViewControllerDelegate,SelectedShareRangeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) CGFloat keyboardOverlap;
@property (nonatomic,strong) UITextView *currentTextView;
@property (nonatomic,strong) NSIndexPath *currentIndexPath;
@property (nonatomic) BOOL keyboardShow;

@property (nonatomic,strong) NSString *noteContent;
@property (nonatomic,strong) NSString *noteType;

//prepare for save note
@property (nonatomic,strong) NSDictionary *sharedUser;
@property (nonatomic,strong) NSDictionary *warningDict;

@property (nonatomic,strong) IHMsgSocket *socket;

@property (nonatomic,strong) CoreDataStack *coreDataStack;
@property (nonatomic) NoteBook *note;
@end

@implementation ReordNoteCreateViewController
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

-(void)saveNoteButtonClicked
{
    for (NoteContent *noteContent in self.note.contents) {
        noteContent.content = noteContent.updatedContent;
        NSLog(@"content:%@",noteContent.updatedContent);
    }
    
    self.note.updateDate = [self currentDate];
    // 只有从服务器保存成功以后才能设定
    //self.note.isCurrentNote = NO;
    
    [self.coreDataStack saveContext];

}
-(void)canceCreateNoteButtonClicked
{
    // 取消创建
    [self.coreDataStack noteBookDeleteWithID:self.note.noteUUID];
    [self.coreDataStack saveContext];
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
        commit = StringValue([self.warningDict objectForKey:@"commit"]);
        detailInfoText = StringValue([self.warningDict objectForKey:@"detailInfoText"]);
        warningDate = StringValue([self.warningDict objectForKey:@"warningDate"]);
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
    
    
    for (NoteContent *noteContent in self.note.contents) {
        NSString *type = [noteContent.contentType lowercaseString];
        NSString *keyString = [@"ih_content" stringByAppendingString:type];
        NSDictionary *contentDict = [NSDictionary dictionaryWithDictionary:[self prepareForServerWithNoteContent:noteContent]];
        [dict setObject:contentDict forKey:keyString];
    }
    
//    NSDictionary *noteContentDict = @{@"ih_note_text":self.noteContent,@"audio":@"",@"images":@""};
//    
//    [dict setObject:noteContentDict forKey:@"ih_contents"];
//    
//    
//    [dict setObject:@"" forKey:@"ih_contento"];
//    [dict setObject:@"" forKey:@"ih_contenta"];
//    [dict setObject:@"" forKey:@"ih_contentp"];

    
    return dict;
}

-(NSDictionary*)prepareForServerWithNoteContent:(NoteContent*)noteContent
{
    NSDictionary *mediaDict;
    NSSet *medias =[[NSSet alloc] initWithSet:noteContent.medias];//s,o,a,p

    if (medias.count == 0) {
        mediaDict = nil;
    }else {
        if (medias) {
            mediaDict =[NSDictionary dictionaryWithDictionary:[self prepareForServerWithMediaArray:medias]];
        }else {
            mediaDict = nil;
        }
    }
    NSMutableDictionary *tempDict;
    if (mediaDict) {
        tempDict = [[NSMutableDictionary alloc] initWithDictionary:mediaDict];
        
    }else {
        tempDict = [[NSMutableDictionary alloc] init];
    }
    [tempDict setObject:noteContent.updatedContent forKey:@"ih_note_text"];

    return tempDict;
}
-(NSDictionary*)prepareForServerWithMediaArray:(NSSet*)medias
{
    NSMutableDictionary *mediasDict = [[NSMutableDictionary alloc] init];
    NSMutableArray *images = [[NSMutableArray alloc] init];
    NSMutableArray *audios = [[NSMutableArray alloc] init];
    
    for (MediaData *mediaData in medias) {

        if ([mediaData.dataType boolValue]) { //audio
            NSDictionary *audioDict = @{@"ih_audio_data":mediaData.data?mediaData:nil,@"ih_audio_index":mediaData.location?mediaData.location:nil};
            [audios addObject:audioDict];
        }else {//image
            NSDictionary *imageDict = @{@"ih_images_data":mediaData.data?mediaData:nil,@"ih_images_index":mediaData.location?mediaData.location:nil};
            [images addObject:imageDict];

        }
    }
    [mediasDict setObject:images.count==0?nil:images forKey:@"images"];
    [mediasDict setObject:audios.count==0?nil:audios forKey:@"audio"];

    return mediasDict;
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
    
    self.note = [self.coreDataStack noteBookFetchWithDoctorID:@"2334" noteType:self.noteType isCurrentNote:[NSNumber numberWithBool:YES]];
    if (self.note) {
        [self.tableView reloadData];
    }else {
        self.note = [self.coreDataStack noteBookFetchWithDict:[self prepareForCreate]];
        
        if (self.note) {
            [self.tableView reloadData];
        }
    }
    
}
-(NSDictionary*)prepareForCreate
{
    NSMutableDictionary *createDict =[[NSMutableDictionary alloc] init];
    [createDict setObject:@"2334" forKey:@"dID"];
    [createDict setObject:@"医生姓名" forKey:@"dName"];
    //[createDict setObject:@"" forKey:@"caseContentS"];
    
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
    [tempDict setObject:@"" forKey:@"content"];
    [tempDict setObject:@"S" forKey:@"contentType"];
    [createDict setObject:tempDict forKey:[NSString stringWithFormat:@"noteContent%@",@"S"]];
    
    [createDict setObject:[NSNumber numberWithBool:YES] forKey:@"isCurrentNote"];
    
    [createDict setObject:self.noteType forKey:@"noteType"];
    [createDict setObject:@"patientName" forKey:@"notePatientName"];
    [createDict setObject:@"patientID" forKey:@"notePatientID"];
    [createDict setObject:[self currentDate] forKey:@"createDate"];
    
    return createDict;
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
    NSOrderedSet *orderSet = (NSOrderedSet*)self.note.contents;

    NoteContent *noteContent = [orderSet objectAtIndex:indexPath.row];
    noteContent.updatedContent = text;
    
    self.note.noteTitle = [self partStringFromString:noteContent.updatedContent];
    self.note.updateDate = [self currentDate];
    NSLog(@"update time:%@",self.note.updateDate);

   // self.noteContent = text;
   [self.coreDataStack saveContext];
}
-(NSString*)partStringFromString:(NSString*)tempStr
{
    NSString *subString;
    if (tempStr.length > 30) {
        subString = [tempStr substringToIndex:30];
    }else {
        subString = tempStr;
    }
    return tempStr;
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
    return self.note?1:0;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.note.contents.count;
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
   //textView.text = self.noteContent;
    
    UITextField *placeHolder =(UITextField*)[cell viewWithTag:1001];
    NSString *placeHolderString = @"请输入内容";
    placeHolder.placeholder = placeHolderString;
    
    NSOrderedSet *orderSet = (NSOrderedSet*)self.note.contents;
    NoteContent *noteContent = [orderSet objectAtIndex:indexPath.row];
    
    textView.text = noteContent.updatedContent;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"originalWarningSegue"]) {
        
        RecordNoteWarningViewController *recordWarningVC =(RecordNoteWarningViewController*) [self expectedViewController:segue.destinationViewController];
        recordWarningVC.delegate = self;
    }
    if ([segue.identifier isEqualToString:@"OriginalNoteCancel"]) {
        
        [self canceCreateNoteButtonClicked];
    }
    if ([segue.identifier isEqualToString:@"originNoteSave"]) {
        
        [self saveNoteButtonClicked];
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
       _noteType = @"1";//for origin note
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
-(UIViewController*)expectedViewController:(UIViewController*)viewController
{
    UIViewController *expectedViewController = viewController;
    if ([expectedViewController isMemberOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController*)viewController;
        expectedViewController =(UIViewController*) [nav.viewControllers firstObject];
    }
    return expectedViewController;
}
-(NSString*)currentDate
{
    NSString *dateString;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    dateString = [formatter stringFromDate:[NSDate new]];
    return dateString;
}

@end
