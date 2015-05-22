//
//  ModelPlateConditionDetailViewController.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/15.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "ModelPlateConditionDetailViewController.h"

@interface ModelPlateConditionDetailViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>

@property (nonatomic) BOOL isHideSearchBar;
@property (nonatomic,strong) IHMsgSocket *socket;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchBarHeightConstraints;
@property (nonatomic,strong) CoreDataStack *coreDataStack;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navbarHeightConstraints;
@property (weak, nonatomic) IBOutlet UINavigationBar *navationBar;
@property (nonatomic,strong) NSArray *dataArray;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) NSInteger numberOfPage;

@property (nonatomic) NSInteger searchNumberOfPage;
@property (nonatomic) BOOL isSearchEnabled;
@property (nonatomic,strong) NSString *searchText;

@property (nonatomic) BOOL stopPageLoad;
@property (nonatomic,strong) NSMutableOrderedSet *orderSet;
@end

@implementation ModelPlateConditionDetailViewController
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

- (IBAction)canceClicked:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)saveClicked:(UIBarButtonItem *)sender
{
    
}
-(NSDictionary*)optNumber
{
    return @{@"diagnose":@(2000),@"mainSymptom":@(2001),@"acompanySymptom":@(2002)};
}
-(NSMutableOrderedSet *)orderSet
{
    
    if ([self.selectedNode.nodeEnglish isEqualToString:@"gender"]) {
        _orderSet = [[NSMutableOrderedSet alloc] initWithArray:@[@"男",@"女"]];
        self.searchBarHeightConstraints.constant = 10;
        self.searchBar.hidden  =YES;
        self.navationBar.hidden = YES;
        self.navbarHeightConstraints.constant = 10;
        self.activityIndicator.hidden = YES;
    }else {
        if (!_orderSet) {
            _orderSet = [[NSMutableOrderedSet alloc] init];
        }
    }
    
    return _orderSet;
}
//-(NSArray *)dataArray
//{
//   
//    if ([self.selectedNode.nodeEnglish isEqualToString:@"diagnose"]) {
//        
//        self.numberOfPage = 1;
//        
//        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
//        //[dic setObject:@"" forKey:@"key"];
//        [dic setObject:@(self.numberOfPage) forKey:@"page"];
//        
//        NSNumber *optInt = [[self optNumber] objectForKey:self.selectedNode.nodeEnglish];
//        [MessageObject messageObjectWithUsrStr:@"1" pwdStr:@"test" iHMsgSocket:self.socket optInt:IntValue(optInt) dictionary:dic block:^(IHSockRequest *request) {
//            
//            if ([request.responseData isKindOfClass:[NSArray class]]) {
//                
//                NSArray *tempA = (NSArray*)request.responseData;
//                if (tempA.count == 0) {
//                   // self.stopPageLoad = YES;
//                }
//                for (id tempID in tempA) {
//                    if ([tempID isKindOfClass:[NSDictionary class]]){
//                        
//                        NSDictionary *dic = (NSDictionary*)tempID;
//                        NSString *keyStr;
//                    
//                        if ([dic.allKeys containsObject:keyStr]) {
//                            [self.orderSet addObject:@"disease_name"];
//                        }
//                    }
//                    
//                }
//            }
//            
//        } failConection:^(NSError *rerro) {
//            
//        }];
//    }
//    if ([self.selectedNode.nodeEnglish isEqualToString:@"mainSymptom"]) {
//        
//    }
//    if ([self.selectedNode.nodeEnglish isEqualToString:@"acompanySymptom"]){
//        
//    }
//    return _dataArray;
//}

-(NSManagedObjectContext *)managedObjectContext
{
    return self.coreDataStack.managedObjectContext;
}
-(CoreDataStack *)coreDataStack
{
    _coreDataStack = [[CoreDataStack alloc] init];
    return _coreDataStack;
}
-(void)loadDataFromServer
{
    
}
#pragma mask - view life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.numberOfPage = 1;
    [self fromServerGetData];

}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = [NSString stringWithFormat:@"选择%@",self.selectedNode.nodeName];
    
}

