//
//  WriteCaseSaveViewController.m
//  WriteMedicalCase
//
//  Created by GK on 15/4/29.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "WriteCaseSaveViewController.h"
#import "WriteCaseSaveCell.h"
#import "WriteCaseEditViewController.h"
#import "NSDate+Helper.h"
#import "writeCaseFirstItemViewController.h"
#import "IHMsgSocket.h"
#import "MessageObject+DY.h"

@interface WriteCaseSaveViewController ()<NSFetchedResultsControllerDelegate,WriteCaseSaveCellDelegate,UITableViewDelegate,UITableViewDataSource,WriteCaseEditViewControllerDelegate,writeCaseFirstItemViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UILabel *remainTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *caseTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

//core data
@property (nonatomic,strong) CoreDataStack *coreDataStack;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic,strong) NSFetchedResultsController *fetchResultController;

//key board
@property (nonatomic) CGFloat keyboardOverlap;
@property (nonatomic,strong) NSIndexPath *currentIndexPath;
@property (nonatomic,strong) UITextView *currentTextView;

@property (nonatomic) BOOL keyboardShow;
@property (nonatomic,strong) NSString *selectedStr;

@property (nonatomic) BOOL isBeginEdit;

@property (nonatomic,strong) RecordBaseInfo *recordBaseInfo;
//@property (nonatomic) BOOL hasContent;
@property (nonatomic,strong) NSString *textViewContent;

///
@property (nonatomic,strong) IHMsgSocket *socket;

@property (nonatomic) BOOL doctorCreatedSucess;
@property (nonatomic) BOOL patientCreateSucess;
@end

