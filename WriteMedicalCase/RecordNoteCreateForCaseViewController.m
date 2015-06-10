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
#import "SelectedShareRangeViewController.h"
#import "TemplateNoteContent.h"
#import "TestViewController.h"
#import "TakePhotoViewController.h"
#import "ContainerViewCell.h"

@interface RecordNoteCreateForCaseViewController ()<RecordNoteCreateCellTableViewCellDelegate,UITableViewDataSource,UITableViewDelegate,RecordNoteWarningViewControllerDelegate,SelectedShareRangeViewControllerDelegate,UITextFieldDelegate,TakePhotoViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) NSMutableDictionary *dataSourceDict;
@property (nonatomic,strong) NSArray *keyArray;

@property (nonatomic) CGFloat keyboardOverlap;
@property (nonatomic,strong) UITextView *currentTextView;
@property (nonatomic,strong) NSIndexPath *currentIndexPath;
@property (nonatomic) BOOL keyboardShow;

@property (nonatomic,strong) NSString *noteType;

@property (nonatomic,strong) IHMsgSocket *socket;

@property (nonatomic,strong) UITextField *titeTextField;
@property (nonatomic,strong) UILabel *titleLabel;
//prepare for save note
@property (nonatomic,strong) NSDictionary *sharedUser;
@property (nonatomic,strong) NSDictionary *warningDict;

@property (nonatomic,strong) NSDictionary *contentDict;

@property (nonatomic,strong) NoteBook *note;

@property (nonatomic,strong) CoreDataStack *coreDataStack;

@property (nonatomic,strong) NoteContent *selectedNoteContent;

@property (nonatomic,strong) NSLayoutConstraint *currentTextViewheightConstraints;

@property (nonatomic,strong) NSMutableDictionary *mediaDict;
@property (nonatomic,strong) NSMutableArray *mediasArray;
@end

@implementation RecordNoteCreateForCaseViewController


#pragma mask - core data stack
-(CoreDataStack *)coreDataStack
{
    _coreDataStack = [[CoreDataStack alloc] init];
    return _coreDataStack;
}
- (IBAction)takePhoto:(UIButton *)sender
{
    
}
- (IBAction)audio:(UIButton *)sender
{
    
}
- (IBAction)sharedClicked:(UIButton *)sender
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

