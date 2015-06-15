//
//  NoteShowViewController.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/6/5.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "NoteShowViewController.h"
#import "TempNoteInfo.h"

@interface NoteShowViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) IHMsgSocket *socket;
@property (nonatomic,strong) CoreDataStack *coreDataStack;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@property (nonatomic,strong) NSMutableArray *noteTitleArray;

@property (nonatomic,strong) NSMutableDictionary *dataDict;

@property (nonatomic,strong) NSMutableArray *keyArray;
@end

@implementation NoteShowViewController
#pragma mask - socket

-(CoreDataStack *)coreDataStack
{
    _coreDataStack = [[CoreDataStack alloc] init];
    return _coreDataStack;
}
- (IBAction)cancel:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mask - view life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
   //NSArray *tempArray = [[NSMutableArray alloc] initWithArray:[self.coreDataStack fetchNoteBooksWithDoctorID:@"2334"]];
//    
//    //以升序排列数组
//    self.noteTitleArray = [tempArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//        NoteBook *note1 = (NoteBook*)obj1;
//        NoteBook *note2 = (NoteBook*)obj2;
//        
//        if ([self dateFromDateString:note1.updateDate] < [self dateFromDateString:note2.updateDate]) {
//            return NSOrderedDescending;
//        }
//        if ([self dateFromDateString:note1.updateDate] >[self dateFromDateString:note2.updateDate]) {
//            return NSOrderedAscending;
//        }
//        return NSOrderedSame;
//    }];
//    
//    for (NoteBook *noteBook in self.noteTitleArray) {
//        
//        for (NoteContent *content in noteBook.contents) {
//            NSLog(@"content:%@",content.updatedContent);
//        }
//    }
//    [self.tableView reloadData];
    self.searchBar.hidden = YES;
    [self.spinner startAnimating];
    [self loadNoteFromServer];
}

-(void)loadNoteFromServer
{
    
    NSString *doctorID = @"2334";
    [MessageObject messageObjectWithUsrStr:doctorID pwdStr:@"test"iHMsgSocket:self.socket optInt:1511 sync_version:1.0 dictionary:@{@"did":doctorID} block:^(IHSockRequest *request) {
        if (request.resp == 0) {
            
            self.noteTitleArray = [[NSMutableArray alloc] init];

            NSMutableArray *resurtArray = [[NSMutableArray alloc] init];

            if ([request.responseData isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dict = (NSDictionary*)request.responseData;
                TempNoteInfo *tempNote = [[TempNoteInfo alloc] initWithDict:dict];

                [resurtArray addObject:tempNote];
            }else {
                if ([request.responseData isKindOfClass:[NSArray class]]) {
                    
                    NSArray *tempArray = (NSArray*)request.responseData;
                    
                    if (tempArray.count == 0) {
                        
                    }else {
                        for (NSDictionary *tempDict in tempArray) {
                            TempNoteInfo *tempNote = [[TempNoteInfo alloc] initWithDict:tempDict];
                            [resurtArray addObject:tempNote];
                        }
                    }
                }
            }
        
            NSArray *localNote = [self.coreDataStack fetchNoteBooksWithDoctorID:doctorID andNoteIsCurrentNote:YES];
                
                if (localNote.count == 0) {
                    
                }else {
                    for (NoteBook *noteBook in localNote) {
                        TempNoteInfo *tempNote = [[TempNoteInfo alloc] initWithNoteBook:noteBook];
                        [resurtArray addObject:tempNote];

                    }
                }
                self.noteTitleArray = [[NSMutableArray alloc] initWithArray:[self sortArray:resurtArray]];
                if (resurtArray.count == 0) {
                    self.spinner.hidden = YES;

                }else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                        self.searchBar.hidden = NO;
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                        [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
                        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
                        self.spinner.hidden = YES;
                    });

                }
            
            }
    
    } failConection:^(NSError *error) {
        NSLog(@" 欧欧，服务器挂了");
        self.spinner.hidden = YES;

        abort();
    }];

}
-(NSArray*)sortArray:(NSArray*)array
{
    NSArray *sortedArray = [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        TempNoteInfo *note1 = (TempNoteInfo*)obj1;
        TempNoteInfo *note2 = (TempNoteInfo*)obj2;

        if ([self dateFromDateString:note1.updatedTime] < [self dateFromDateString:note2.updatedTime]) {
            return NSOrderedDescending;
        }
        if ([self dateFromDateString:note1.updatedTime] >[self dateFromDateString:note2.updatedTime]) {
            return NSOrderedAscending;
        }
        return NSOrderedSame;
    }];
    
    return sortedArray;
}
#pragma mask - table view delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.noteTitleArray.count == 0?0:1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.noteTitleArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"noteTitleCell";
    UITableViewCell *tableViewCell =[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [self configCell:tableViewCell atIndexPath:indexPath];
    return tableViewCell;
}
-(void)configCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UILabel *titleLabel = (UILabel*)[cell viewWithTag:1001];
    UILabel *createTimeLabel =(UILabel*)[cell viewWithTag:1002];
    UILabel *contentPartLabel =(UILabel*)[cell viewWithTag:1003];

    TempNoteInfo *note = (TempNoteInfo*)[self.noteTitleArray objectAtIndex:indexPath.row];
    
    createTimeLabel.text = [self TimeAndMinutesStringWithDateString:note.updatedTime];
    NSLog(@"update time:%@",note.updatedTime);

    [createTimeLabel sizeToFit];
    
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
   // NSLog(@"note title: %@,noteContent: %@,counts:%@,UUID:%@",note.noteTitle,note.noteUUID,@(note.contents.count),note.noteUUID);
    
   // NoteContent *noteContent = (NoteContent*)[note.contents objectAtIndex:0];
    
    contentPartLabel.text = [self subStringWithString:note.noteText toIndex:15];
    titleLabel.text = note.noteTitle;

}
-(NSString*)subStringWithString:(NSString*)originString toIndex:(NSUInteger)index
{
    NSString *contentString;
    if (originString.length > index) {
        contentString =[NSString stringWithFormat:@"%@...",[originString substringToIndex:index]];
        NSLog(@"contentString:%@",contentString);
    }else {
        contentString = originString;
    }
    return contentString;

}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        TempNoteInfo *note = [self.noteTitleArray objectAtIndex:indexPath.row];
        [self.noteTitleArray removeObjectAtIndex:indexPath.row];
        if (self.noteTitleArray.count == 0) {
            
            [self.tableView reloadData];
          
            
        }else {
            if (note.noteID) {
                [self.delegate didDeletedNoteWithNoteID:note.noteID andNoteUUID:nil];
                
            }else {
                
                [self.delegate didDeletedNoteWithNoteID:nil andNoteUUID:note.noteUUID];
            }
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
        if (note.noteID) {
            
            [self.delegate didDeletedNoteWithNoteID:note.noteID andNoteUUID:nil];
            [self.coreDataStack noteBookDeleteWithID:note.noteID andNoteUUID:nil];

            [MessageObject messageObjectWithUsrStr:@"2334" pwdStr:@"test" iHMsgSocket:self.socket optInt:1514 sync_version:1 dictionary:@{@"uuid":StringValue(note.noteID)} block:^(IHSockRequest *request) {
                
                [self.coreDataStack noteBookDeleteWithID:note.noteID andNoteUUID:nil];

            } failConection:^(NSError *error) {
                
            }];
        }else {
            if (note.noteUUID) {
             //   [self.delegate didDeletedNoteWithNoteID:note.noteID andNoteUUID:nil];

                [self.coreDataStack noteBookDeleteWithID:nil andNoteUUID:note.noteUUID];
            }
        }
        
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   // [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TempNoteInfo *note = (TempNoteInfo*)[self.noteTitleArray objectAtIndex:indexPath.row];
    
    NSString *doctorID = @"2334";
    [self.delegate didSelectedANoteWithNoteID:note.noteID andCreateDoctorID:doctorID withNoteUUID:note.noteUUID];
   // NSLog(@"did selected noteID:%@,dID:%@",note.noteID);
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *titleString = @"2015年05月";
    
    
    return titleString;
}

