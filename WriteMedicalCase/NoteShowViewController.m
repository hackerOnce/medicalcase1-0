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

#pragma mask - view life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.noteTitleArray = [[NSMutableArray alloc] initWithArray:[self.coreDataStack fetchNoteBooksWithDoctorID:@"2334"]];
    
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
    
    titleLabel.text = note.noteTitle;
    createTimeLabel.text = @"10:18";
    [createTimeLabel sizeToFit];
    
    NSLog(@"note title: %@,noteContent: %@,counts:%@,UUID:%@",note.noteTitle,note.noteUUID,@(note.contents.count),note.noteUUID);
    
    NoteContent *noteContent = (NoteContent*)[note.contents objectAtIndex:0];

    NSString *contentString;
    if (noteContent.updatedContent.length > 60) {
        contentString =[NSString stringWithFormat:@"%@...",[noteContent.updatedContent substringToIndex:60]];
    }else {
        contentString = noteContent.updatedContent;
    }
    contentPartLabel.text = contentString;
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


@end