@implementation WriteCaseSaveViewController
@synthesize tempResidentDoctor = _tempResidentDoctor;
@synthesize tempPatient = _tempPatient;
///test data
-(IHMsgSocket *)socket
{
    if (!_socket) {
        _socket = [IHMsgSocket sharedRequest];
        [_socket connectToHost:@"192.168.10.106" onPort:2323];
    }
    return _socket;
}
//-(TempPatient *)tempPatient
//{
//    if (!_tempPatient) {
////        NSDictionary *tempDic =@{@"pID":@"99999",@"pName":@"魍天赐",@"pGender":@"男",@"pAge":@"24",@"pCity":@"上海",@"pProvince":@"上海",@"pDetailAddress":@"闸北区彭江路602号",@"pDept":@"心内科",@"pBedNum":@"02",@"pNation":@"中国"};
//        _tempPatient = [[TempPatient alloc] initWithPatientID:nil];
//    }
//    return _tempPatient;
//}
-(void)setTempResidentDoctor:(TempDoctor *)tempResidentDoctor
{
    _tempResidentDoctor = tempResidentDoctor;
    NSString *dept = _tempResidentDoctor.dept;
    NSString *dID = _tempResidentDoctor.dID;
    NSString *dName =  tempResidentDoctor.dName;
    NSString *dProfessionalTitle = tempResidentDoctor.dProfessionalTitle?tempResidentDoctor.dProfessionalTitle:@" ";
    NSString *isResident = tempResidentDoctor.isResidentDoctor?tempResidentDoctor.isResidentDoctor:@" ";
    NSString *medicalTeam = tempResidentDoctor.medicalTeam?tempResidentDoctor.medicalTeam:@" ";
 
    
    //创建住院医师
    [self.coreDataStack fetchDoctorWithDic:NSDictionaryOfVariableBindings(dept,dID,dName,dProfessionalTitle) successfulFetched:^(NSArray *resultArray) {
        self.doctorCreatedSucess  = YES;

    } failedToFetched:^(NSError *error, NSString *errorInfo) {
        
    }];

}
-(void)setTempPatient:(TempPatient *)tempPatient
{
    _tempPatient = tempPatient;
    //创建病人
    NSDictionary *tempDic = [self getSaveCasePatientSocketDic];
    [self.coreDataStack fetchPatientWithDic:tempDic successfulFetched:^(NSArray *resultArray) {
        self.patientCreateSucess = YES;
    
            NSString *dName = self.tempResidentDoctor.dName;
            NSString *dID = self.tempResidentDoctor.dID;
            NSString *pName = self.tempPatient.pName;
            NSString *pID = self.tempPatient.pID;
            NSString *caseType = self.caseType;//入院病历
            //
            if (self.patientCreateSucess && self.doctorCreatedSucess) {
                [self.coreDataStack fetchCaseInfoWithDic:NSDictionaryOfVariableBindings(dName,dID,pName,pID,caseType) successfulFetched:^(NSArray *resultArray) {
    
                    if (resultArray.count == 1) {
                        self.recordBaseInfo = (RecordBaseInfo*)[resultArray firstObject];
                    }else {
    
                    }
                } failedToFetched:^(NSError *error, NSString *errorInfo) {
                    
                }];
            }

    } failedToFetched:^(NSError *error, NSString *errorInfo) {
        
    }];

//    [self.coreDataStack createPatientManagedObjectWithDataDic:tempDic failedToCreated:^(NSError *error, NSString *errorInfo) {
//        
//    } successfulCreated:^{
//        
//        self.patientCreateSucess = YES;
//        
//        NSString *dName = self.tempResidentDoctor.dName;
//        NSString *dID = self.tempResidentDoctor.dID;
//        NSString *pName = self.tempPatient.pName;
//        NSString *pID = self.tempPatient.pID;
//        NSString *caseType = self.caseType;//入院病历
//        //
//        if (self.patientCreateSucess && self.doctorCreatedSucess) {
//            [self.coreDataStack fetchCaseInfoWithDic:NSDictionaryOfVariableBindings(dName,dID,pName,pID,caseType) successfulFetched:^(NSArray *resultArray) {
//                
//                if (resultArray.count == 1) {
//                    self.recordBaseInfo = (RecordBaseInfo*)[resultArray firstObject];
//                }else {
//                    
//                }
//            } failedToFetched:^(NSError *error, NSString *errorInfo) {
//                
//            }];
//        }
//    }];
        
}
-(NSString *)caseType
{
    if (!_caseType) {
        _caseType = @"入院病历";
    }
    return _caseType;
}
//-(TempDoctor*)tempResidentDoctor
//{
//    if (!_tempResidentDoctor) {
//        NSDictionary *tempDic = @{@"dID":@"88888",@"dName":@"住院医师",@"dept":@"心内科",@"isResidentDoctor":@"1"};
//        _tempResidentDoctor = [[TempDoctor alloc] initWithTempDoctorDic:tempDic];
//    }
//    return _tempResidentDoctor;
//}
//-(TempDoctor *)tempChiefPhysicianDoctor
//{
//    if (!_tempChiefPhysicianDoctor) {
//        NSDictionary *tempDic = @{@"dID":@"99999",@"dName":@"主任医师",@"dept":@"心内科",@"isResidentDoctor":@"0"};
//        _tempResidentDoctor = [[TempDoctor alloc] initWithTempDoctorDic:tempDic];
//    }
//    return _tempChiefPhysicianDoctor;
//}
//-(TempDoctor *)tempAttendingPhysicianDoctor
//{
//    if (!_tempAttendingPhysicianDoctor) {
//        NSDictionary *tempDic = @{@"dID":@"77777",@"dName":@"主治医师",@"dept":@"心内科",@"isResidentDoctor":@"0"};
//        _tempResidentDoctor = [[TempDoctor alloc] initWithTempDoctorDic:tempDic];
//
//    }
//    return _tempAttendingPhysicianDoctor;
//}
-(NSDictionary*)testData
{
    NSString *pID = self.tempPatient.pID;
    NSString *pName = self.tempPatient.pName;
    NSString *dID = self.tempResidentDoctor.dID;
    NSString *dName = self.tempResidentDoctor.dName;
    NSString *caseType;
    if (self.caseType) {
        caseType = self.caseType;
    }else {
        caseType = @"error";
    }

    return NSDictionaryOfVariableBindings(pID,pName,dID,dName);
}
- (IBAction)saveOrCommit:(UIButton *)sender {
    
    [self.coreDataStack saveContext];

    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[self getContentDic]];
    
    NSString * dID = self.tempResidentDoctor.dID;
    NSString * dName = self.tempResidentDoctor.dName;
    NSString * pID = self.tempPatient.pID;
    NSString * pName = self.tempPatient.pName;
    
    [dic setObject:dID forKey:@"dID"];
    [dic setObject:dName forKey:@"dName"];
    [dic setObject:pID forKey:@"pID"];
    [dic setObject:pName forKey:@"pName"];
    
   // UIButton *button = (UIButton*)sender;
    NSDictionary *doctor = [self getSaveCaseDoctorSocketDic];
    NSDictionary *patient = [self getSaveCasePatientSocketDic];
    NSDictionary *caseBaseInfo = [self getContentDic];
    
    
   [MessageObject messageObjectWithUsrStr:@"1" pwdStr:@"test" iHMsgSocket:self.socket optInt:20001 dictionary:NSDictionaryOfVariableBindings(doctor,patient,caseBaseInfo) block:^(IHSockRequest *request) {
       
       NSDictionary *requestDic = [request.responseData firstObject];
       [dic setObject:requestDic[@"_DOF"] forKey:@"archivedTime"];
       [dic setObject:requestDic[@"_created"] forKey:@"createdTime"];
       [dic setObject:requestDic[@"_updated"] forKey:@"lastModifyTime"];
       [dic setObject:requestDic[@"_id"] forKey:@"caseID"];
       
       [self.coreDataStack createMedicalCaseManagedObjectWithDataDic:dic failedToCreated:^(NSError *error, NSString *errorInfo) {
           
       } successfulCreated:^{
           
       }];
      } failConection:^(NSError *error) {
       
   }];
}
-(NSDictionary*)getSaveCaseDoctorSocketDic
{
    //doctor
    NSString  *residentDoctorname = self.tempResidentDoctor.dName?self.tempResidentDoctor.dName:@" ";
    NSString  *residentDoctorID = self.tempResidentDoctor.dID?self.tempResidentDoctor.dID:@" ";
    NSString  *attendingPhysicianDoctorName = self.tempAttendingPhysicianDoctor.dName?self.tempAttendingPhysicianDoctor.dName:@" ";
    NSString  *attendingPhysicianDoctorID = self.tempAttendingPhysicianDoctor.dID?self.tempAttendingPhysicianDoctor.dID:@" ";
    NSString  *chiefPhysicianDoctorID = self.tempChiefPhysicianDoctor.dName?self.tempChiefPhysicianDoctor.dName:@" ";
    NSString  *chiefPhysicianDoctorName = self.tempChiefPhysicianDoctor.dID?self.tempChiefPhysicianDoctor.dID:@" ";
    return NSDictionaryOfVariableBindings(residentDoctorID,residentDoctorname,attendingPhysicianDoctorID,attendingPhysicianDoctorName,chiefPhysicianDoctorID,chiefPhysicianDoctorName);
}
-(NSDictionary*)getSaveCasePatientSocketDic
{
    ///patient dic
    
    NSString  *pAge = self.tempPatient.pAge?self.tempPatient.pAge:@" ";
    NSString  *patientState = self.tempPatient.patientState?self.tempPatient.patientState:@" ";
    NSString  *pBedNum = self.tempPatient.pBedNum?self.tempPatient.pBedNum:@" ";
    NSString  *pCity = self.tempPatient.pCity?self.tempPatient.pCity:@" ";
    NSString  *pCountOfHospitalized = self.tempPatient.pCountOfHospitalized?self.tempPatient.pCountOfHospitalized:@" ";
    NSString  *pDept = self.tempPatient.pDept?self.tempPatient.pDept:@" ";
    NSString  *pDetailAddress = self.tempPatient.pDetailAddress?self.tempPatient.pDetailAddress:@" ";
    NSString  *pGender = self.tempPatient.pGender?self.tempPatient.pGender:@" " ;
    NSString  *pID = self.tempPatient.pID?self.tempPatient.pID:@" ";
    NSString  *pLinkman = self.tempPatient.pLinkman?self.tempPatient.pLinkman:@" ";
    NSString  *pLinkmanMobileNum = self.tempPatient.pLinkmanMobileNum?self.tempPatient.pLinkmanMobileNum:@" ";
    NSString  *pMaritalStatus = self.tempPatient.pMaritalStatus?self.tempPatient.pMaritalStatus:@" "; //婚姻状况
    NSString  *pMobileNum = self.tempPatient.pMobileNum?self.tempPatient.pMobileNum:@" ";
    NSString  *pName = self.tempPatient.pName?self.tempPatient.pName:@" ";
    NSString  *pNation = self.tempPatient.pNation?self.tempPatient.pNation:@" ";
    NSString  *pProfession = self.tempPatient.pProfession?self.tempPatient.pProfession:@" ";
    NSString  *pProvince = self.tempPatient.pProvince?self.tempPatient.pProvince:@" ";
    NSString  *presenter = self.tempPatient.presenter?self.tempPatient.presenter:@" ";//病史陈述者
    
    NSDictionary *patientDic = NSDictionaryOfVariableBindings(pAge,patientState,pBedNum,pCity,pCountOfHospitalized,pDetailAddress,pDept,pGender,pID,pCountOfHospitalized,pLinkman,pLinkmanMobileNum,pMobileNum,pName,pNation,pProfession,pProvince,presenter,pMaritalStatus);
    
    return patientDic;
}
-(void)setRecordBaseInfo:(RecordBaseInfo *)recordBaseInfo
{
    _recordBaseInfo = recordBaseInfo;
    
    NSDictionary *dic;
    if (_recordBaseInfo.caseContent == nil || [_recordBaseInfo.caseContent isEqualToString:@""]) {
        _recordBaseInfo.caseContent = @"";

    }else {
        
    }
    dic =[self convertJSONDataToList:[self convertStringToJSONData:_recordBaseInfo.caseContent]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"nodeName = %@",@"入院记录"];
    
    NSArray *resultA = [self.coreDataStack fetchNSManagedObjectEntityWithName:[ParentNode entityName] withNSPredicate:predicate setUpFetchRequestResultType:0 isSetUpResultType:NO setUpFetchRequestSortDescriptors:nil isSetupSortDescriptors:NO];
    if (resultA.count == 1) {
        ParentNode *parentNode = (ParentNode*)[resultA firstObject];
        for (Node *node in parentNode.nodes.array) {
            node.nodeContent = [dic objectForKey:node.nodeNameE];
        }
        [self.coreDataStack saveContextFailToSave:^(NSError *error, NSString *errorInfo) {
            
        } successfulCreated:^{
            [self setUpFetchViewController];
        }];
        
    }else {
        abort();
    }

}

