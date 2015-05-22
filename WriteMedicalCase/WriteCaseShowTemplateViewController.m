//
//  WriteCaseShowTemplateViewController.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/4/30.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "WriteCaseShowTemplateViewController.h"
#import "WriteCaseShowTemplateCell.h"
#import "RWLabel.h"
#import "TemplateDetailViewController.h"

@interface WriteCaseShowTemplateViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>


@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,strong) NSString *titleStr;

@property (nonatomic,strong) IHMsgSocket *socket;

@property (nonatomic,strong) WLKCaseNode *currentNode;

@property (nonatomic,strong) NSDictionary *sendDataDic;

@property (nonatomic,strong) NSString *doctorID;


@property (nonatomic,strong) TemplateModel *currentTemplateModel;

@property (nonatomic,strong) NSString *searchText;
@property (nonatomic,strong) NSMutableArray *searchDataArray;
@property (nonatomic) BOOL searchFlag;

@property (nonatomic,strong) NSMutableArray *tempArray;


@property (nonatomic,strong) NSMutableArray *templateArray;
@end

@implementation WriteCaseShowTemplateViewController

#pragma mask - socket
-(IHMsgSocket *)socket
{
    if (!_socket) {
        _socket = [IHMsgSocket sharedRequest];
        [_socket connectToHost:@"192.168.10.106" onPort:2323];
    }
    return _socket;
}


#pragma mask - property
-(void)setUpTableView
{
    self.tableView.layer.shadowOffset = CGSizeMake(15, 13);
    self.tableView.layer.shadowOpacity = 1;
    self.tableView.layer.shadowRadius = 20;
    self.tableView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    
    self.tableView.layer.borderWidth = 1;

}
-(void)refreshTableViewData:(UIRefreshControl*)refreshControl
{
    [self getTemplateWithSearchText:nil];
}
-(NSString *)doctorID
{
    if (!_doctorID) {
        _doctorID = [[NSUserDefaults standardUserDefaults] objectForKey:@"doctorID"];
    }
    return _doctorID;
}
-(NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}
-(NSMutableArray *)searchDataArray
{
    if (!_searchDataArray) {
        _searchDataArray = [[NSMutableArray alloc] init];
    }
    return _searchDataArray;
}
-(NSMutableArray *)tempArray
{
    if (!_tempArray) {
        _tempArray = [[NSMutableArray alloc] init];
    }
    return _tempArray;
}
-(void)setTemplateName:(NSString *)templateName
{
    _templateName = templateName;
    
    NSString *dID = [[NSUserDefaults standardUserDefaults] objectForKey:@"dID"];
    NSString  *templateType =[NSString stringWithFormat:@"%@",[self getMBBHWithEnglishName:_templateName]];
    self.templateArray = [[NSMutableArray alloc] init];
    
    [MessageObject messageObjectWithUsrStr:@"2216" pwdStr:@"test" iHMsgSocket:self.socket optInt:2003 dictionary:@{@"id":dID,@"mbbh":templateType} block:^(IHSockRequest *request) {
        
        if ([request.responseData isKindOfClass:[NSArray class]]) {
            NSArray *tempArray = (NSArray*)request.responseData;
            
            for (NSDictionary *dict in tempArray) {
                TemplateModel *templateModel = [[TemplateModel alloc] initWithDic:dict];
                [self.templateArray addObject:templateModel];
            }
            // self.spinner.hidden = YES;
            [self.tableView reloadData];
        }
    } failConection:^(NSError *error) {
        // self.spinner.hidden = YES;
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

#pragma mask - view controller life cycle
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    /// set title
    NSString *titleStr = [self.templateName stringByAppendingString:@"模板"];
    self.title = titleStr;

}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpTableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectedCellLabel:) name:@"didSelectedTitleLabel" object:nil];
}
-(void)didSelectedCellLabel:(NSNotification*) notification
{
    id tempID = [notification object];
    if ([tempID isKindOfClass:[NSString class]]) {
        self.templateName = (NSString*)tempID;
    }else if([tempID isKindOfClass:[WLKCaseNode class]]){
        WLKCaseNode *tempNode =(WLKCaseNode*) [notification object];
        self.templateName = tempNode.nodeName;
    }
    
    NSString *titleStr = [self.templateName stringByAppendingString:@"模板"];
    self.title = titleStr;
    
}


