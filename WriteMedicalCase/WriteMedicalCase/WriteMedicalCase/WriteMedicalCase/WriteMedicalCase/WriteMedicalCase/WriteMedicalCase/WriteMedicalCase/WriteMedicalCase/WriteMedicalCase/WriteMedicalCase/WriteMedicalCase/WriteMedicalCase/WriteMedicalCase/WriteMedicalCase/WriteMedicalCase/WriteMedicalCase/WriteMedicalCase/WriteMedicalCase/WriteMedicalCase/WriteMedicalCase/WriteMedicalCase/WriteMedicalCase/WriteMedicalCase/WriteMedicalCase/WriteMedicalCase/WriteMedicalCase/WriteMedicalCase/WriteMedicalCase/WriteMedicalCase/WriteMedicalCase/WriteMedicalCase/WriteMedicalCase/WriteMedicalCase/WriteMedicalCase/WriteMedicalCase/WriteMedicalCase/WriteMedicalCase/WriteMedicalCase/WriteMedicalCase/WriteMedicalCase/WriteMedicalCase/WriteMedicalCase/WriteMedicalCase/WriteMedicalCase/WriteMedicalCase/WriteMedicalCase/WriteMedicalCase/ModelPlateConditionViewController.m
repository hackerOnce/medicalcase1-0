//
//  ModelPlateConditionViewController.m
//  MedicalCase
//
//  Created by ihefe-JF on 15/4/2.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import "ModelPlateConditionViewController.h"
#import "Constants.h"
#import "CKHttpClient.h"
#import "IHMsgSocket.h"
#import "MessageObject+DY.h"
#import "IHMsgSocket.h"
#import "MessageObject+DY.h"

@interface ModelPlateConditionViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchControllerDelegate,UISearchDisplayDelegate>
@property (nonatomic,strong) CKHttpClient *httpClient;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) UISearchDisplayController *strongSearchDisplayController;
@property (nonatomic) BOOL loadMoreFlag;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *adjustTableViewConstraints;

@property (nonatomic,strong) NSMutableArray *filterArray;

@property (nonatomic,strong) NSDictionary *keyDic;
@property (nonatomic,strong) UIRefreshControl *refreshControl;

@property (nonatomic,strong) NSMutableOrderedSet *resultOrderSet;

@property (nonatomic,strong) NSMutableDictionary *searchParameter;
@property (nonatomic) BOOL isSearchEnabled;

@property (nonatomic,strong) NSString *searchText;
@property (nonatomic,strong) NSDictionary *searchKeyDic;

@property (nonatomic,strong) UIActivityIndicatorView *searchIndicatorView;

@property (nonatomic,strong) NSString *loadURLStrNextPage;
@property (nonatomic) int numberOfPage;

@property (nonatomic) BOOL searchResultCountIsZero;
@property (nonatomic) BOOL willSelecteSubSymptom;
@property (nonatomic,strong) IHMsgSocket *socket;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic,strong) NSDictionary *optIntDic;
@property (nonatomic,strong) NSDictionary *optKeyDic;

@property (nonatomic) BOOL stopPageLoad;
@end

@implementation ModelPlateConditionViewController
@synthesize httpClient = _httpClient;
- (IBAction)conditionSaveBtn:(UIBarButtonItem *)sender {
    
    
}
-(int)numberOfPage
{
    if (!_numberOfPage) {
        _numberOfPage = 1;
    }
    return _numberOfPage;
}


-(IHMsgSocket *)socket
{
    if (!_socket) {
        _socket = [IHMsgSocket sharedRequest];
        [_socket connectToHost:@"192.168.10.106" onPort:2323];
    }
    return _socket;
}


-(NSMutableArray *)filterArray
{
    if (!_filterArray) {
        _filterArray = [[NSMutableArray alloc] init];
    }
    return _filterArray;
}
-(NSString *)loadURLStrNextPage
{
   // if (!_loadURLStrNextPage) {
   // _loadURLStrNextPage = [self.loadURLStr stringByAppendingString:[NSString stringWithFormat:@"?page=%@",@(self.numberOfPage)]];
   // }
    _loadURLStrNextPage = [self.loadURLStr stringByAppendingString:[NSString stringWithFormat:@"%@",@(self.numberOfPage)]];

    return _loadURLStrNextPage;
}
-(NSDictionary *)searchKeyDic
{
   // if (!_searchKeyDic) {
        _searchKeyDic = @{@"diseases":@"key",@"symptoms": self.isSearchEnabled?@"name":@"ks",@"sub_symptoms":@"name"};
   // }
    return _searchKeyDic;
}