-(NSMutableDictionary*)getContentDic
{
    NSMutableDictionary *dic =[NSMutableDictionary dictionaryWithDictionary:[self testData]];
    NSMutableDictionary *returnDic = [[NSMutableDictionary alloc] init];
    
    NSString *caseContent;
    NSString *caseState;
    BOOL hasContent = NO;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"nodeName = %@",@"入院记录"];
    //NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"nodeIndex" ascending:YES];
    
    NSArray *resultA = [self.coreDataStack fetchNSManagedObjectEntityWithName:[ParentNode entityName] withNSPredicate:predicate setUpFetchRequestResultType:0 isSetUpResultType:NO setUpFetchRequestSortDescriptors:nil isSetupSortDescriptors:NO];
    if (resultA.count == 1) {
        ParentNode *parentNode = (ParentNode*)[resultA firstObject];
        for (Node *node in parentNode.nodes.array) {
            
          node.nodeContent = [node.nodeContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if (node.nodeContent == nil ||[node.nodeContent isEqualToString:node.nodeName] || [node.nodeContent isEqualToString:@""]) {
                caseState  = @"未完整创建";
                hasContent = YES;
            }else {
                [dic setObject:node.nodeContent forKey:node.nodeNameE];
            }
        }
        caseContent = [self convertJSONDataToString:[self convertToJSONDataFromList:dic]];

    }
    if (hasContent) {
        [self.saveButton setTitle:@"保存" forState:UIControlStateNormal];
        caseState  = @"未完整创建";
    }else {
        [self.saveButton setTitle:@"提交" forState:UIControlStateNormal];
        caseState  = @"未提交";
    }
    [returnDic setObject:dic forKey:@"caseContentDic"];
    [returnDic setObject:caseContent forKey:@"caseContent"];
    [returnDic setObject:caseState forKey:@"caseState"];
    [returnDic setObject:self.caseType forKey:@"caseType"];
    
    return returnDic;
}
-(void)updateButtonState
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"nodeName = %@",@"入院记录"];
    //NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"nodeIndex" ascending:YES];
    BOOL hasContent = NO;
    NSArray *resultA = [self.coreDataStack fetchNSManagedObjectEntityWithName:[ParentNode entityName] withNSPredicate:predicate setUpFetchRequestResultType:0 isSetUpResultType:NO setUpFetchRequestSortDescriptors:nil isSetupSortDescriptors:NO];
    if (resultA.count == 1) {
        ParentNode *parentNode = (ParentNode*)[resultA firstObject];
        for (Node *node in parentNode.nodes.array) {
            if (node.nodeContent == nil ||[node.nodeContent isEqualToString:node.nodeName] || [node.nodeContent isEqualToString:@" "]) {
                hasContent = YES;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (hasContent) {
                [self.saveButton setTitle:@"保存" forState:UIControlStateNormal];
            }else {
                [self.saveButton setTitle:@"提交" forState:UIControlStateNormal];
            }

        });
    }
}

