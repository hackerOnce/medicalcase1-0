//
//  ShowTemplateViewController.m
//  MedicalCase
//
//  Created by ihefe-JF on 15/4/3.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import "ShowTemplateViewController.h"
#import "Constants.h"
#import "CoreDataStack.h"
#import "ParentNode.h"
#import "Node.h"
#import "Template.h"
#import "ShowTemplateDetailViewController.h"
#import "SelectedShareRangeViewController.h"
#import "SelectASharedTemplateViewController.h"
#import "ShowTemplateTableViewCell.h"

@interface ShowTemplateViewController ()<UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate,ShowTemplateTableViewCellDelegate>
@property (nonatomic,strong) CoreDataStack *coreDataStack;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) CGFloat keyboardOverlap;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@property (nonatomic,strong) NSFetchedResultsController *fetchResultController;

@property (nonatomic, strong) NSMutableArray *cellsCurrentlyEditing;

@property (nonatomic) BOOL isNewsPage;

@property (nonatomic) NSInteger test;

@property (nonatomic,strong) NSMutableArray *templateArray;//template
@property (nonatomic,strong) IHMsgSocket *socket;

@property (nonatomic,strong) TemplateModel *templateModel;

@property (nonatomic,strong) NSString *templateType;
@end
@implementation ShowTemplateViewController

-(NSManagedObjectContext *)managedObjectContext
{
    return self.coreDataStack.managedObjectContext;
}
-(CoreDataStack *)coreDataStack
{
    _coreDataStack = [[CoreDataStack alloc] init];
    return _coreDataStack;
}
-(NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
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
- (IBAction)cancelBtn:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.cellsCurrentlyEditing = [NSMutableArray array];

    [self setUpTableView];
    [self addKVOObserver];
    
    
}
-(void)setUpTableView
{
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
   // self.title = @"病历模板展示";
}
-(void)addKVOObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTableView:) name:kDidSelectedFinalTemplate object:nil];
}

-(void)updateTableView:(NSNotification*)info
{
    NSString *tempStr = (NSString*)[info object];
    NSLog(@"%@",tempStr);
    if ([tempStr isEqualToString:@"消息"]) {
        tempStr = @"主诉";
        self.isNewsPage = YES;
    }else {
        self.isNewsPage = NO;
    }
    
    NSString *dID = [[NSUserDefaults standardUserDefaults] objectForKey:@"dID"];
    NSString *tempType = tempStr;
    
    self.templateType = [self getMBBHWithEnglishName:tempType];
    
    self.templateArray = [[NSMutableArray alloc] init];

    [MessageObject messageObjectWithUsrStr:dID pwdStr:@"test" iHMsgSocket:self.socket optInt:2003 dictionary:@{@"id":dID,@"mbbh":[NSString stringWithFormat:@"%@",[self getMBBHWithEnglishName:tempType]]} block:^(IHSockRequest *request) {
        
        if ([request.responseData isKindOfClass:[NSArray class]]) {
            NSArray *tempArray = (NSArray*)request.responseData;
            
            for (NSDictionary *dict in tempArray) {
                TemplateModel *templateModel = [[TemplateModel alloc] initWithDic:dict];
                [self.templateArray addObject:templateModel];
            }
            self.spinner.hidden = YES;
            [self.tableView reloadData];
        }
    } failConection:^(NSError *error) {
        self.spinner.hidden = YES;
    }];
    
}
-(NSString*)getMBBHWithEnglishName:(NSString*)name
{
    static NSDictionary *dic = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dic = @{
                @"入院记录" : @"ihefe101",
                @"主诉" : @"ihefe10101",
                @"现病史" : @"ihefe10102",
                @"过去史" : @"ihefe10103",
                @"系统回顾" : @"ihefe10104",
                @"个人史" : @"ihefe10105",
                @"月经史" : @"ihefe10106",
                @"婚姻史" : @"ihefe10107",
                @"婚育史" : @"ihefe10107",//婚育史
                @"家族史" : @"ihefe10108",
                @"体格检查" : @"ihefe10109",
                @"专科检查" : @"ihefe10110",
                @"辅助检查" : @"ihefe10111",
                @"初步诊断" : @"ihefe10112",
                @"入院诊断" : @"ihefe10113",
                @"确诊诊断" : @"ihefe10114" //补充诊断
                };
    });
    if ([dic.allKeys containsObject:name]) {
        return dic[name];
    }
    return nil;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1 ;

}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   
    return self.templateArray.count ;
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        ShowTemplateTableViewCell *cell = (ShowTemplateTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"swipeCell"];
        cell.delegate = self;
        cell.isNewsPage = self.isNewsPage;

        [self configCell:cell withIndexPath:indexPath];
        
        if ([self.cellsCurrentlyEditing containsObject:indexPath]) {
            [cell openCell];
        }

        return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.templateModel =(TemplateModel*)[self.templateArray objectAtIndex:indexPath.row];

    [self performSegueWithIdentifier:@"templateDetail" sender:nil];
}

///table view delete
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
    }
}

