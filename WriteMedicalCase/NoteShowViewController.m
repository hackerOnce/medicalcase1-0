//
//  NoteShowViewController.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/6/5.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "NoteShowViewController.h"

@interface NoteShowViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) IHMsgSocket *socket;
@property (nonatomic,strong) CoreDataStack *coreDataStack;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic,strong) NSArray *noteTitleArray;

@end

@implementation NoteShowViewController
#pragma mask - socket
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
    
    NSArray *tempArray = [[NSMutableArray alloc] initWithArray:[self.coreDataStack fetchNoteBooksWithDoctorID:@"2334"]];
    
    //以升序排列数组
    self.noteTitleArray = [tempArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NoteBook *note1 = (NoteBook*)obj1;
        NoteBook *note2 = (NoteBook*)obj2;
        
        if ([self dateFromDateString:note1.updateDate] < [self dateFromDateString:note2.updateDate]) {
            return NSOrderedDescending;
        }
        if ([self dateFromDateString:note1.updateDate] >[self dateFromDateString:note2.updateDate]) {
            return NSOrderedAscending;
        }
        return NSOrderedSame;
    }];
    
    for (NoteBook *noteBook in self.noteTitleArray) {
        
        for (NoteContent *content in noteBook.contents) {
            NSLog(@"content:%@",content.updatedContent);
        }
    }
    [self.tableView reloadData];
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

    NoteBook *note = (NoteBook*)[self.noteTitleArray objectAtIndex:indexPath.row];
    
    createTimeLabel.text = [self TimeAndMinutesStringWithDateString:note.updateDate];
    NSLog(@"update time:%@",note.updateDate);

    [createTimeLabel sizeToFit];
    
    NSLog(@"note title: %@,noteContent: %@,counts:%@,UUID:%@",note.noteTitle,note.noteUUID,@(note.contents.count),note.noteUUID);
    
    NoteContent *noteContent = (NoteContent*)[note.contents objectAtIndex:0];

    contentPartLabel.text = [self subStringWithString:noteContent.updatedContent toIndex:15];
    titleLabel.text = [self subStringWithString:note.noteTitle toIndex:20];

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
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NoteBook *note = (NoteBook*)[self.noteTitleArray objectAtIndex:indexPath.row];
    
    
    [self.delegate didSelectedANoteWithNoteID:note.noteUUID andCreateDoctorID:note.dID];
    NSLog(@"did selected noteID:%@,dID:%@",note.noteUUID,note.dID);
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
    [formatter setDateFormat:@"yyyy年"];
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
    [formatter setDateFormat:@"HH:mm"];
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
@end