///core data
-(NSManagedObjectContext *)managedObjectContext
{
    return self.coreDataStack.managedObjectContext;
}
-(CoreDataStack *)coreDataStack
{
    _coreDataStack = [[CoreDataStack alloc] init];
    return _coreDataStack;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateButtonState];
    
    self.caseTypeLabel.text =self.caseType?self.caseType:@"入院病历";
//    if (!self.caseType) {
//        abort();
//    }

    self.remainTimeLabel.text =[NSString stringWithFormat:@"剩余时间:%@",[self getRemainTime]];
    self.currentTimeLabel.text  =  [self getYearAndMonthWithDateStr:[NSDate date]];
}
-(NSString*)getYearAndMonthWithDateStr:(NSDate*)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *dateStr = [formatter stringFromDate:date];
    
    NSLog(@"date : %@",dateStr);
    
    return dateStr;
}

-(NSString *)getRemainTime
{
    
    return  @"jdjdj";

}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addKeyboardObserver];
    
    [self setUpTableView];
    self.isBeginEdit = NO;
    
    NSString *dID = @"88888";
    NSString *dName = @"医生";
    NSString *dProfessionalTitle = @"小医生";
    NSString *dept = @"心内科";
    NSString *medicalTeam = @"无";
    
    self.tempResidentDoctor = [[TempDoctor alloc] initWithTempDoctorDic:NSDictionaryOfVariableBindings(dID,dName,dProfessionalTitle,dept,medicalTeam)];
    
    ///test data
    NSString *pID = @"99999";
    NSString *pName = @"王天找";
    NSString *pGender = @"男";
    NSString *pAge = @"22";
    NSString *pCity = @"上海";
    NSString *pProvince = @"上海";
    NSString *pDetailAddress = @"上海闸北区彭江路";
    NSString *pDept = @"心内科";
    NSString *pBedNum = @"086";
    NSString *pNation = @"东突";
    NSString *pProfession = @"律师";
    NSString *pMaritalStatus = @"未婚";
    NSString *pMobileNum = @"13778126754";
    NSString *pLinkman = @"王天华";
    NSString *pLinkmanMobileNum = @"13787865676";
    NSString *pCountOfHospitalized = @"1";
    NSString *presenter = @"本人";//病史陈述者
    NSString *pAdmissionTime = @"2015-09-09";//入院时间 //年月日
    NSString *pSubAdmissionTime = @"上午 09:00:09"; //时分秒
    NSString *patientState = @"0";//0：未出院 1： 已出院

    self.tempPatient = [[TempPatient alloc] initWithPatientID:NSDictionaryOfVariableBindings(pID,pNation,pName,pGender,pAge,pCity,pProvince,pDetailAddress,pDept,pBedNum,pProvince,pMaritalStatus,pMobileNum,pLinkmanMobileNum,pLinkman,pCountOfHospitalized,presenter,pAdmissionTime,pSubAdmissionTime,patientState,pProfession)];
    
   // self.hasContent = NO;