-(NSDictionary *)optIntDic
{
    if (!_optIntDic) {
        _optIntDic = @{@"diseases":@(2000),@"symptoms":@(2001),@"sub_symptoms":@(2002)};
    }
    return _optIntDic;
}
-(NSDictionary *)optKeyDic
{
    if (!_optKeyDic) {
        _optKeyDic = @{@"diseases":@"disease_name",@"symptoms":@"symptom_name",@"sub_symptoms":@"sub_symptoms"};
    }
    return _optKeyDic;
}
-(void)setSearchText:(NSString *)searchText
{
    if (![searchText isEqualToString:@""]) {
        _searchText = searchText;

        if (self.willSelecteSubSymptom) {
            [self.searchParameter setObject:searchText forKey:[self.searchKeyDic objectForKey:self.subSymptom]];
        }else {
            [self.searchParameter setObject:searchText forKey:[self.searchKeyDic objectForKey:self.loadURLStr]];
        }
        
        [self loadDataFromServer];

    }
//    NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
//    ;
//   // if (self.willSelecteSubSymptom) {
//        [tempDic setObject:searchText forKey:[self.searchKeyDic objectForKey:self.loadURLStr]];
//  //  }else {
//   //     [tempDic setObject:searchText forKey:[self.searchKeyDic objectForKey:self.subSymptom]];
//   // }
//    NSData *json = [NSJSONSerialization dataWithJSONObject:tempDic options:NSJSONWritingPrettyPrinted error:nil];
//        NSString *jsonStr = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
//    [self.searchParameter setObject:jsonStr forKey:@"where"];
}
-(NSMutableDictionary *)searchParameter
{
    if (!_searchParameter) {
        _searchParameter = [[NSMutableDictionary alloc] init];
        
        
//        if (self.willSelecteSubSymptom) {
//            //only for 伴随症状
//            [_searchParameter setObject:self.symptomName forKey:self.subSymptom];
//        }

    }
    if (!self.isSearchEnabled){
        if (self.willSelecteSubSymptom) {
            
        }else {
            [_searchParameter setObject:@(self.numberOfPage) forKey:@"page"];
            [_searchParameter setObject:@"" forKey:[self.searchKeyDic objectForKey:self.loadURLStr]];
        }
        
    }

    return _searchParameter;
}
-(NSMutableOrderedSet *)resultOrderSet
{
    if(!_resultOrderSet){
        _resultOrderSet = [[NSMutableOrderedSet alloc] init];
    }
    
    return _resultOrderSet;
}
-(NSDictionary *)keyDic
{
    if (!_keyDic) {
        _keyDic = @{@"diseases":@"disease_name",@"symptoms":@"symptom_name",@"sub_symptoms":@"sub_symptoms"};
    }
    return _keyDic;
}
-(NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

-(void)setLoadURLStr:(NSString *)loadURLStr
{
    _loadURLStr = loadURLStr;
    self.numberOfPage = 1;
    if (self.willSelecteSubSymptom) {
        self.searchText = self.symptomName;
    }else {
        [self loadDataFromServer];
    }
}
-(void)setSymptomName:(NSString *)symptomName
{
    _symptomName = symptomName;
    self.willSelecteSubSymptom = YES;

}
-(void)loadDataFromServer
{
    
    [MessageObject messageObjectWithUsrStr:@"1" pwdStr:@"test" iHMsgSocket:self.socket optInt:[[self.optIntDic objectForKey: self.subSymptom ? self.subSymptom:self.loadURLStr] integerValue] dictionary:self.searchParameter block:^(IHSockRequest *request) {
        
        if ([request.responseData isKindOfClass:[NSArray class]]) {
            
            NSArray *tempA = (NSArray*)request.responseData;
            if (tempA.count == 0) {
                self.stopPageLoad = YES;
            }
            for (id tempID in tempA) {
                if ([tempID isKindOfClass:[NSDictionary class]]){
                    
                    NSDictionary *dic = (NSDictionary*)tempID;
                    NSString *keyStr;
                    if (self.willSelecteSubSymptom) {
                        keyStr = [self.keyDic objectForKey:self.subSymptom];
                    }else {
                        keyStr = [self.keyDic objectForKey:self.loadURLStr];
                    }
                    if ([dic.allKeys containsObject:keyStr]) {
                        [self.resultOrderSet addObject:dic[keyStr]];
                    }
                }
 
            }
        }else {
            [self.activityIndicator stopAnimating];

            NSLog(@"result is not a array");
            abort();
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.isSearchEnabled) {
                self.filterArray = [self.resultOrderSet.array mutableCopy];
                [self.searchDisplayController.searchResultsTableView reloadData];
            }else {
//                if (self.searchBar.hidden) {
//                    self.searchBar.hidden = NO;
//                }
                self.dataSource = [self.resultOrderSet.array mutableCopy];
                if ([self.refreshControl isRefreshing]) {
                    [self.refreshControl endRefreshing];
                }

                [self.tableView reloadData];
                [self.activityIndicator stopAnimating];

            }
        });

              //NSString *str = [[NSString alloc] ;
        
        NSLog(@"success");
        
    } failConection:^(NSError *error) {
        
        if ([self.refreshControl isRefreshing]) {
                [self.refreshControl endRefreshing];
            }
    
            if ([self.searchIndicatorView isAnimating]) {
                [self.searchIndicatorView  stopAnimating];
            }
    
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"服务器端出错" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];


        [self.activityIndicator stopAnimating];
         NSLog(@"error");
    }];
    