-(NSDate*)getSystemCurrentTime
{
    NSDate *newDate = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSTimeInterval interval = [zone secondsFromGMTForDate:newDate];
    NSDate *localDate = [newDate dateByAddingTimeInterval:interval];
    
    return localDate;
}

#pragma mask - set server parameter
-(NSDictionary *)sendDataDic
{
    NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
    
    
    _sendDataDic = [NSDictionary dictionaryWithDictionary:tempDic];
    
    return _sendDataDic;
}
#pragma mask - load data from server
-(void)getTemplateWithSearchText:(NSString*)searchText;
{
    //设置搜索文本
    if (searchText) {
        [self.sendDataDic setValue:searchText forKey:@"searchText"];
    }
    
    [self getTemplateWithDoctorID:self.doctorID templateName:(NSString *)self.templateName];
}
-(void)getTemplateWithDoctorID:(NSString*)doctorID templateName:(NSString*)templateName
{
    RawDataProcess *rawData = [RawDataProcess sharedRawData];
    WLKCaseNode *tempNode = [WLKCaseNode getSubNodeFromNode:rawData.rootNode withNodeName:templateName resultNode:nil ];
    self.currentNode = tempNode;
    
//    [MessageObject messageObjectWithUsrStr:@"1" pwdStr:@"test" iHMsgSocket:self.socket optInt:10001 dictionary:self.sendDataDic block:^(IHSockRequest *request) {
//        
//        //self.dataArray =
//        [self.tableView reloadData];
//        [self.refreshControl endRefreshing];
//    } failConection:^(NSError *error) {
//        
//        self.sendDataDic = nil;
//        [self.tableView reloadData];
//        [self.refreshControl endRefreshing];
//    }];
}

#pragma mask - table view delegate && data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searchFlag) {
        self.tempArray = [NSMutableArray arrayWithArray:self.searchDataArray];
    }else {
        self.tempArray = [NSMutableArray arrayWithArray:self.templateArray];
    }
    
    return  self.tempArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WriteCaseShowTemplateCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WriteShowTemplate"];
    [self configureCell:cell AtIndexPath:indexPath];
    
    return cell;
}
-(void)configureCell:(WriteCaseShowTemplateCell*)cell AtIndexPath:(NSIndexPath*)indexPath
{
    TemplateModel *templateModel = [self.tempArray objectAtIndex:indexPath.row];
    
    cell.accessoryType  = UITableViewCellAccessoryDetailButton;

    cell.sourcelabel.text = templateModel.sourceType;//来源个人，科室
    cell.createPeopleLabel.text = templateModel.createPeople;
    

    NSString *content;
    if (templateModel.content.length > 100) {
        content = [NSString stringWithFormat:@"%@...", [templateModel.content substringToIndex:100]];
    }else {
        content = templateModel.content;
    }

    cell.contentLabel.text  = templateModel.content;
}
-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    ///查看模板的详细内容
    TemplateModel *templateModel = [self.tempArray objectAtIndex:indexPath.row];

    self.currentTemplateModel = templateModel;
    
    [self performSegueWithIdentifier:@"templateContent" sender:nil];

}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TemplateModel *templateModel = [self.tempArray objectAtIndex:indexPath.row];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.showTemplateDelegate didSelectedTemplateWithNode:templateModel withTitleStr:self.templateName];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self heightForBasicCellAtIndexPath:indexPath];
}
- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath {
    static WriteCaseShowTemplateCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [self.tableView dequeueReusableCellWithIdentifier:@"WriteShowTemplate"];
    });
    
    [self configureCell:sizingCell AtIndexPath:indexPath];
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

#pragma mask -search
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    if ([searchBar isFirstResponder]) {
        [searchBar resignFirstResponder];
    }
    self.searchText = @"";
    [self.searchBar setShowsCancelButton:NO animated:YES];
    
    //[self setUpFetchViewControllerWithSearchText:nil];

}
-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    [self.searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
     self.searchText = searchBar.text;
    
   // [self setUpFetchViewControllerWithSearchText:searchText];
}
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
   // [self setUpFetchViewControllerWithSearchText:searchText];

    
}

#pragma mask - segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"templateContent"]) {
        TemplateDetailViewController *templateVC = (TemplateDetailViewController*)segue.destinationViewController;
        templateVC.templateModel = self.currentTemplateModel;
    }
}

@end