//    NSString *pID = @"88888";
//    NSString *pName = @"张三";
//    NSString *dID = @"99999";
//    NSString *dName = @"涨涨我";
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pID=%@ and pName=%@ and dID=%@ and dName=%@",pID,pName,dID,dName];
//    [self.coreDataStack fetchManagedObjectInContext:self.managedObjectContext WithEntityName:[RecordBaseInfo entityName] withPredicate:predicate successfulFetched:^(NSArray *resultArray) {
//        
//        if (resultArray.count == 0) {
//            
//        }else {
//            if (resultArray.count == 1) {
//                RecordBaseInfo *recordBaseInfo = (RecordBaseInfo*)[resultArray firstObject];
//                self.recordBaseInfo = recordBaseInfo;
//            }
//        }
//
//    } failedToFetched:^(NSError *error, NSString *errorInfo) {
//        
//    }];

}
-(void)addKeyboardObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)setUpTableView
{
    self.tableView.layer.shadowOffset = CGSizeMake(15, 13);
    self.tableView.layer.shadowOpacity = 1;
    self.tableView.layer.shadowRadius = 20;
    self.tableView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    
    self.tableView.layer.borderWidth = 1;
    self.tableView.estimatedRowHeight = 55;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

-(void)setUpFetchViewController
{
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:[Node entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"parentNode.nodeName = %@",@"入院记录"];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"nodeIndex" ascending:YES];
    //  NSSortDescriptor *sortDescriptor = nil;
    fetchRequest.predicate = predicate;
    fetchRequest.sortDescriptors = @[sortDescriptor];
    
    self.fetchResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.coreDataStack.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    self.fetchResultController.delegate = self;
    NSError *error = nil;
    if (![self.fetchResultController performFetch:&error]) {
        NSLog(@"error: %@",error.description);
        abort();
    }else {
        [self.tableView reloadData];
    }
}

