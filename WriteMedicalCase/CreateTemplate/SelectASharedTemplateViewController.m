//
//  SelectASharedTemplateViewController.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/13.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "SelectASharedTemplateViewController.h"
#import "SelectedASharedTemplateTableViewCell.h"
#import "ShowTemplateDetailViewController.h"
#import "SelectedShareRangeViewController.h"

@interface SelectASharedTemplateViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic) BOOL isSearchEnabled;
@property (nonatomic,strong) IHMsgSocket *socket;

@property (nonatomic,strong) NSMutableArray *templateArray;

@property (nonatomic,strong) TemplateModel *templateModel;
@end

@implementation SelectASharedTemplateViewController
- (IBAction)cancelButtonClicked:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
-(NSMutableArray *)templateArray
{
    if (!_templateArray) {
        _templateArray = [[NSMutableArray alloc] init];
        

        NSDictionary *testDict = @{@"dID":@"2445",@"condition":@"条条件条件件",@"content":@"内容",@"createPeople":@"创建人",@"sourceType":@"个人"};
        TemplateModel *temp = [[TemplateModel alloc] initWithDic:testDict];
        [_templateArray addObject:temp];
    }
    return _templateArray;
}
-(IHMsgSocket *)socket
{
    if (!_socket) {
        _socket = [IHMsgSocket sharedRequest];
        [_socket connectToHost:@"192.168.10.106" onPort:2323];
    }
    return _socket;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpTableView];
    
    [self updateTableView];
}
-(void)setUpTableView
{
    [self.tableView setEditing:YES animated:NO];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.isSearchEnabled = NO;
}
-(void)updateTableView
{
    NSString *dID = [[NSUserDefaults standardUserDefaults] objectForKey:@"dID"];
    [MessageObject messageObjectWithUsrStr:@"2225" pwdStr:@"test" iHMsgSocket:self.socket optInt:2003 dictionary:@{@"id":dID,@"mbbh":[NSString stringWithFormat:@"%@",self.templateType]} block:^(IHSockRequest *request) {
        
        if ([request.responseData isKindOfClass:[NSArray class]]) {
            NSArray *tempArray = (NSArray*)request.responseData;
            
            if (tempArray.count == 0) {
                
            }else {
                for (NSDictionary *dict in tempArray) {
                    TemplateModel *templateModel = [[TemplateModel alloc] initWithDic:dict];
                    [self.templateArray addObject:templateModel];
                }
                [self.tableView reloadData];
 
            }
        }
    } failConection:^(NSError *error) {
    }];
    
}
#pragma mask - tableView delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.templateArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SelectedASharedTemplateTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SelectASharedTemplateCell"];
    
//    cell.accessoryType = UITableViewCellAccessoryDetailButton;
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}
-(void)configureCell:(SelectedASharedTemplateTableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    
    TemplateModel *templateModel = [self.templateArray objectAtIndex:indexPath.row];
    
    NSString *contentStr = templateModel.content;
    NSString *content;
    if (contentStr.length > 100) {
        content = [NSString stringWithFormat:@"%@...", [contentStr substringToIndex:100]];
    }else {
        content = contentStr;
    }
    cell.conditionLabel.text = templateModel.condition;
    cell.contentLabel.text = content;
    
   // [cell setEditing:YES animated:NO];
    [cell setEditingAccessoryType:UITableViewCellAccessoryDetailButton];
}
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert ;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self heightForBasicCellAtIndexPath:indexPath];
}
- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath {
    static SelectedASharedTemplateTableViewCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [self.tableView dequeueReusableCellWithIdentifier:@"SelectASharedTemplateCell"];
    });
    
    [self configureCell:sizingCell atIndexPath:indexPath];
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
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
   // self.templateModel = (TemplateModel*)[self.templateArray objectAtIndex:indexPath.row];
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    
    self.templateModel = (TemplateModel*)[self.templateArray objectAtIndex:indexPath.row];

    [self performSegueWithIdentifier:@"shareDetailSegue" sender:nil];
}


#pragma mask - search bar 

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    if ([searchBar isFirstResponder]) {
        [searchBar resignFirstResponder];
    }
    searchBar.text = @"";
    //self.searchText = @"";
    self.isSearchEnabled = NO;

    [self.searchBar setShowsCancelButton:NO animated:YES];
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if ([searchBar isFirstResponder]) {
        [searchBar resignFirstResponder];
    }
    self.isSearchEnabled = YES;
   // [self updateTableView];
}
-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    [self.searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}


#pragma mark - Navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"shareDetailSegue"]) {
        ShowTemplateDetailViewController *templateDetailVC = (ShowTemplateDetailViewController*)segue.destinationViewController;
        templateDetailVC.templateModel = self.templateModel;
    }
    
    if ([segue.identifier isEqualToString:@"presentDoctorListSegue"]) {
        
        UINavigationController *nav = (UINavigationController*)segue.destinationViewController;
        SelectedShareRangeViewController *sharedRange = (SelectedShareRangeViewController*)[nav.viewControllers firstObject];
        NSArray *tempArray  = [self.tableView indexPathsForSelectedRows];
        
        NSMutableArray *selectedTemplates = [[NSMutableArray alloc] init];
        for (NSIndexPath *indexPath in tempArray) {
            TemplateModel *templateModel = [self.templateArray objectAtIndex:indexPath.row];
            [selectedTemplates addObject:templateModel];
        }
        sharedRange.selectedTemplates =[NSMutableArray arrayWithArray:selectedTemplates];
    }
    
}


@end
