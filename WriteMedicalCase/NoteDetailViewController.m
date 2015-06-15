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
#import "IHMsgSocket.h"
#import "RecordView.h"
#import "PlayView.h"

@interface NoteDetailViewController ()<RecordNoteCreateCellTableViewCellDelegate,RecordNoteWarningViewControllerDelegate,SelectedShareRangeViewControllerDelegate,NoteShowViewControllerDelegate,UITextFieldDelegate,TakePhotoViewControllerDelegate,RecordViewDelegate,PlayViewDelegate
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
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@property (nonatomic,strong) NSMutableDictionary *mediaDict;
@property (nonatomic,strong) NSMutableArray *mediasArray;

@property (nonatomic,strong) RecordView *recordView;
@property (nonatomic,strong) PlayView *playView;

@property (nonatomic,strong) NSURL *url;
@end

@implementation NoteDetailViewController

#pragma mask - core data stack
-(CoreDataStack *)coreDataStack
{
    _coreDataStack = [[CoreDataStack alloc] init];
    return _coreDataStack;
}
- (IBAction)audioButtonClicked:(UIButton *)sender
{
    self.recordView = [[RecordView alloc] initWithFrame:CGRectMake(320, 0, self.view.frame.size.width, 64)];
    self.recordView.delegate = self;
    [self.recordView startRecord];
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    [keyWindow addSubview:self.recordView];
    
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
  //  TempDoctor *doctor = [TempDoctor setSharedDoctorWithDict:nil];
//    if ([StringValue(self.noteContent) isEqualToString:@""] ) {
//        //笔记内容不允许为空
//        return;
//    }
//    NSString *doctorID = @"2334";
//    NSDictionary *dict = [NSDictionary dictionaryWithDictionary:[self prepareForSave]];
//    
//    
//    [MessageObject messageObjectWithUsrStr:doctorID pwdStr:@"test"iHMsgSocket:self.socket optInt:1513 sync_version:1.0 dictionary:dict block:^(IHSockRequest *request) {
//        
//    } failConection:^(NSError *error) {
//        
//    }];
    [self saveNotebuttonClicked];
}
- (IBAction)cancel:(UIBarButtonItem *)sender
{
    
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
    NSString *titleString = [NSString stringWithFormat:@"%@: %@",self.titleLabel.text,self.titeTextField.text];
    self.note.noteTitle = titleString;
    [self.coreDataStack saveContext];
    
    ///修改待验证
    //  TempDoctor *doctor = [TempDoctor setSharedDoctorWithDict:nil];
    //NSDictionary *dict = [NSDictionary dictionaryWithDictionary:[self prepareForSave]];
     NSDictionary *dict = [self prepareForSave];
    [MessageObject messageObjectWithUsrStr:@"2334"pwdStr:@"test"iHMsgSocket:self.socket optInt:1513 sync_version:1.0 dictionary:dict block:^(IHSockRequest *request) {
        
        if (request.resp == 0) {
            if ([request.responseData isKindOfClass:[NSDictionary class]]) {
                NSDictionary *resultDict = (NSDictionary*)request.responseData;
                NoteBook *note = self.note;
                note.updateDate = [resultDict objectForKey:@"ih_create_time"];
                note.createDate = [resultDict objectForKey:@"ih_modify_time"];
                // note.noteID = [resultDict objectForKey:@"ih_note_id"];
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
    [dict setObject:self.note.noteID forKey:@"uuid"];
    for (NoteContent *noteContent in self.note.contents) {
        NSString *type = [noteContent.contentType lowercaseString];
        NSString *keyString = [@"ih_content" stringByAppendingString:type];
        NSDictionary *contentDict = [NSDictionary dictionaryWithDictionary:[self prepareForServerWithNoteContent:noteContent]];
        [dict setObject:contentDict forKey:keyString];
    }
    return dict;
}
-(NSDictionary*)prepareForServerWithNoteContent:(NoteContent*)noteContent
{
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
    NSSet *medias =[[NSMutableSet alloc] initWithSet:noteContent.medias];//s,o,a,p
    
    NSPredicate *addedPredicateForImages = [NSPredicate predicateWithFormat:@"hasAdded = %@ AND dataType = %@",[NSNumber numberWithBool:YES],@"0"];
    NSPredicate *addedPredicateForAudios = [NSPredicate predicateWithFormat:@"hasAdded = %@ AND dataType = %@",[NSNumber numberWithBool:YES],@"1"];

    NSPredicate *deletedPredicateImages = [NSPredicate predicateWithFormat:@"hasDeleted = %@ AND dataType = %@",[NSNumber numberWithBool:YES],@"0"];
    NSPredicate *deletedPredicateAudios = [NSPredicate predicateWithFormat:@"hasDeleted = %@ AND dataType = %@",[NSNumber numberWithBool:YES],@"1"];


    NSSet *addedMediasForImages = [medias filteredSetUsingPredicate:addedPredicateForImages];
    NSSet *addedMediasForAudios = [medias filteredSetUsingPredicate:addedPredicateForAudios];
    NSSet *deletededMediasForImages = [medias filteredSetUsingPredicate:deletedPredicateImages];
    NSSet *deletedMediasForAudios = [medias filteredSetUsingPredicate:deletedPredicateAudios];

    if (deletedMediasForAudios) {
        
        if (deletedMediasForAudios.count == 0){
            [tempDict setObject:@"" forKey:@"delete_audio"];
        }else {
            
            NSMutableArray *deletedArray = [[NSMutableArray alloc] init];
            
            for (MediaData *mediaData in deletedMediasForAudios) {
                [deletedArray addObject:mediaData.mediaID];
            }
            
            [tempDict setObject:deletedArray forKey:@"delete_audio"];
        }
        
    }else {
        [tempDict setObject:@"" forKey:@"delete_audio"];
    }
    
    if (deletededMediasForImages) {
        
        if (deletededMediasForImages.count == 0){
            [tempDict setObject:@"" forKey:@"delete_image"];
        }else {
            
            NSMutableArray *deletedArray = [[NSMutableArray alloc] init];
            
            for (MediaData *mediaData in deletededMediasForImages) {
                [deletedArray addObject:mediaData.mediaID];
            }
            
            [tempDict setObject:deletedArray forKey:@"delete_image"];
        }
        
    }else {
        [tempDict setObject:@"" forKey:@"delete_image"];
    }
    
//    if (deletededMediasForImages) {
//        [tempDict setObject:deletedMediasForAudios.count==0?@"":deletededMediasForImages forKey:@"delete_image"];
//    }else {
//        [tempDict setObject:@"" forKey:@"delete_image"];
//    }
    
    if (addedMediasForAudios) {
        
        if (addedMediasForAudios.count == 0) {
            
        }else {
            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
            
            for (MediaData *mediaData in addedMediasForAudios) {
//                NSMutableDictionary *mediaDict = [[NSMutableDictionary alloc] init];
//                [mediaDict setObject:StringValue(mediaData.location) forKey:@"ih_audio_index"];
                NSString *encodeDataString = [[mediaData.data gzippedData] base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
                NSDictionary *imageDict = @{@"ih_audio_data":encodeDataString,@"ih_audio_index":mediaData.location?mediaData.location:nil};
                [tempArray addObject:imageDict];
            }
            
            [tempDict setObject:tempArray forKey:@"audio"];
        }
        //[tempDict setObject:addedMediasForAudios.count==0?@"":addedMediasForAudios forKey:@"audio"];
    }else {
        [tempDict setObject:@"" forKey:@"audio"];
    }
    
    if (addedMediasForImages) {
        
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        
        for (MediaData *mediaData in addedMediasForAudios) {

            NSString *encodeDataString = [[mediaData.data gzippedData] base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
            
            NSDictionary *imageDict = @{@"ih_image_data":encodeDataString,@"ih_image_index":mediaData.location?mediaData.location:nil};
            [tempArray addObject:imageDict];
        }
        
        [tempDict setObject:tempArray forKey:@"images"];
    }else {
        [tempDict setObject:@"" forKey:@"images"];
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
            NSString *encodeDataString = [[mediaData.data gzippedDataWithCompressionLevel:1.0] base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
            NSDictionary *audioDict = @{@"ih_audio_data":encodeDataString,@"ih_audio_index":mediaData.location?mediaData.location:nil};
            [audios addObject:audioDict];
        }else {//image
            NSString *encodeDataString = [[mediaData.data gzippedDataWithCompressionLevel:1.0] base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
            
            
            NSDictionary *imageDict = @{@"ih_image_data":encodeDataString,@"ih_image_index":mediaData.location?mediaData.location:nil};
            [images addObject:imageDict];
            
        }
    }
    [mediasDict setObject:images.count==0?@"":images forKey:@"images"];
    [mediasDict setObject:audios.count==0?@"":audios forKey:@"audio"];
    
    return mediasDict;
}

#pragma mask - recoview delegate
-(void)didCompletedAudioWithDuration:(NSString *)durationString audioName:(NSString *)audioName audioURL:(NSURL *)audioURL
{
    [self.recordView removeFromSuperview];
    NoteContent *noteContent = [self.note.contents objectAtIndex:self.currentIndexPath.row];
    CGRect  textViewRect = [self.currentTextView caretRectForPosition:self.currentTextView.selectedTextRange.start];
    CGPoint cursorPosition = textViewRect.origin;
    
    NSRange range = self.currentTextView.selectedRange;

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self addMediaDataAudioToNoteContent:noteContent withAudioName:audioName andAudioURL:audioURL audioDuration:durationString cursorPoint:cursorPosition atRange:range];
    });
  //  self.currentIndexPath
}
-(void)addMediaDataAudioToNoteContent:(NoteContent*)noteContent withAudioName:(NSString*)audioName andAudioURL:(NSURL*)audioURL audioDuration:(NSString*)duration cursorPoint:(CGPoint)cursorPoint atRange:(NSRange)range
{
    NSError *error;
    NSData *data = [NSData dataWithContentsOfURL:audioURL options:NSDataReadingMappedIfSafe error:&error];
    self.url = audioURL;
    NSDictionary *dataDict = @{@"mediaNameString": audioName,@"data":data,@"location":[NSString stringWithFormat:@"%@",@(range.location)],@"cursorX":[NSString stringWithFormat:@"%@",@(cursorPoint.x)],@"cursorY":[NSString stringWithFormat:@"%@",@(cursorPoint.y)],@"urlString":[audioURL relativeString],@"dataType":@"1"};
    MediaData *mediaData = [self.coreDataStack mediaDataCreateWithDict:dataDict];
    mediaData.hasAdded = [NSNumber numberWithBool:YES];
    mediaData.hasDeleted = [NSNumber numberWithBool:NO];
    
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
#pragma mask - take photo view controller delegate
-(void)didCancelSelectedImage
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
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
    NSData *data = UIImageJPEGRepresentation(image, 0.5);
    NSDictionary *dataDict = @{@"mediaNameString":[self currentDate],@"data":data,@"location":[NSString stringWithFormat:@"%@",@(range.location)],@"cursorX":[NSString stringWithFormat:@"%@",@(point.x)],@"cursorY":[NSString stringWithFormat:@"%@",@(point.y)],@"dataType":@"0"};
    MediaData *mediaData = [self.coreDataStack mediaDataCreateWithDict:dataDict];
    mediaData.hasAdded = [NSNumber numberWithBool:YES];
    mediaData.hasDeleted = [NSNumber numberWithBool:NO];
    
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
#pragma mask - note show view controller delegate
-(void)didDeletedNoteWithNoteID:(NSString *)noteID andNoteUUID:(NSString *)noteUUID
{
    self.note = nil;
    [self.tableView reloadData];
}
-(void)didSelectedANoteWithNoteID:(NSString *)noteID andCreateDoctorID:(NSString *)dID withNoteUUID:(NSString *)noteUUID
{
    
    self.note = nil;

    [self.tableView reloadData];
    if(self.spinner.hidden){
        self.spinner.hidden = NO;
    }
    [self.spinner startAnimating];
    
    if (noteID && ![noteID isEqualToString:@""]) { //从服务器请求
        [MessageObject messageObjectWithUsrStr:@"2334" pwdStr:@"test" iHMsgSocket:self.socket optInt:1510 sync_version:1 dictionary:@{@"uuid":StringValue(noteID)} block:^(IHSockRequest *request) {
            
            if (request.resp == 0 ) {
                if ([request.responseData isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *dict = (NSDictionary*)request.responseData;
                    NSDictionary *parseDict = [self prepareForCoreDataWithDict:dict];
                    self.note = [self.coreDataStack noteBookFetchWithDict:parseDict];
                    [self prepareForShowNoteMedia];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                        self.spinner.hidden = YES;
                    });
                }
            }
            
        } failConection:^(NSError *error) {
            self.spinner.hidden = NO;

    }];
    }else {
        self.note = [self.coreDataStack noteBookFetchWithDict:@{@"noteUUID":noteUUID,@"dID":dID}];
        
        NSLog(@"note UUID:%@",self.note.noteUUID);
        [self prepareForShowNoteMedia];
    
        [self.tableView reloadData];
        self.spinner.hidden = YES;

    }
}
-(NSDictionary*)prepareForCoreDataWithDict:(NSDictionary*)dict
{
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
    
    if ([dict.allKeys containsObject:@"ih_doctor_id"]) {
        [tempDict setObject:StringValue(dict[@"ih_doctor_id"]) forKey:@"dID"];
    }
//    if ([dict.allKeys containsObject:@"ih_doctor_id"]) {
//        [tempDict setObject:StringValue(dict[@"ih_doctor_id"]) forKey:@"dName"];
//    }
    if ([dict.allKeys containsObject:@"ih_note_id"]) {
        [tempDict setObject:StringValue(dict[@"ih_note_id"]) forKey:@"noteID"];
    }
    [tempDict setObject:@(NO) forKey:@"isCurrentNote"];
    
    NSString *noteType;
//    if ([dict.allKeys containsObject:@"notePatientName"]) {
//        [tempDict setObject:StringValue(dict[@"notePatientName"]) forKey:@"notePatientName"];
//    }
    //    if ([dict.allKeys containsObject:@"notePatientName"]) {
    //        [tempDict setObject:StringValue(dict[@"notePatientName"]) forKey:@"notePatientID"];
    //    }
    if ([dict.allKeys containsObject:@"ih_note_type"]) {
        [tempDict setObject:StringValue(dict[@"ih_note_type"]) forKey:@"noteType"];
        noteType = [dict objectForKey:@"ih_note_type"];
    }
    if ([dict.allKeys containsObject:@"ih_note_title"]) {
        [tempDict setObject:StringValue(dict[@"ih_note_title"]) forKey:@"noteTitle"];
    }

    if ([dict.allKeys containsObject:@"ih_create_time"]) {
        [tempDict setObject:StringValue(dict[@"ih_create_time"]) forKey:@"createDate"];
    }
    if ([dict.allKeys containsObject:@"ih_modify_time"]) {
        [tempDict setObject:StringValue(dict[@"ih_modify_time"]) forKey:@"updateDate"];
    }
    
    if ([dict.allKeys containsObject:@"ih_alert_com"]) {
        [tempDict setObject:StringValue(dict[@"ih_alert_com"]) forKey:@"warningCommit"];
    }
    if ([dict.allKeys containsObject:@"ih_alert_cont"]) {
        [tempDict setObject:StringValue(dict[@"ih_alert_cont"]) forKey:@"warningContent"];
    }
    if ([dict.allKeys containsObject:@"ih_alert_time"]) {
        [tempDict setObject:StringValue(dict[@"ih_alert_time"]) forKey:@"warningTime"];
    }
    
   // NSMutableDictionary *contentsDict = [[NSMutableDictionary alloc] init];
    
    if (noteType) {
        if ([noteType integerValue]){
            // origin note
            if ([dict.allKeys containsObject:@"ih_contents"]) {
                id contenta = dict[@"ih_contents"];
                if (contenta) {
                    if ([contenta isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *contentDict = dict[@"ih_contents"];
                        [tempDict setObject:[self parseNoteContentsWithDict:contentDict] forKey:@"noteContentS"];
                    }else if ([contenta isEqualToString:@""]){
                        
                        NSDictionary *contentDict = @{@"ih_note_text":@""};
                        //[tempDict setObject:@"" forKey:@"noteContentA"];
                        [tempDict setObject:[self parseNoteContentsWithDict:contentDict] forKey:@"noteContentS"];
                        
                    }
                    
                }
            }
        }else {
            //patient note
            if ([dict.allKeys containsObject:@"ih_contenta"]) {
                id contenta = dict[@"ih_contenta"];
                if (contenta) {
                    if ([contenta isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *contentDict = dict[@"ih_contenta"];
                        [tempDict setObject:[self parseNoteContentsWithDict:contentDict] forKey:@"noteContentA"];
                    }else if ([contenta isEqualToString:@""]){
                        
                        NSDictionary *contentDict = @{@"ih_note_text":@""};
                        //[tempDict setObject:@"" forKey:@"noteContentA"];
                        [tempDict setObject:[self parseNoteContentsWithDict:contentDict] forKey:@"noteContentA"];
                        
                    }
                }
            }
            
            if ([dict.allKeys containsObject:@"ih_contento"]) {
                id contento = dict[@"ih_contento"];
                if (contento) {
                    if ([contento isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *contentDict = dict[@"ih_contento"];
                        [tempDict setObject:[self parseNoteContentsWithDict:contentDict] forKey:@"noteContentO"];
                    }else if ([contento isEqualToString:@""]){
                        
                        NSDictionary *contentDict = @{@"ih_note_text":@""};
                        //[tempDict setObject:@"" forKey:@"noteContentA"];
                        [tempDict setObject:[self parseNoteContentsWithDict:contentDict] forKey:@"noteContentO"];
                        
                    }
                }
            }
            if ([dict.allKeys containsObject:@"ih_contentp"]) {
                id contenta = dict[@"ih_contentp"];
                if (contenta) {
                    if ([contenta isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *contentDict = dict[@"ih_contentp"];
                        [tempDict setObject:[self parseNoteContentsWithDict:contentDict] forKey:@"noteContentP"];
                    }else if ([contenta isEqualToString:@""]){
                        
                        NSDictionary *contentDict = @{@"ih_note_text":@""};
                        //[tempDict setObject:@"" forKey:@"noteContentA"];
                        [tempDict setObject:[self parseNoteContentsWithDict:contentDict] forKey:@"noteContentP"];
                        
                    }
                }
            }
            if ([dict.allKeys containsObject:@"ih_contents"]) {
                id contenta = dict[@"ih_contents"];
                if (contenta) {
                    if ([contenta isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *contentDict = dict[@"ih_contents"];
                        [tempDict setObject:[self parseNoteContentsWithDict:contentDict] forKey:@"noteContentS"];
                    }else if ([contenta isEqualToString:@""]){
                        
                        NSDictionary *contentDict = @{@"ih_note_text":@""};
                        //[tempDict setObject:@"" forKey:@"noteContentA"];
                        [tempDict setObject:[self parseNoteContentsWithDict:contentDict] forKey:@"noteContentS"];
                        
                    }
                    
                }
            }

        }
    }
    
   // [tempDict setObject:contentsDict forKey:@"content"];
    return tempDict;
}
-(NSDictionary*)parseNoteContentsWithDict:(NSDictionary*)contentDict
{
    NSMutableDictionary *tempContentDict = [[NSMutableDictionary alloc] init];
    
    NSMutableArray *mediasArray = [[NSMutableArray alloc] init];

    if ([contentDict.allKeys containsObject:@"audio"]) {
        
        id audio = contentDict[@"audio"];
        NSMutableArray *tempAudioArray = [[NSMutableArray alloc] init];
        if ([audio isKindOfClass:[NSArray class]]) {
            NSArray *audioArray = (NSArray*)contentDict[@"audio"];
            [tempAudioArray addObjectsFromArray:audioArray];
        }else if([audio isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *tempAudoDict = (NSDictionary*)audio;
            
            if (tempAudoDict.count == 0) {
                
            }else {
                [tempAudioArray addObject:tempAudoDict];
            }
        }
        
        for (NSDictionary *tempDict in tempAudioArray) {
            NSMutableDictionary *tempCDict = [[NSMutableDictionary alloc] init];
            if ([tempDict.allKeys containsObject:@"ih_audio_data"]) {
                
                NSString *dataString = tempDict[@"ih_audio_data"];
                
                NSData *data = [[NSData alloc] initWithBase64EncodedString:dataString options:NSDataBase64DecodingIgnoreUnknownCharacters];
                
                [tempCDict setObject:[data gunzippedData] forKey:@"data"];
            }
            if ([tempDict.allKeys containsObject:@"ih_audio_index"]) {
                [tempCDict setObject:StringValue(tempCDict[@"ih_audio_index"])  forKey:@"location"];
            }
            //                    if ([tempDict.allKeys containsObject:@"ih_audio_index"]) {
            //                        [tempCDict setObject:tempCDict[@"ih_audio_index"] forKey:@"mediaID"];
            //                    }
            //data type 1 for audio ,0 for image
            [tempCDict setObject:@(1) forKey:@"dataType"];
            
            [tempCDict setObject:[NSNumber numberWithBool:NO] forKey:@"hasAdded"];
            [tempCDict setObject:[NSNumber numberWithBool:NO] forKey:@"hasDeleted"];
            
            [mediasArray addObject:tempCDict];
        }
        
       // [tempContentDict setObject:tempCArray forKey:@"audios"];
    }

    if ([contentDict.allKeys containsObject:@"images"]) {
        id images = contentDict[@"images"];
        NSMutableArray *tempImagesArray = [[NSMutableArray alloc] init];
        if ([images isKindOfClass:[NSArray class]]) {
            NSArray *imageArray = (NSArray*)contentDict[@"images"];
            [tempImagesArray addObjectsFromArray:imageArray];
        }else if([images isKindOfClass:[NSDictionary class]]) {
            NSDictionary *tempImageDict = (NSDictionary*)images;
            
            if (tempImageDict.count == 0) {
                
            }else {
                [tempImagesArray addObject:tempImageDict];
            }
        }
       // NSMutableArray *tempCArray = [[NSMutableArray alloc] init];
        for (NSDictionary *tempDict in tempImagesArray) {
            NSMutableDictionary *tempCDict = [[NSMutableDictionary alloc] init];
            if ([tempDict.allKeys containsObject:@"ih_image_data"]) {
                NSString *dataString = tempDict[@"ih_image_data"];
            
                NSData *data = [[NSData alloc] initWithBase64EncodedString:dataString options:NSDataBase64DecodingIgnoreUnknownCharacters];
                [tempCDict setObject:[data gunzippedData] forKey:@"data"];
            }
            if ([tempDict.allKeys containsObject:@"ih_image_index"]) {
                [tempCDict setObject:StringValue([NSString stringWithFormat:@"%@",tempDict[@"ih_image_index"]])  forKey:@"location"];
            }
            if ([tempDict.allKeys containsObject:@"ih_media_id"]) {
                [tempCDict setObject:tempDict[@"ih_media_id"] forKey:@"mediaID"];
            }
            [tempCDict setObject:[NSNumber numberWithBool:NO] forKey:@"hasAdded"];
            [tempCDict setObject:[NSNumber numberWithBool:NO] forKey:@"hasDeleted"];

            //                    ifpo ([tempDict.allKeys containsObject:@"ih_audio_index"]) {
            //                        [tempCDict setObject:tempCDict[@"ih_audio_index"] forKey:@"mediaID"];
            //                    }
            //data type 0 for audio ,1 for image
            [tempCDict setObject:[NSString stringWithFormat:@"%@",@(0)] forKey:@"dataType"];
            [mediasArray addObject:tempCDict];
        }
        
        //[tempContentDict setObject:tempCArray forKey:@"images"];
        
    }
    
    if (mediasArray.count == 0) {
        
    }else {
        [tempContentDict setObject:mediasArray forKey:@"medias"];
    }
    if ([contentDict.allKeys containsObject:@"ih_note_text"]) {
        [tempContentDict setObject:contentDict[@"ih_note_text"] forKey:@"content"];
    }
    
    return tempContentDict;
   // [contentsDict setObject:tempContentDict forKey:@"contentA"];

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
    self.spinner.hidden = YES;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectedMedia:) name:@"didSelectItemFromCollectionView" object:nil];
}
-(void)setUpTableView
{
    self.tableView.estimatedRowHeight = 1000;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
}

-(void)didSelectedMedia:(NSNotification*)info
{
    MediaData *mediaData = (MediaData*)[info object];
    
    if ([mediaData.dataType integerValue]) {
        //aduio
        UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];

        BOOL hasPlayView = NO;
        for (UIView *subView in keyWindow.subviews) {
            if (subView == self.playView) {
                hasPlayView = YES;
            }
        }
        if (hasPlayView) {
            self.playView.audioData = mediaData.data;
        }else {
            self.playView = [[PlayView alloc] initWithFrame:CGRectMake(320, 0, self.view.frame.size.width, 64)];
            [keyWindow addSubview:self.playView];
            self.playView.delegate = self;
             self.playView.audioData = mediaData.data;
            //self.playView.playURL  = self.url;
        }
       
    }
}
#pragma mask -play view delegate
-(void)didCompletedAudioPlay
{
    [self.playView removeFromSuperview];
    
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
    if (self.note) {
        NSInteger section = self.mediaDict.count==0?1:2;
        NSLog(@"coyunt:%@",@(self.mediaDict.count));
        NSLog(@"section:%@",@(section));
        return section;
    }else {
        return 0;
    }
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        if (self.note) {
            if ([self.note.noteType integerValue] == 0) {
                return self.note.contents.count;
            }else {
                return 1;
            }
        }else {
            return 0;
        }
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
    placeHolder.placeholder = [self.note.noteType integerValue]?@"":placeHolderString;
    
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
        if ([self.note.noteType integerValue] == 0) {
            return 80;

        }else {
            return 0.1;
        }
    }else {
        return 0.1;
        //        return self.mediaDict.count==0?0:20;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        if ([self.note.noteType integerValue] == 0) {
            CGRect headerViewFrame = CGRectMake(0, 0, tableView.frame.size.width, tableView.frame.size.height);
            UIView *headerView = [[UIView alloc] initWithFrame:headerViewFrame];
            headerView.backgroundColor = [UIColor whiteColor];
            [self addSubViewToHeaderView:headerView];
            return headerView;
        }else {
           return [[UIView alloc] initWithFrame:CGRectZero];
        }
        
    }else {
        return [[UIView alloc] initWithFrame:CGRectZero];
    }
    
}
-(void)addSubViewToHeaderView:(UIView*)headerView
{
    
    NSString *titleStr = [StringValue(self.note.noteTitle) isEqualToString:@""]?@"新入院: 输入子标题":self.note.noteTitle;
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