#pragma mask - data helper
-(NSString*)yearAndMonthStringWithDateString:(NSString*)dateString
{
    NSString *yearAndMonth;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy年MM月dd日"];
    yearAndMonth = [formatter stringFromDate:[self dateFromDateString:dateString]];
    return yearAndMonth;
}
-(NSString*)yearStringWithDateString:(NSString*)dateString
{
    NSString *yearString;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy年MM月"];
    yearString = [formatter stringFromDate:[self dateFromDateString:dateString]];
    return yearString;
}
-(NSString*)MonthAndDayStringWithDateString:(NSString*)dateString
{
    NSString *monthAndDay;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM月dd日"];
    monthAndDay = [formatter stringFromDate:[self dateFromDateString:dateString]];
    return monthAndDay;
}
-(NSString*)TimeAndMinutesStringWithDateString:(NSString*)dateString
{
    NSLog(@"date:%@",dateString);

    NSString *timeAndMinutes;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd日 HH:mm"];
    timeAndMinutes = [formatter stringFromDate:[self dateFromDateString:dateString]];

    return timeAndMinutes;
}
-(NSDate*)dateFromDateString:(NSString*)dateString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy年MM月dd日 HH:mm:ss"];
    NSDate *date = [formatter dateFromString:dateString];
    
    return date;
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
-(NSMutableArray *)keyArray
{
    if (!_keyArray) {
        _keyArray = [[NSMutableArray alloc] init];
    }
    return _keyArray;
}
-(NSMutableDictionary *)dataDict
{
    if (!_dataDict) {
        _dataDict = [[NSMutableDictionary alloc] init];
    }
    return _dataDict;
}
-(void)setNoteTitleArray:(NSMutableArray *)noteTitleArray
{
    _noteTitleArray = noteTitleArray;
    self.dataDict = nil;
    self.keyArray = nil;
    
    if (noteTitleArray.count > 0){
        [noteTitleArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            TempNoteInfo *noteInfo = (TempNoteInfo*)obj;
            if ([self.keyArray containsObject:noteInfo.shortCreateDate]){
                if ([self.dataDict.allKeys containsObject:noteInfo.shortCreateDate]) {
                    NSMutableArray *array =[NSMutableArray arrayWithArray:[self.dataDict objectForKey:noteInfo.shortCreateDate]];
                    [array addObject:noteInfo];
                }
            }else {
                [self.keyArray addObject:noteInfo.shortCreateDate];
                
                NSMutableArray *array =[[NSMutableArray alloc] init];
                [array addObject:noteInfo];
                
                [self.dataDict setObject:array forKey:noteInfo.shortCreateDate];
            }
        }];

    }
   }
@end
