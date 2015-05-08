//
//  ViewController.m
//  MedicalCase
//
//  Created by ihefe-JF on 15/4/1.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import "CreateTemplateViewController.h"
#import "Constants.h"
#import "TemplateManagementViewController.h"
#import "HUDSubViewController.h"
#import "TemplateLeftDetailViewController.h"
#import "CoreDataStack.h"
#import "ParentNode.h"
#import "Node.h"
#import "Template.h"

#import "RawDataProcess.h"
#import "WLKCaseNode.h"

#import "CKHttpClient.h"
#import "IHMsgSocket.h"
#import "MessageObject+DY.h"

@interface CreateTemplateViewController () <UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveBtn;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSArray *dataArray;

@property (nonatomic,strong) NSMutableDictionary *dataDic;

@property (nonatomic,strong) NSIndexPath *currentIndexPath;

@property (nonatomic,strong) CoreDataStack *coreDataStack;

@property (nonatomic,strong) NSString *selectedStr;

@property (nonatomic,strong) Node *currentNode;

@property (nonatomic,strong) IHMsgSocket *socket;
@end

@implementation CreateTemplateViewController


#import "IHMsgSocket.h"
#import "MessageObject+DY.h"

-(IHMsgSocket *)socket
{
    if (!_socket) {
        _socket = [IHMsgSocket sharedRequest];
        [_socket connectToHost:@"192.168.10.106" onPort:2323];
    }
    return _socket;
}

-(CoreDataStack *)coreDataStack
{
    _coreDataStack = [[CoreDataStack alloc] init];
    return _coreDataStack;
}

-(NSArray *)dataArray
{
    if(!_dataArray){
        _dataArray = @[@"添加条件",@"添加内容"];
    }
    return _dataArray;
}
-(NSMutableDictionary *)dataDic
{
    if(!_dataDic){
        _dataDic = [[NSMutableDictionary alloc] init];
        NSArray *tempArray = @[@"添加条件",@"添加内容"];
        
        for (NSString *str in tempArray) {
            [_dataDic setObject:str forKey:str];
        }
    }
    return _dataDic;
}
- (IBAction)save:(UIBarButtonItem *)sender {
    
    [self performSegueWithIdentifier:@"unwindSegueFromCreateTemplateVCToSplitViewController" sender:nil];
   // [self.navigationController popViewControllerAnimated:YES];
}
-(void)setUpTableView
{
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
}
-(void)addNotificationObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectedCondition:) name:selectedModelResultString object:nil];
}
-(void)didSelectedCondition:(NSNotification*)info
{
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:didExcutePopoverConditionSegue];
    }];
    

    
    id strId = [info object];
//    if ([strId isKindOfClass:[NSString class]]){
//        NSString *str =(NSString*) strId;
//        self.title = str;
//    }
    if ([strId isKindOfClass:[Node class]]) {
        self.currentNode = (Node*)strId;
        self.title = self.currentNode.nodeName;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.conditionLabel = (UILabel*)[self.view viewWithTag:1001];
    [self setUpTableView];
    self.title = @"";
    [self addNotificationObserver];
    
    self.saveBtn.enabled = NO;
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:didExcutePopoverConditionSegue];

}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(self.conditionLabelStr && self.currentIndexPath) {
        
    }else {
        
    }
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.title == nil || [self.title isEqualToString:@""]) {
       [self performSegueWithIdentifier:@"popoverConditionSegue" sender:nil];
    }
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RightViewCell"];
    [self configCell:cell withIndexPath:indexPath];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.currentIndexPath = indexPath;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UILabel *cellLabel = (UILabel*)[cell viewWithTag:1001];
    if (indexPath.row == 0) {
        [self performSegueWithIdentifier:@"conditionSegue" sender:nil];
    }else {
        self.selectedStr = cellLabel.text;
        [self performSegueWithIdentifier:@"contentSegue" sender:nil];
    }
}
-(void)configCell:(UITableViewCell*)cell withIndexPath:(NSIndexPath*)indexPath
{
    UILabel *cellLabel = (UILabel*)[cell viewWithTag:1001];
    NSString *tempStr = [self.dataArray objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cellLabel.text = [self.dataDic objectForKey:tempStr];

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"unwindSegueFromCreateTemplateVCToSplitViewController"]){
        NSString *condition = [self.dataDic objectForKey:@"添加条件"];
        NSString *content = [self.dataDic objectForKey:@"添加内容"];
        
//        if ([condition isEqualToString:@"添加条件"] || [content isEqualToString:@"添加内容"] ) {
//        }else {
//            [self saveTemplateToCoreData];
//        }
        [self saveTemplateToCoreData];

        
    }else if([segue.identifier isEqualToString:@"contentSegue"]){
        HUDSubViewController *hubVC = (HUDSubViewController*)segue.destinationViewController;
        hubVC.detailCaseNode = [self getSelectedNode];
        hubVC.title = @"选择内容";
        hubVC.progectName = self.title;
       // hubVC.detailCaseNode =
    }else if([segue.identifier isEqualToString:@"popoverConditionSegue"]){
        UINavigationController *nagVC = (UINavigationController*)segue.destinationViewController;
        nagVC.preferredContentSize = CGSizeMake(600, 400);

        TemplateLeftDetailViewController *leftDetailVC = (TemplateLeftDetailViewController*)[nagVC.viewControllers firstObject];
        leftDetailVC.fetchNodeName = @"住院病历";
        leftDetailVC.title = @"选择项目";
        

        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:didExcutePopoverConditionSegue];
    }else if([segue.identifier isEqualToString:@"ToAdmiss"]){
            
    }
}

