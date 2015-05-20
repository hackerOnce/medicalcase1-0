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
#import "Template.h"

#import "ModelPlateConditionsViewController.h"

#import "RawDataProcess.h"
#import "WLKCaseNode.h"


@interface CreateTemplateViewController () <UITableViewDataSource,UITableViewDelegate>
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
    
    [self saveTemplateToCoreData];
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
    self.currentNode = (Node*)strId;
    self.title = self.currentNode.nodeName;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.conditionLabel = (UILabel*)[self.view viewWithTag:1001];
    [self setUpTableView];
    //self.title = @"";
    [self addNotificationObserver];
    
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:didExcutePopoverConditionSegue];

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
    if([segue.identifier isEqualToString:@"contentSegue"]){
        HUDSubViewController *hubVC = (HUDSubViewController*)segue.destinationViewController;
        hubVC.detailCaseNode = [self getSelectedNode];
        hubVC.title = @"选择内容";
        hubVC.progectName = self.title;
    }else if([segue.identifier isEqualToString:@"popoverConditionSegue"]){
        UINavigationController *nagVC = (UINavigationController*)segue.destinationViewController;
        nagVC.preferredContentSize = CGSizeMake(600, 400);

        TemplateLeftDetailViewController *leftDetailVC = (TemplateLeftDetailViewController*)[nagVC.viewControllers firstObject];
        leftDetailVC.fetchNodeName = @"住院病历";
        leftDetailVC.title = @"选择项目";
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:didExcutePopoverConditionSegue];
    }
}