-(void)configCell:(ShowTemplateTableViewCell*)cell withIndexPath:(NSIndexPath*)indexPath
{
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    TemplateModel *templateModel = [self.templateArray objectAtIndex:indexPath.row];
    cell.cellIndexPath = indexPath;
    
    UILabel *conditionLabel = (UILabel*)[cell viewWithTag:1001];
    UILabel *contentLabel = (UILabel*)[cell viewWithTag:1003];
    
    conditionLabel.text = templateModel.condition;

    NSString *content;
    if (templateModel.content.length > 100) {
        content = [NSString stringWithFormat:@"%@...", [templateModel.content substringToIndex:100]];
    }else {
        content = templateModel.content;
    }
    contentLabel.text = content;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self heightForBasicCellAtIndexPath:indexPath];
}
- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath {
    static ShowTemplateTableViewCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [self.tableView dequeueReusableCellWithIdentifier:@"swipeCell"];
    });
    sizingCell.isNewsPage = self.isNewsPage;
    [self configCell:sizingCell withIndexPath:indexPath];
    return [self calculateHeightForConfiguredSizingCell:sizingCell];
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell {
    
    sizingCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.frame), CGRectGetHeight(sizingCell.bounds));
    
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height + 1.0f; // Add 1.0f for the cell separator height
}
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}
- (void)cellDidOpen:(UITableViewCell *)cell
{
    NSIndexPath *currentEditingIndexPath = [self.tableView indexPathForCell:cell];
    [self.cellsCurrentlyEditing addObject:currentEditingIndexPath];
}

- (void)cellDidClose:(UITableViewCell *)cell
{
    [self.cellsCurrentlyEditing removeObject:[self.tableView indexPathForCell:cell]];
}

-(void)buttonDeleteActionClicked:(UIButton *)sender withCell:(ShowTemplateTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    TemplateModel *templateModel = (TemplateModel*)[self.templateArray objectAtIndex:indexPath.row];
    [self deleteATemplate:templateModel];
    [self.templateArray removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}
-(void)deleteATemplate:(TemplateModel*)templateModel
{
    NSString *dID = templateModel.dID;
    NSString *templateID = templateModel.templateID;
    NSString *templateType = templateModel.templateType;
    
    
    [MessageObject messageObjectWithUsrStr:@"2225" pwdStr:@"test" iHMsgSocket:self.socket optInt:2004 dictionary:@{@"id":templateID,@"did":dID,@"mbbh":templateType} block:^(IHSockRequest *request) {
        
        if (request.resp == 0) {
            
        }else {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"模板删除失败" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//            [alert show];
        }
        
    } failConection:^(NSError *error) {
        
    }];
}
-(void)buttonMoreActionClicked:(UIButton *)sender withCell:(ShowTemplateTableViewCell *)cell
{
    
}
-(void)buttonShareActionClicked:(UIButton *)sender withCell:(ShowTemplateTableViewCell *)cell
{
    if ([sender.titleLabel.text isEqualToString:@""]) {
        
    }
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    TemplateModel *templateModel = (TemplateModel*)[self.templateArray objectAtIndex:indexPath.row];
    
    UIStoryboard *myStoryBoard = self.storyboard;
    UINavigationController *shareRangeVC = [myStoryBoard instantiateViewControllerWithIdentifier:@"SelectedShareRangeNav"];
    SelectedShareRangeViewController *rangeVC = (SelectedShareRangeViewController*)[shareRangeVC.viewControllers firstObject];
    rangeVC.selectedTemplates = [[NSMutableArray alloc] initWithArray:@[templateModel]];
    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:shareRangeVC];
    
    CGRect frame = [cell convertRect:sender.frame toView:self.view];
    
    CGRect rectMake = frame;
    rectMake.origin.y += rectMake.size.height/2;
    [popover presentPopoverFromRect:rectMake inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
}
-(void)buttonIgnoreActionClicked:(UIButton *)sender withCell:(ShowTemplateTableViewCell *)cell
{
    
}
-(void)buttonAcceptActionClicked:(UIButton *)sender withCell:(ShowTemplateTableViewCell *)cell
{
    
}
-(void)buttonCancellationOfShareActionClicked:(UIButton *)sender withCell:(ShowTemplateTableViewCell *)cell
{
    
}
-(void)dealloc
{
   
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

///helper
-(NSString*)getYearAndMonthWithDateStr:(NSDate*)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM"];
    
    NSString *dateStr = [formatter stringFromDate:date];
    
    NSLog(@"date : %@",dateStr);
    
    return dateStr;
}
-(NSString*)getDayWithDateStr:(NSDate*)date
{
    NSString *dayStr ;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd"];
    
    dayStr = [formatter stringFromDate:date];
    return dayStr;
}
-(NSString*)getMonthWithDateStr:(NSDate*)date
{
    NSString *monthStr ;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEE"];
//[formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    monthStr = [formatter stringFromDate:date];
    return monthStr;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"templateDetail"]) {
        ShowTemplateDetailViewController *templateDetailVC = (ShowTemplateDetailViewController*)segue.destinationViewController;
        templateDetailVC.templateModel = self.templateModel;
    }
    
    if ([segue.identifier isEqualToString:@"ShareVCSegue"]) {
        UINavigationController *nav = (UINavigationController*)segue.destinationViewController;
        SelectASharedTemplateViewController *sharedVC = (SelectASharedTemplateViewController*)[nav.viewControllers firstObject];
        sharedVC.templateType = self.templateType;
    }
}
@end