-(void)saveTemplateToCoreData
{
    NSString *condition = [self.dataDic objectForKey:@"添加条件"];
    NSString *content = [self.dataDic objectForKey:@"添加内容"];
    
    NSString *ageSegment = [self.conditionDicData objectForKey:@"年龄段"];
    NSNumber *ageLow = [NSNumber numberWithInt:0];
    NSNumber *ageHigh = [NSNumber numberWithInt:0];
    if (ageSegment) {
        if(![ageSegment isEqualToString:@"请选择"]){
            
            NSArray *tempA = [ageSegment componentsSeparatedByString:@"-"];
            NSMutableArray *tep = [[NSMutableArray alloc] init];
            for (NSString *ageStr in tempA) {
                NSArray *a = [ageStr componentsSeparatedByString:@"岁"];
                [tep addObject:a[0]];
            }
            ageLow =[NSNumber numberWithInt:[(NSString*)tep[0] intValue]];
            ageHigh = [NSNumber numberWithInt:[(NSString*)tep[1] intValue]];
            
        }
        
    }
    NSString *gender = [self.conditionDicData objectForKey:@"性别"];
    NSString *admittingDiagnosis = [self.conditionDicData objectForKey:@"入院诊断"];
    NSString *simultaneousPhenomenon = [self.conditionDicData objectForKey:@"伴随症状"];
    NSString *cardinalSymptom = [self.conditionDicData objectForKey:@"主要症状"];
    
    ///save to server
    NSDictionary *param = @{@"tID" :self.currentNode.nodeIdentifier ,
                            @"tArgs" : @{@"highAge" : ageHigh,
                                         @"lowAge" : ageLow,
                                         @"gender" :StringValue([gender isEqualToString:@"男"] ? @(1):@(0)), //1为男，0为女
                                         @"diagnose" : admittingDiagnosis,
                                         @"mainSymptom" : cardinalSymptom,
                                         @"otherSymptom" : simultaneousPhenomenon
                                         },
                            @"tContent" : content,
                            @"dID" : @"735789", //医生ID
                            @"isPublic" : @"1" //是否公开，1为公开，0为不公开
                            };
    
    NSDictionary *tempDD = NSDictionaryOfVariableBindings(condition,content,ageLow,ageHigh,gender,admittingDiagnosis,simultaneousPhenomenon,cardinalSymptom);
   // tempD = [NSDictionary dictionaryWithDictionary:tempDD];
    
    [self.coreDataStack createManagedObjectTemplateWithDic:tempDD ForNodeWithNodeName:self.title];
    
   // __block NSDictionary *tempD = [[NSDictionary alloc] init];
    
//    CKHttpClient *http = [CKHttpClient getInstance];
//    [http postTemplateToServerWithDicParam:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"test %@", responseObject);
//        ///save to core data
//        NSString *nodeID =(NSString*) responseObject[@"_id"];
//        NSString *createDateStr = (NSString*)responseObject[@"_updated"];
//
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSString *str = [[NSString alloc] initWithData:operation.request.HTTPBody encoding:NSUTF8StringEncoding];
//        NSLog(@"fucj%@", str);
//        
//        
//    }];
//
    [MessageObject messageObjectWithUsrStr:@"1" pwdStr:@"test" iHMsgSocket:self.socket optInt:20002 dictionary:param block:^(IHSockRequest *request) {
        
        NSLog(@"sucess");
        
    } failConection:^(NSError *error) {
        
        NSLog(@"fail");
    }];
}
- (IBAction)unwindSegueFromModelPCSToCurrentViewController:(UIStoryboardSegue *)segue {
    
    NSString *tempStr = [self.dataArray objectAtIndex:self.currentIndexPath.row];
    self.conditionLabelStr  = [self.conditionLabelStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    if(![self.conditionLabelStr isEqualToString:@""]){
        [self.dataDic setObject:self.conditionLabelStr forKey:tempStr];
        [self.tableView reloadData];
        
        self.saveBtn.enabled = YES;
    }
}

- (IBAction)unwindSegueFromSubContentVCToCurrentViewController:(UIStoryboardSegue *)segue {
    
    NSString *tempStr = [self.dataArray objectAtIndex:self.currentIndexPath.row];
    self.contentStr  = [self.contentStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    if(![self.contentStr isEqualToString:@""]){
        [self.dataDic setObject:self.contentStr forKey:tempStr];
        [self.tableView reloadData];
        
       // self.saveBtn.enabled = YES;
        
    }
    
    
}
/// selected condition save and cancel unwind segue
- (IBAction)unwindSegueToCreateViewController:(UIStoryboardSegue *)segue {
    

    
}
- (IBAction)unwindSegueCancelToCreateViewController:(UIStoryboardSegue *)segue {
    
    
    
}


///for test
-(WLKCaseNode*)getSelectedNode
{
    RawDataProcess *rawData = [RawDataProcess sharedRawData];
    WLKCaseNode *node = [WLKCaseNode getSubNodeFromNode:rawData.rootNode withNodeName:self.title resultNode:nil];
    
    return node;
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