-(void)cancelCreateNoteButtonClicked
{
    // 取消创建
    [self.coreDataStack noteBookDeleteWithID:nil andNoteUUID:self.note.noteUUID];
    [self.coreDataStack saveContext];
}
- (IBAction)saveButton:(UIButton *)sender {
    
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"保存成功" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [alertView show];
}
-(void)saveNotebuttonClicked
{
    for (NoteContent *noteContent in self.note.contents) {
        noteContent.content = noteContent.updatedContent;
        NSLog(@"content:%@",noteContent.updatedContent);
    }
    
    self.note.updateDate = [self currentDate];
    // 只有从服务器保存成功以后才能设定
    //self.note.isCurrentNote = NO;
    
    [self.coreDataStack saveContext];

    //  TempDoctor *doctor = [TempDoctor setSharedDoctorWithDict:nil];
    NSDictionary *dict = [NSDictionary dictionaryWithDictionary:[self prepareForSave]];
      [MessageObject messageObjectWithUsrStr:@"2334"pwdStr:@"test"iHMsgSocket:self.socket optInt:1509 sync_version:1.0 dictionary:dict block:^(IHSockRequest *request) {
          
          if (request.resp == 0) {
              if ([request.responseData isKindOfClass:[NSDictionary class]]) {
                  NSDictionary *resultDict = (NSDictionary*)request.responseData;
                  NoteBook *note = self.note;
                  note.updateDate = [resultDict objectForKey:@"ih_create_time"];
                  note.createDate = [resultDict objectForKey:@"ih_modify_time"];
                  note.noteID = [resultDict objectForKey:@"ih_note_id"];
                  note.isCurrentNote = @(NO);
                  [self.coreDataStack saveContext];

              }
          }
        
      }failConection:^(NSError *error) {
    
      }];
    
        //[self dismissViewControllerAnimated:YES completion:nil];
}
-(NSDictionary*)prepareForSave
{
    //doctor
    TempDoctor *doctor = [TempDoctor setSharedDoctorWithDict:nil];
//    NSString *dID = StringValue(doctor.dID);
    NSString *dName = StringValue(doctor.dName);
    NSString *dProfessionalTitle= StringValue(doctor.dProfessionalTitle);
    NSString *dept = StringValue(doctor.dept);
    NSString *medicalTeam = StringValue(doctor.medicalTeam);
    
    NSString *dID = @"2334";
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
    
    for (NoteContent *noteContent in self.note.contents) {
        NSString *type = [noteContent.contentType lowercaseString];
        NSString *keyString = [@"ih_content" stringByAppendingString:type];
        NSDictionary *contentDict = [NSDictionary dictionaryWithDictionary:[self prepareForServerWithNoteContent:noteContent]];
        [dict setObject:contentDict forKey:keyString];
    }
    NSString *titleString = [NSString stringWithFormat:@"%@: %@",self.titleLabel.text,self.titeTextField.text];
   [dict setObject:titleString forKey:@"ih_note_title"];
    return dict;
}
-(NSDictionary*)prepareForServerWithNoteContent:(NoteContent*)noteContent
{
    NSDictionary *mediaDict;
    NSSet *medias =[[NSSet alloc] initWithSet:noteContent.medias];//s,o,a,p
    
    if (medias.count == 0) {
        mediaDict = nil;
    }else {
        //if (medias) {
            mediaDict =[NSDictionary dictionaryWithDictionary:[self prepareForServerWithMediaArray:medias]];
//        }else {
//            mediaDict = nil;
//        }
    }
    NSMutableDictionary *tempDict;
    if (mediaDict) {
        tempDict = [[NSMutableDictionary alloc] initWithDictionary:mediaDict];
        
    }else {
        tempDict = [[NSMutableDictionary alloc] init];
        [tempDict setObject:@"" forKey:@"images"];
        [tempDict setObject:@"" forKey:@"audio"];

    }
    [tempDict setObject:StringValue(noteContent.updatedContent) forKey:@"ih_note_text"];
    
    return tempDict;
}
-(NSDictionary*)prepareForServerWithMediaArray:(NSSet*)medias
{
    NSMutableDictionary *mediasDict = [[NSMutableDictionary alloc] init];
    NSMutableArray *images = [[NSMutableArray alloc] init];
    NSMutableArray *audios = [[NSMutableArray alloc] init];
    
    for (MediaData *mediaData in medias) {
        
        if ([mediaData.dataType boolValue]) { //audio
            NSString *encodeDataString = [mediaData.data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
            NSDictionary *audioDict = @{@"ih_audio_data":encodeDataString,@"ih_audio_index":mediaData.location?mediaData.location:nil};
            [audios addObject:audioDict];
        }else {//image
            NSString *encodeDataString = [mediaData.data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
            
            
            NSDictionary *imageDict = @{@"ih_image_data":encodeDataString,@"ih_image_index":mediaData.location?mediaData.location:nil};
            [images addObject:imageDict];
            
        }
    }
    [mediasDict setObject:images.count==0?@"":images forKey:@"images"];
    [mediasDict setObject:audios.count==0?@"":audios forKey:@"audio"];
    
    return mediasDict;
}
-(NSString*)contentTypeTransform:(NSString*)contents
{
    NSDictionary *contentDict = @{@"noteContentS":@"ih_contents",@"noteContentO":@"ih_contento",@"noteContentA":@"ih_contenta",@"noteContentP":@"ih_contentp"};
    return contentDict[contents];
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
-(void)showMediaImage:(NSData*)imageData atLocation:(CGPoint)location
{
    
//    UIImageView *imageView = [[UIImageView alloc] init];
//    imageView.contentMode = UIViewContentModeScaleAspectFit;
//    //CGFloat oldWidth = image.size.width;
//   // CGFloat scaleFactor = oldWidth / (self.currentTextView.frame.size.width - 10);
//    //UIImage *newImage = [UIImage imageWithCGImage:image.CGImage scale:scaleFactor orientation:UIImageOrientationUp];
//    UIImage *image = [UIImage imageWithData:imageData];
//            imageView.image = image;
//    imageView.frame = CGRectMake(location.x + 10, location.y-45, self.view.frame.size.width/6, self.view.frame.size.width/6);
//    
//    [self.currentTextView addSubview:imageView];
//    self.currentTextView.scrollEnabled  =NO;
//    
 //     CGRect ovalFrame = [self.currentTextView convertRect:imageView.bounds
//                                         fromView:imageView];
//      UIBezierPath *ovalPath = [UIBezierPath bezierPathWithRect:ovalFrame];
    //NSMutableArray *ovalPaths = [NSMutableArray arrayWithArray:self.currentTextView.textContainer.exclusionPaths];
    //[ovalPaths addObject:ovalPath];
   // self.currentTextView.textContainer.exclusionPaths = ovalPath;

    //ovalFrame.origin.x -= self.currentTextView.textContainerInset.left;
    //ovalFrame.origin.y -= self.currentTextView.textContainerInset.top;
//    UIImage *image = [UIImage imageWithData:imageData];
//    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
//    textAttachment.image = image;
//    CGFloat oldWidth = textAttachment.image.size.width;
//    CGFloat scaleFactor = oldWidth / (self.currentTextView.frame.size.width - 10);
//    textAttachment.image = [UIImage imageWithCGImage:textAttachment.image.CGImage scale:scaleFactor orientation:UIImageOrientationUp];
//    
//    NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
//    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.currentTextView.text];
//    [attributedString replaceCharactersInRange:self.currentTextView.selectedRange withAttributedString:attrStringWithImage];
//    self.currentTextView.attributedText = attributedString;
//    
//    self.currentTextViewheightConstraints.constant += image.size.height;
//    
//    NSLog(@"height:%@",@(self.currentTextViewheightConstraints.constant));
//    [UIView animateWithDuration:1.5 animations:^{
//        
//        [self.currentTextView layoutIfNeeded];
//       // [self.tableView reloadRowsAtIndexPaths:@[self.currentIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//    }];
//  UIBezierPath *ovalPath = [UIBezierPath bezierPathWithRect:ovalFrame];
//  self.currentTextView.textContainer.exclusionPaths = @[ovalPath];
    
    
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

    self.note = [self.coreDataStack noteBookFetchWithDoctorID:@"2334" noteType:self.noteType isCurrentNote:[NSNumber numberWithBool:YES]];
    if (self.note) {
        [self prepareForShowNoteMedia];
        [self.tableView reloadData];
    }else {
        self.note = [self.coreDataStack noteBookFetchWithDict:[self prepareForCreate]];

        if (self.note) {
            [self prepareForShowNoteMedia];
            [self.tableView reloadData];
        }
    }
    
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
-(NSDictionary*)prepareForCreate
{
    NSMutableDictionary *createDict =[[NSMutableDictionary alloc] init];
    [createDict setObject:@"2334" forKey:@"dID"];
    [createDict setObject:@"医生姓名" forKey:@"dName"];
    //[createDict setObject:@"" forKey:@"caseContentS"];
    
    for (NSString *value in @[@"S",@"O",@"A",@"P"]) {
        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
        [tempDict setObject:@"" forKey:@"content"];
        [tempDict setObject:value forKey:@"contentType"];
        
        [createDict setObject:tempDict forKey:[NSString stringWithFormat:@"noteContent%@",value]];
        
        NSLog(@"noteContent:%@",[NSString stringWithFormat:@"noteContent%@",value]);
    }
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
   // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectedMedia) name:@"didSelectItemFromCollectionView" object:nil];
}
-(void)setUpTableView
{
    self.tableView.estimatedRowHeight = 2000;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
}


#pragma mask - cell delegate
-(void)textViewCell:(RecordNoteCreateCellTableViewCell *)cell didChangeText:(NSString *)text
{
    NSIndexPath *indexPath = [[self tableView] indexPathForCell:cell];
    
    NoteContent *noteContent = [self.note.contents objectAtIndex:indexPath.row];
    noteContent.updatedContent = text;
    self.note.updateDate = [self currentDate];
    NSLog(@"update time:%@",self.note.updateDate);
    [self.coreDataStack saveContext];
    
    NSLog(@"note content:%@",noteContent.updatedContent);
}
-(void)textViewDidBeginEditing:(UITextView *)textView withCellIndexPath:(NSIndexPath *)indexPath
{
    RecordNoteCreateCellTableViewCell *cell = (RecordNoteCreateCellTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    self.currentTextViewheightConstraints = cell.textViewHeightConstraints;
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
    static NSString *cellIdentifier = @"noteCreatePatientCell";
    static NSString *mediaCellIdentifier = @"ContainerViewCell";
    
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
    UITextField *placeHolder =(UITextField*)[cell viewWithTag:1001];
    NSString *placeHolderString =[self.keyArray objectAtIndex:indexPath.row];
    placeHolder.placeholder = placeHolderString;
    
    NoteContent *noteContent = [self.note.contents objectAtIndex:indexPath.row];
    NSMutableArray *ovalPaths =[[NSMutableArray alloc] init];
    for (MediaData  *mediaData in noteContent.medias) {
        
       // [self showMediaImage:mediaData.data atLocation:CGPointMake([mediaData.cursorX integerValue], [mediaData.cursorY integerValue])];
//        UIImageView *imageView = [[UIImageView alloc] init];
//        imageView.contentMode = UIViewContentModeScaleAspectFit;
//        //CGFloat oldWidth = image.size.width;
//        // CGFloat scaleFactor = oldWidth / (self.currentTextView.frame.size.width - 10);
//        //UIImage *newImage = [UIImage imageWithCGImage:image.CGImage scale:scaleFactor orientation:UIImageOrientationUp];
//        UIImage *image = [UIImage imageWithData:mediaData.data];
//        imageView.image = image;
//        imageView.frame = CGRectMake([mediaData.cursorX integerValue] + 10, [mediaData.cursorY integerValue]-45, 200, 200);
//        
//        [textView addSubview:imageView];
//        textView.scrollEnabled  = NO;
//        
//        CGRect ovalFrame = [self.currentTextView convertRect:imageView.bounds
//                                                    fromView:imageView];
//        UIBezierPath *ovalPath = [UIBezierPath bezierPathWithRect:ovalFrame];
//       
//        [ovalPaths addObject:ovalPath];
        
    }
    textView.textContainer.exclusionPaths = ovalPaths;

    textView.text = StringValue(noteContent.updatedContent);
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
    subTitleField.text = StringValue(textFieldText);
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
#pragma mask -text field delegate
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    self.note.noteTitle = [[self.titleLabel.text stringByAppendingString:@":"] stringByAppendingString:self.titeTextField.text];
    [self.coreDataStack saveContext];
}
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"patientWarningSegue"]) {
        
        RecordNoteWarningViewController *recordWarningVC =(RecordNoteWarningViewController*) [self expectedViewController:segue.destinationViewController];
        recordWarningVC.delegate = self;
        recordWarningVC.preferredContentSize = CGSizeMake(320, 500);
    }
    if ([segue.identifier isEqualToString:@"patientNoteCancel"]) {
        
        [self cancelCreateNoteButtonClicked];
    }
    
    if ([segue.identifier isEqualToString:@"takePhotoSegue"]) {
        TakePhotoViewController *takePhoto = (TakePhotoViewController*)segue.destinationViewController;
        takePhoto.delegate  = self;
    }
    if ([segue.identifier isEqualToString:@"patientNoteSave"]) {
        //save note
    
        [self saveNotebuttonClicked];

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
        _noteType = @"0";//for patient
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
-(NSDictionary *)contentDict
{
    if (!_contentDict) {
        
         //NSArray *tempArray = [[NSArray alloc] initWithArray:[self noteKeyArray];
        
                              
    }
    return _contentDict;
}
-(NSArray*)noteKeyArray
{
    return @[@"noteContentS",@"noteContentO",@"noteContentP",@"noteContentA"];
}
-(NSString*)currentDate
{
    NSString *dateString;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    dateString = [formatter stringFromDate:[NSDate new]];
    return dateString;
}
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
#pragma mask - keyboard
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