//    [self.httpClient GET:self.isSearchEnabled?self.loadURLStr : self.loadURLStrNextPage parameters:(self.isSearchEnabled || self.willSelecteSubSymptom) ? self.searchParameter: nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        if ([responseObject isKindOfClass:[NSDictionary class]]) {
//            NSDictionary *tempDic = (NSDictionary*)responseObject[@"_items"];
//            
//            if (tempDic.count == 0) {
//              self.searchResultCountIsZero = NO;
//            }
//            for (id tempID in tempDic) {
//                if ([tempID isKindOfClass:[NSDictionary class]]) {
//                    NSDictionary *tempDic = (NSDictionary*)tempID;
//                    NSString *keyStr;
//                    if (self.willSelecteSubSymptom) {
//                        keyStr = [self.keyDic objectForKey:self.subSymptom];
//                    }else {
//                       keyStr = [self.keyDic objectForKey:self.loadURLStr];
//                    }
//                    
//                    if ([tempDic.allKeys containsObject:keyStr]) {
//                        [self.resultOrderSet addObject:tempDic[keyStr]];
//                    }
//                }
//            }
//        }
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (self.isSearchEnabled) {
//                self.filterArray = [self.resultOrderSet.array mutableCopy];
//                [self.searchDisplayController.searchResultsTableView reloadData];
//            }else {
////                if (self.searchBar.hidden) {
////                    self.searchBar.hidden = NO;
////                }
//                self.dataSource = [self.resultOrderSet.array mutableCopy];
//                if ([self.refreshControl isRefreshing]) {
//                    [self.refreshControl endRefreshing];
//                }
//
//                [self.tableView reloadData];
//                
//            }
//        });
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        if ([self.refreshControl isRefreshing]) {
//            [self.refreshControl endRefreshing];
//        }
// 
//        if ([self.searchIndicatorView isAnimating]) {
//            [self.searchIndicatorView  stopAnimating];
//        }
//        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"服务器出错，请联系申" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alert show];
//
//    }];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.loadURLStr) {
        [self setSearchDisplayController];
        // [self setSearchBarBackground];
        [self setUpRefreshControl];
    }
    self.numberOfPage = 1;
    self.stopPageLoad = NO;
    [self setTableView];

    [self.activityIndicator startAnimating];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.hideSearchBar) {
        self.adjustTableViewConstraints.constant = -44;
    }
    [self.tableView setContentOffset:CGPointMake(0, 100)];

}

#pragma mask - set search display controller
-(void)setSearchDisplayController
{
    self.strongSearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.strongSearchDisplayController.searchResultsDataSource = self;
    self.strongSearchDisplayController.searchResultsDelegate = self;
    self.strongSearchDisplayController.delegate = self;
    
    [self.strongSearchDisplayController.searchResultsTableView setTableFooterView:[[UIView alloc] init]];
    [self.strongSearchDisplayController.searchResultsTableView setBackgroundColor:[UIColor whiteColor]];
    self.searchBar.autoresizingMask = UIViewAutoresizingNone;
    self.strongSearchDisplayController.searchResultsTableView.autoresizesSubviews = NO;
}
-(void)handData
{
//    self.searchBar.hidden = YES;
    self.loadMoreFlag = NO;
    self.isSearchEnabled = NO;
    self.numberOfPage = 1;
    self.stopPageLoad = NO;
    [self loadDataFromServer];
}

-(void)setUpRefreshControl
{
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"正在更新数据,请稍候"];
    [self.refreshControl addTarget:self action:@selector(handData) forControlEvents:UIControlEventValueChanged];
    
    [self.tableView addSubview:self.refreshControl];
    
}