#pragma mask -m load data from server
-(void)fromServerGetData
{
    if ([self.selectedNode.nodeEnglish isEqualToString:@"diagnose"]) {
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        if (self.isSearchEnabled) {
            [dic setObject:self.searchText forKey:@"key"];
        }else {
            [dic setObject:@"" forKey:@"key"];
        }
        [dic setObject:@(self.numberOfPage) forKey:@"page"];
        
        NSNumber *optInt = [[self optNumber] objectForKey:self.selectedNode.nodeEnglish];
        [MessageObject messageObjectWithUsrStr:@"1" pwdStr:@"test" iHMsgSocket:self.socket optInt:IntValue(optInt) dictionary:dic block:^(IHSockRequest *request) {
            
            if ([request.responseData isKindOfClass:[NSArray class]]) {
                
                NSArray *tempA = (NSArray*)request.responseData;
                if (tempA.count == 0) {
                    self.stopPageLoad = YES;
                }
                for (id tempID in tempA) {
                    if ([tempID isKindOfClass:[NSDictionary class]]){
                        
                        NSDictionary *dic = (NSDictionary*)tempID;
                        NSString *keyStr = @"disease_name";
                        
                        if ([dic.allKeys containsObject:keyStr]) {
                            [self.orderSet addObject:dic[keyStr]];
                        }
                    }
                }
            }
            [self.tableView reloadData];
        } failConection:^(NSError *rerro) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"服务器端出错" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];

        }];
    }
    
    if ([self.selectedNode.nodeEnglish isEqualToString:@"mainSymptom"]) {
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        if (self.isSearchEnabled) {
            [dic setObject:@"" forKey:@"ks"];
            [dic setObject:self.searchText forKey:@"name"];
        }else {
            [dic setObject:@"" forKey:@"ks"];
            [dic setObject:@"" forKey:@"name"];
        }
        [dic setObject:@(self.numberOfPage) forKey:@"page"];
        
        NSNumber *optInt = [[self optNumber] objectForKey:self.selectedNode.nodeEnglish];
        [MessageObject messageObjectWithUsrStr:@"1" pwdStr:@"test" iHMsgSocket:self.socket optInt:IntValue(optInt) dictionary:dic block:^(IHSockRequest *request) {
            
            if ([request.responseData isKindOfClass:[NSArray class]]) {
                
                NSArray *tempA = (NSArray*)request.responseData;
                if (tempA.count == 0) {
                    self.stopPageLoad = YES;
                }
                for (id tempID in tempA) {
                    if ([tempID isKindOfClass:[NSDictionary class]]){
                        
                        NSDictionary *dic = (NSDictionary*)tempID;
                        NSString *keyStr = @"symptom_name";
                        
                        if ([dic.allKeys containsObject:keyStr]) {
                            [self.orderSet addObject:dic[keyStr]];
                        }
                    }
                }
            }
            [self.tableView reloadData];
        } failConection:^(NSError *rerro) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"服务器端出错" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];

        }];
    }
    if ([self.selectedNode.nodeEnglish isEqualToString:@"acompanySymptom"]){
        
        self.searchBarHeightConstraints.constant = 10;
        self.searchBar.hidden  =YES;
        self.stopPageLoad = YES;
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        
        [dic setObject:self.selectedMainNode.nodeContent forKey:@"symptom_name"];
       // [dic setObject:@(self.numberOfPage) forKey:@"page"];
        
        NSNumber *optInt = [[self optNumber] objectForKey:self.selectedNode.nodeEnglish];
        [MessageObject messageObjectWithUsrStr:@"1" pwdStr:@"test" iHMsgSocket:self.socket optInt:IntValue(optInt) dictionary:dic block:^(IHSockRequest *request) {
            
            if ([request.responseData isKindOfClass:[NSArray class]]) {
                
                NSArray *tempA = (NSArray*)request.responseData;
                if (tempA.count == 0) {
                    self.stopPageLoad = YES;
                }
                for (id tempID in tempA) {
                    if ([tempID isKindOfClass:[NSDictionary class]]){
                        
                        NSDictionary *dic = (NSDictionary*)tempID;
                        NSString *keyStr = @"sub_symptoms";
                        
                        if ([dic.allKeys containsObject:keyStr]) {
                            [self.orderSet addObject:dic[keyStr]];
                        }
                    }
                }
            }
            [self.tableView reloadData];
        } failConection:^(NSError *rerro) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"服务器端出错" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];

        }];
    }
}
#pragma mask -search bar delegate
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    if ([searchBar isFirstResponder]) {
        [searchBar resignFirstResponder];
    }
    self.searchText = @"";
    searchBar.text = @"";
    [self.searchBar setShowsCancelButton:NO animated:YES];
    
    self.numberOfPage = 1;
    self.isSearchEnabled =  NO;
    self.isSearchEnabled = NO;
    
    [self fromServerGetData];
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
    self.searchText = searchBar.text;
    [self fromServerGetData];
}

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [self.searchBar setShowsCancelButton:YES animated:YES];

    self.orderSet = nil;
    self.numberOfPage = 1;
    self.isSearchEnabled = YES;
    self.isSearchEnabled = YES;

    return YES;
}

#pragma mask -m table view data source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   return self.orderSet.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"conditionsCell"];
    UIView *selectedbackgroundView = [[UIView alloc] initWithFrame:cell.bounds];
    selectedbackgroundView.backgroundColor = [UIColor orangeColor];
    [cell setSelectedBackgroundView:selectedbackgroundView];
    
    cell.textLabel.text = [self.orderSet objectAtIndex:indexPath.row];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *selectedItem = [self.orderSet objectAtIndex:indexPath.row];
    self.selectedNode.nodeContent = selectedItem;
    
    [self.coreDataStack saveContext];
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        
        if (indexPath.row == self.orderSet.count-1) {
            
            if (!self.stopPageLoad) {
                self.numberOfPage += 1;
//                if (self.isSearchEnabled) {
//                    self.searchNumberOfPage += 1;
//                }
                [self fromServerGetData];

            }
        }
    }
}

@end