-(void)saveTemplateToCoreData
{
    NSString *condition = [self.dataDic objectForKey:@"添加条件"];
    NSString *content = [self.dataDic objectForKey:@"添加内容"];
    
    
    ParentNode *parentNode = [self.coreDataStack fetchParentNodeWithNodeEntityName:@"条件"];
    
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
    for (Node *tempNode in parentNode.nodes) {
        [tempDict setObject:tempNode.nodeContent forKey:tempNode.nodeEnglish];
    }
    
    NSString *tID = self.currentNode.nodeEnglish;
    NSString *highAge = tempDict[@"highAge"];
    NSString *lownAge = tempDict[@"lowAge"];
    NSString *gender =  tempDict[@"gender"];
    NSString *diagnose = tempDict[@"diagnose"];
    NSString *mainSymptom = tempDict[@"mainSymptom"];
    NSString *otherSymptom = tempDict[@"acompanySymptom"];
    
    NSString *dID = [[NSUserDefaults standardUserDefaults] objectForKey:@"dID"];
    
    NSDictionary *param = @{@"tID" :self.currentNode.nodeEnglish ,
                            @"tArgs" : @{@"highAge" : highAge,
                                         @"lowAge" : lownAge,
                                         @"gender" : gender, //1为男，0为女
                                         @"diagnose" : diagnose,
                                         @"mainSymptom" :mainSymptom,
                                         @"otherSymptom" : otherSymptom
                                         },
                            @"tContent" : content,
                            @"isPublic" : @"1", //是否公开，1为公开，0为不公开，
                            @"doctor" : @{@"dID" : dID,
                                          @"dName" : @""},
                            @"templateType" : [self getMBBHWithEnglishName:self.currentNode.nodeEnglish],
                            @"templateName" : self.currentNode.nodeName
                            };
    
    [tempDict setObject:condition forKey:@"condition"];
    [tempDict setObject:content forKey:@"content"];
    
    [MessageObject messageObjectWithUsrStr:@"11" pwdStr:@"test" iHMsgSocket:self.socket optInt:20002 dictionary:param block:^(IHSockRequest *request) {
        
    } failConection:^(NSError *error) {
        
    }];
    //[self.coreDataStack createManagedObjectTemplateWithDic:tempDict ForNodeWithNodeName:self.title];
//    NSString *ageSegment = [self.conditionDicData objectForKey:@"年龄段"];
//    NSString *ageLow = @"0";
//    NSString *ageHigh = @"0";
//    if (ageSegment) {
//        if(![ageSegment isEqualToString:@"请选择"]){
//            
//            NSArray *tempA = [ageSegment componentsSeparatedByString:@"-"];
//            NSMutableArray *tep = [[NSMutableArray alloc] init];
//            for (NSString *ageStr in tempA) {
//                NSArray *a = [ageStr componentsSeparatedByString:@"岁"];
//                [tep addObject:a[0]];
//            }
//            ageLow = (NSString*)tep[0];
//            ageHigh = (NSString*)tep[1];
//            
//        }
//        
//    }
//    NSString *gender = [self.conditionDicData objectForKey:@"性别"];
//    NSString *admittingDiagnosis = [self.conditionDicData objectForKey:@"入院诊断"];
//    NSString *simultaneousPhenomenon = [self.conditionDicData objectForKey:@"伴随症状"];
//    NSString *cardinalSymptom = [self.conditionDicData objectForKey:@"主要症状"];
//    
//    ///save to server
//    NSDictionary *param = @{@"tID" :self.currentNode.nodeEnglish ,
//                            @"tArgs" : @{@"highAge" :ageHigh,
//                                         @"lowAge" : ageLow,
//                                         @"gender" :StringValue([gender isEqualToString:@"男"] ? @(1):@(0)), //1为男，0为女
//                                         @"diagnose" : admittingDiagnosis,
//                                         @"mainSymptom" : cardinalSymptom,
//                                         @"otherSymptom" : simultaneousPhenomenon
//                                         },
//                            @"tContent" : content,
//                            @"dID" : @"735789", //医生ID
//                            @"isPublic" : @"1" //是否公开，1为公开，0为不公开
//                            };
//    
//    NSDictionary *tempDD = NSDictionaryOfVariableBindings(condition,content,ageLow,ageHigh,gender,admittingDiagnosis,simultaneousPhenomenon,cardinalSymptom);
//    
////    [self.coreDataStack createManagedObjectTemplateWithDic:tempDD ForNodeWithNodeName:self.title];
//    [MessageObject messageObjectWithUsrStr:@"1" pwdStr:@"test" iHMsgSocket:self.socket optInt:20002 dictionary:param block:^(IHSockRequest *request) {
//        
//        NSLog(@"sucess");
//        
//    } failConection:^(NSError *error) {
//        
//        NSLog(@"fail");
//    }];
}
-(NSString*)getMBBHWithEnglishName:(NSString*)name
{
    static NSDictionary *dic = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dic = @{
                @"residentAdmitNote" : @"ihefe101",
                @"chiefComplaint" : @"ihefe10101",
                @"historyOfPresentIllness" : @"ihefe10102",
                @"pastHistory" : @"ihefe10103",
                @"systemsReview" : @"ihefe10104",
                @"personalHistory" : @"ihefe10105",
                @"menstrualHistory" : @"ihefe10106",
                @"maritalHistory" : @"ihefe10107",
                @"obstericalHistory" : @"ihefe10107",//婚育史
                @"familyHistory" : @"ihefe10108",
                @"physicalExamination" : @"ihefe10109",
                @"specializedExamination" : @"ihefe10110",
                @"accessoryExamination" : @"ihefe10111",
                @"tentativeDiagnosis" : @"ihefe10112",
                @"admittingDiagnosis" : @"ihefe10113",
                @"confirmedDiagnosis" : @"ihefe10114" //补充诊断
                };
    });
    if ([dic.allKeys containsObject:name]) {
        return dic[name];
    }
    return nil;
}
- (IBAction)setConditions:(UIStoryboardSegue *)segue {
    ///得到条件
    ParentNode *parentNode = [self.coreDataStack fetchParentNodeWithNodeEntityName:@"条件"];
    NSString *conditionString = @"";
    for (Node *tempNode in parentNode.nodes) {
        if ([tempNode.nodeEnglish isEqualToString:@"lowAge"]) {
            
        }else {
            conditionString = [conditionString stringByAppendingString:tempNode.nodeContent];
        }
    }
    NSString *removeSpace = [conditionString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *tempStr = [self.dataArray objectAtIndex:self.currentIndexPath.row];
    if ([removeSpace isEqualToString:@""]) {
        
    }else {
        [self.dataDic setObject:self.conditionLabelStr forKey:tempStr];
        [self.tableView reloadRowsAtIndexPaths:@[self.currentIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }

}

- (IBAction)unwindSegueFromSubContentVCToCurrentViewController:(UIStoryboardSegue *)segue {
    
    ///得到内容
    NSString *tempStr = [self.dataArray objectAtIndex:self.currentIndexPath.row];
    self.contentStr  =  [self.contentStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([self.contentStr isEqualToString:@""]){
        
    }else {
        [self.dataDic setObject:self.contentStr forKey:tempStr];
        [self.tableView reloadRowsAtIndexPaths:@[self.currentIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
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