#pragma mask - set search bar
-(void)setSearchBarBackground
{
    self.searchBar.backgroundColor = [UIColor clearColor];
    
    UIView *searchBarView = [self.searchBar.subviews objectAtIndex:0];
    for (UIView *searchBarSubView in searchBarView.subviews) {
        if([searchBarSubView isKindOfClass:NSClassFromString(@"UISearchBarBackground")]){
            
            [searchBarSubView removeFromSuperview];
            break;
        }
        if([searchBarSubView isKindOfClass:NSClassFromString(@"UISearchBarTextField")]){
            //  searchBarSubView.backgroundColor = [UIColor colorWithRed:234.0/255 green:234.0/255 blue:234.0/255 alpha:1];
            searchBarSubView.backgroundColor = [UIColor clearColor];
        }
    }
}
#pragma mask - set table view
-(void)setTableView
{
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}


-(CKHttpClient *)httpClient
{
    if (!_httpClient) {
        _httpClient = [CKHttpClient getInstance];
    }
    return _httpClient;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return tableView == self.tableView ? self.dataSource.count :(self.searchResultCountIsZero ?self.filterArray.count + 1 : self.filterArray.count) ;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"conditionCell"];
        [self configCell:cell withIndexPath:indexPath];
        return cell;

    }else {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"searchCell"];
        
        }
        if (indexPath.row == self.filterArray.count) {
            self.searchIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            self.searchIndicatorView.center = cell.contentView.center;
            [cell.contentView addSubview:self.searchIndicatorView];
            tableView.separatorStyle = NO;
            cell.textLabel.text = @" ";
          }else {
            if ([self.searchIndicatorView isAnimating]) {
                [self.searchIndicatorView stopAnimating];
            }
            cell.textLabel.text = [self.filterArray objectAtIndex:indexPath.row];
            tableView.separatorStyle = YES;
        }
        return cell;

    }
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[self performSegueWithIdentifier:@"selectTemplateSecondSegue" sender:nil];
    if (tableView == self.tableView) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UILabel *cellabel = (UILabel*)[cell viewWithTag:1001];
        if ([[cellabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0) {
            
        }else {
            [self.conditionDelegate didSelectedStr:cellabel.text];
            [self.navigationController popViewControllerAnimated:NO];
        }
 
    }else {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [self.conditionDelegate didSelectedStr:cell.textLabel.text];
        [self.navigationController popViewControllerAnimated:NO];
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        return 45;
    }else {
        if (indexPath.row == self.filterArray.count) {
            return 150;
        }else {
            return 45;
        }
    }
}
-(void)configCell:(UITableViewCell*)cell withIndexPath:(NSIndexPath*)indexPath
{
    UILabel *cellabel = (UILabel*)[cell viewWithTag:1001];
    cellabel.text = [self.dataSource objectAtIndex:indexPath.row];
    
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        if (self.loadURLStr) {
            if (self.stopPageLoad && indexPath.row == self.dataSource.count -2 ) {
                self.numberOfPage += 1;
                [self loadDataFromServer];
            }
        }
    }
}
#pragma mask - search barpo
-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    self.stopPageLoad = NO;
    
    self.filterArray = [[NSMutableArray alloc] init];
    self.isSearchEnabled = YES;
    self.searchResultCountIsZero = YES;
    if (self.resultOrderSet) {
        self.resultOrderSet = nil;
    }
    return YES;
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.filterArray removeAllObjects];
    self.filterArray = nil;
}

#pragma mask - searchDisplayController delegate and other methods
-(void)filiterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    self.strongSearchDisplayController.searchResultsTableView.alpha = 1;
    [self.filterArray removeAllObjects];
    self.searchText = searchText;
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.patientString contains[c] %@",searchText];
    // self.filterArray = [NSMutableArray arrayWithArray:[self.modelsArray filteredArrayUsingPredicate:predicate]];
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if(![searchBar.text isEqualToString:@""]){
        [self filiterContentForSearchText:searchBar.text scope:[[self.searchBar scopeButtonTitles] objectAtIndex:[self.searchBar selectedScopeButtonIndex]]];
        [self.searchIndicatorView startAnimating];
    }
    
}
// delegate
-(void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
    [tableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [tableView setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
}

-(void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    controller.searchResultsTableView.alpha = 1;
}
-(void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    self.strongSearchDisplayController.searchResultsTableView.alpha = 0;
    
    // self.viewForSearchBar.alpha = 0;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