-(void)keyboardWillShow:(NSNotification*)notificationInfo
{
    if (self.keyboardShow) {
        return;
    }
    self.keyboardShow = YES;
    // Get the keyboard size
    UIScrollView *tableView;
    if([self.tableView.superview isKindOfClass:[UIScrollView class]])
        tableView = (UIScrollView *)self.tableView.superview;
    else
        tableView = self.tableView;
    
    NSDictionary *userInfo = [notificationInfo userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    //[self.delegate keyboardShow:[aValue CGRectValue].size.height];
    CGRect keyboardRect = [tableView.superview convertRect:[aValue CGRectValue] fromView:nil];
    
    
    // [self.delegate keyboardShow:keyboardRect.size.height];
    // Get the keyboard's animation details
    NSTimeInterval animationDuration;
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    UIViewAnimationCurve animationCurve;
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    
    // Determine how much overlap exists between tableView and the keyboard
    CGRect tableFrame = tableView.frame;
    CGFloat tableLowerYCoord = tableFrame.origin.y + tableFrame.size.height;
    self.keyboardOverlap = tableLowerYCoord - keyboardRect.origin.y;
    if(self.currentTextView && self.keyboardOverlap>0)
    {
        CGFloat accessoryHeight = self.currentTextView.frame.size.height;
        self.keyboardOverlap -= accessoryHeight;
        
        tableView.contentInset = UIEdgeInsetsMake(0, 0, accessoryHeight, 0);
        tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, accessoryHeight, 0);
    }
    
    if(self.keyboardOverlap < 0)
        self.keyboardOverlap = 0;
    
    if(self.keyboardOverlap != 0)
    {
        tableFrame.size.height -= self.keyboardOverlap;
        
        NSTimeInterval delay = 0;
        if(keyboardRect.size.height)
        {
            delay = (1 - self.keyboardOverlap/keyboardRect.size.height)*animationDuration;
            animationDuration = animationDuration * self.keyboardOverlap/keyboardRect.size.height;
        }
        
        [UIView animateWithDuration:animationDuration delay:delay
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{ tableView.frame = tableFrame; }
                         completion:^(BOOL finished){ [self tableAnimationEnded:nil finished:nil contextInfo:nil]; }];
    }
    
}
-(void)keyboardWillHide:(NSNotification*)notificationInfo
{
    
    [self.coreDataStack saveContext];
    
    self.keyboardShow = NO;
    
    UIScrollView *tableView;
    if([self.tableView.superview isKindOfClass:[UIScrollView class]])
        tableView = (UIScrollView *)self.tableView.superview;
    else
        tableView = self.tableView;
    if(self.currentTextView)
    {
        tableView.contentInset = UIEdgeInsetsZero;
        tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
    }
    
    if(self.keyboardOverlap == 0)
        return;
    
    // Get the size & animation details of the keyboard
    NSDictionary *userInfo = [notificationInfo userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [tableView.superview convertRect:[aValue CGRectValue] fromView:nil];
    
    NSTimeInterval animationDuration;
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    UIViewAnimationCurve animationCurve;
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    
    CGRect tableFrame = tableView.frame;
    tableFrame.size.height += self.keyboardOverlap;
    
    //  tableFrame.size = CGSizeMake(678, 497);
    if(keyboardRect.size.height)
        animationDuration = animationDuration * self.keyboardOverlap/keyboardRect.size.height;
    
    [UIView animateWithDuration:animationDuration delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{ tableView.frame = tableFrame; }
                     completion:^(BOOL finished){ [self tableAnimationEnded:nil finished:nil contextInfo:nil]; }];
    
    
}
- (void) tableAnimationEnded:(NSString*)animationID finished:(NSNumber *)finished contextInfo:(void *)context
{
    // Scroll to the active cell
    UITableView *tableView = self.tableView;
    if(self.currentIndexPath)
    {
        [tableView scrollToRowAtIndexPath:self.currentIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        [tableView selectRowAtIndexPath:self.currentIndexPath animated:NO scrollPosition:UITableViewScrollPositionBottom];
    }
}

-(void)removeKeyboardObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mask - table view delegate && data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"section count %@", @(self.fetchResultController.sections.count));
    return self.fetchResultController.sections.count ;
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // return self.dataArray.count;
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchResultController.sections[section];
    
    return [sectionInfo numberOfObjects];
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WriteCaseSaveCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WriteCaseSaveCell"];
    cell.autoresizesSubviews = NO;
    [self configureCell:cell AtIndexPath:indexPath];
    
    return cell;
}
-(void)configureCell:(WriteCaseSaveCell*)cell AtIndexPath:(NSIndexPath*)indexPath
{
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    Node *tempNode = [self.fetchResultController objectAtIndexPath:indexPath];
    cell.textViewDelegate = self;
    UILabel *cellLabel = (UILabel*)[cell viewWithTag:1001];
    UITextView *textView = (UITextView*)[cell viewWithTag:1002];
    
    
    cellLabel.text = tempNode.nodeName;
    textView.text = ([tempNode.nodeContent isEqualToString:tempNode.nodeName]) ? @" ": tempNode.nodeContent;
    [textView layoutIfNeeded];
    //    if(indexPath.row == 0) {
    //        cellLabel.text = @"主诉";
    //      //  textView.text = [self.dataArray objectAtIndex:indexPath.row];
    //        textView.text = tempNode.nodeName
    //    }else {
    //        cellLabel.text = @"现病史";
    //        textView.text = [self.dataArray objectAtIndex:indexPath.row];
    //    }
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
#pragma mask - WriteCaseSaveCell  delegate
-(void)textViewCell:(WriteCaseSaveCell *)cell didChangeText:(NSString *)text
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    Node *tempNode = [self.fetchResultController objectAtIndexPath:indexPath];
    tempNode.nodeContent = text;
    [self.coreDataStack saveContext];
}
-(void)textViewDidBeginEditing:(UITextView *)textView withCellIndexPath:(NSIndexPath *)indexPath
{
    [self updateButtonState];
    self.isBeginEdit = NO;

    self.currentIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    self.currentTextView = textView;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    WriteCaseSaveCell *cell =(WriteCaseSaveCell*) [tableView cellForRowAtIndexPath:indexPath];
    UILabel *label =(UILabel*) [cell viewWithTag:1001];
    UITextView *textView = (UITextView*)[cell viewWithTag:1002];
    self.selectedStr = label.text;
    self.textViewContent = textView.text;
    self.currentIndexPath = indexPath;
    
    if ([label.text isEqualToString:@"主诉"]) {
        [self performSegueWithIdentifier:@"firstSegue" sender:nil];

    }else{
        [self performSegueWithIdentifier:@"EditCaseSegue" sender:nil];
    }
}
#pragma mask - fetch view controller delegate
/// fetch result controller delegate
-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}
-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeInsert:{
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }
        case NSFetchedResultsChangeDelete:{
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }
        case NSFetchedResultsChangeUpdate:{
            
            if (self.isBeginEdit) {
                WriteCaseSaveCell *cell =(WriteCaseSaveCell*) [self.tableView cellForRowAtIndexPath:indexPath];
                [self configureCell:cell AtIndexPath:indexPath];
            }
            
        }
            
        default:
            break;
    }
}
-(void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:sectionIndex];
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        default:
            break;
    }
}
-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"EditCaseSegue"]) {
        self.isBeginEdit = YES;
        
        UINavigationController *nav = (UINavigationController*)segue.destinationViewController;
        
        WriteCaseEditViewController *writeVC = (WriteCaseEditViewController*)[nav.viewControllers firstObject];
        writeVC.labelString = self.selectedStr;
        writeVC.Editdelegate = self;
        writeVC.textViewContent = self.textViewContent;
        writeVC.tempPatient = self.tempPatient;
    
    }else if([segue.identifier isEqualToString:@"firstSegue"]){
        self.isBeginEdit = YES;

        UINavigationController *nav = (UINavigationController*)segue.destinationViewController;
        
        writeCaseFirstItemViewController *firstItem = (writeCaseFirstItemViewController*)[nav.viewControllers firstObject];
        firstItem.titleString = self.selectedStr;
        firstItem.delegate = self;
        firstItem.textViewContent = self.textViewContent;
    }
}
#pragma mask - write delegate
-(void)didWriteStringToMedicalRecord:(NSString *)writeString withKeyStr:(NSString *)keyStr
{
    
    Node *tempNode = [self.fetchResultController objectAtIndexPath:self.currentIndexPath];
    tempNode.nodeContent = writeString;
    [self.coreDataStack saveContext];
    
    [self updateButtonState];
}
-(void)didWriteWithString:(NSString *)writeString
{
    
    Node *tempNode = [self.fetchResultController objectAtIndexPath:self.currentIndexPath];
    tempNode.nodeContent = writeString;
    [self.coreDataStack saveContext];

    [self updateButtonState];

}
-(void)dealloc
{
    [self removeKeyboardObserver];
}


///helper method
#pragma mask - parase to json data
-(NSData*)convertToJSONDataFromList:(id)listData
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:listData options:NSJSONWritingPrettyPrinted error:&error];
    if ([jsonData length] > 0 && error == nil) {
        return jsonData;
    }else {
        return nil;
    }
}
-(NSString*)convertJSONDataToString:(NSData*)jsonData
{
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}
#pragma mask - parse to list
-(NSData*)convertStringToJSONData:(NSString*)jsonString
{
    return [jsonString dataUsingEncoding:NSUTF8StringEncoding];
}
-(id)convertJSONDataToList:(NSData*)jsonData
{
    NSError *error = nil;
    id list = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
    if (list != nil && error == nil) {
        return list;
    }else {
        NSLog(@"parse error");
    }
    return nil;
}


@end
