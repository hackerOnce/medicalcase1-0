//
//  CoreDataStack.m
//  CoreData
//
//  Created by GK on 15/4/4.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "CoreDataStack.h"
#import "Node.h"
#import "ParentNode.h"
#import "Template.h"
#import "Doctor.h"
#import "Patient.h"
#import "RecordBaseInfo.h"

@implementation CoreDataStack

static NSString *momdName = @"Model";

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.apphouse.CoreData" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
+(CoreDataStack *)sharedCoreDataStack
{
    static CoreDataStack *coreDataStack;
    static dispatch_once_t token;
    
    dispatch_once(&token,^{
        coreDataStack = [[CoreDataStack alloc] initSingle];
        //load data from plist
        [coreDataStack createManagedObjectFromPlistData];
        
    });
    return coreDataStack;
}
-(instancetype)initSingle
{
    if(self = [super init])
    {
        //load data from plist to core data
    
    }
    return self;

}
-(instancetype)init
{
    return  [CoreDataStack sharedCoreDataStack];
}
-(NSManagedObjectContext *)privateContext
{
    if (!_privateContext) {
        _privateContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _privateContext.persistentStoreCoordinator = self.managedObjectContext.persistentStoreCoordinator;

    }
    return _privateContext;
}
- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:momdName withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"MedicalCase.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}
- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext{
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}
#pragma mask - create entity or NSmanagedObject with data
-(Node *)createManagedObjectEntityForNameNodeAndWithDicData:(NSDictionary*)dicData
{
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName: [Node entityName]inManagedObjectContext:self.managedObjectContext];
    Node *node = [[Node alloc] initWithEntity:entityDesc insertIntoManagedObjectContext:self.managedObjectContext];
    
    if ([dicData.allKeys containsObject:@"nodeName"]) {
        node.nodeName =[dicData objectForKey:@"nodeName"];
    }
    if ([dicData.allKeys containsObject:@"nodeType"]) {
        node.nodeType = [dicData objectForKey:@"nodeType"]; //0 : from origin data ,1 : from custom data
    }else {
        node.nodeType = [NSNumber numberWithInt:0];
    }
    if ([dicData.allKeys containsObject:@"nodeContent"]) {
        node.nodeContent = [dicData objectForKey:@"nodeContent"];
    }else {
        node.nodeContent = node.nodeName;
    }
    if([dicData.allKeys containsObject:@"nodeIndex"]){
        node.nodeIndex = [dicData objectForKey:@"nodeIndex"];
    }else {
        node.nodeIndex = [NSNumber numberWithInt:0];
    }
    
    if ([node.nodeName isEqualToString:@"入院记录"]) {
        node.nodeIdentifier =  @"ihefe101";
    }
    if ([dicData.allKeys containsObject:@"childNode"]) {
        NSArray *childArray = [dicData objectForKey:@"childNode"];
        
        NSEntityDescription *entityDescP = [NSEntityDescription entityForName: [ParentNode entityName]inManagedObjectContext:self.managedObjectContext];
        ParentNode *nodeP = [[ParentNode alloc] initWithEntity:entityDescP insertIntoManagedObjectContext:self.managedObjectContext];
        nodeP.nodeName = node.nodeName;
    
        NSMutableOrderedSet *childNodes = [[NSMutableOrderedSet alloc] initWithOrderedSet:nodeP.nodes];
        
        NSUInteger index = 1;
        for (NSDictionary *subNodeDic in childArray) {
            node.hasSubNode = [NSNumber numberWithBool:YES] ;
            Node *subNode = [self createManagedObjectEntityForNameNodeAndWithDicData:subNodeDic];
        
            subNode.nodeIdentifier = [node.nodeIdentifier stringByAppendingString:[NSString stringWithFormat:@"%@",index > 10 ? @(index) : [NSString stringWithFormat:@"0%@",@(index)]]];
            [childNodes addObject:subNode];
            
            index += 1;

        }
        nodeP.nodes =[[NSOrderedSet alloc] initWithOrderedSet:childNodes];
    }
    return node;
}
#pragma mask - create managed object Template
///create managed object Template
-(void)createManagedObjectTemplateWithDic:(NSDictionary*)dic  ForNodeWithNodeName:(NSString *)nodeName
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"nodeName = %@",nodeName];
    NSArray *tempArray = [self fetchNSManagedObjectEntityWithName:[Node entityName] withNSPredicate:predicate setUpFetchRequestResultType:NSCountResultType isSetUpResultType:NO setUpFetchRequestSortDescriptors:nil isSetupSortDescriptors:NO];
    
    Node *node = (Node*)[tempArray firstObject];
    
    NSEntityDescription *templateDesc = [NSEntityDescription entityForName: [Template entityName]inManagedObjectContext:self.managedObjectContext];
    Template *template = [[Template alloc] initWithEntity:templateDesc insertIntoManagedObjectContext:self.managedObjectContext];
    template.node = node;
    
    if ([dic.allKeys containsObject:@"condition"]) {
        template.condition = dic[@"condition"];
    }
    if ([dic.allKeys containsObject:@"content"]) {
        template.content = dic[@"content"];
    }
    if ([dic.allKeys containsObject:@"gender"]) {
        template.gender = dic[@"gender"];
    }
    if ([dic.allKeys containsObject:@"ageHigh"]) {
        template.ageHigh = dic[@"ageHigh"];
    }
    if ([dic.allKeys containsObject:@"admittingDiagnosis"]) {
        template.admittingDiagnosis = dic[@"admittingDiagnosis"];
    }
    if ([dic.allKeys containsObject:@"simultaneousPhenomenon"]) {
        template.simultaneousPhenomenon  = dic[@"simultaneousPhenomenon"];
    }
    if ([dic.allKeys containsObject:@"ageLow"]) {
        template.ageLow = dic[@"ageLow"];
    }
    if ([dic.allKeys containsObject:@"cardinalSymptom"]) {
        template.cardinalSymptom = dic[@"cardinalSymptom"];
    }
    
    if ([dic.allKeys containsObject:@"nodeID"]) {
        template.nodeID = dic[@"nodeID"];
    }
    if ([dic.allKeys containsObject:@"updatedTime"]) {
        template.nodeID = dic[@"updatedTime"];
    }
    NSDate *newDate = [NSDate date];
//    NSTimeZone *zone = [NSTimeZone systemTimeZone];
//    NSTimeInterval interval = [zone secondsFromGMTForDate:newDate];
//    NSDate *localDate = [newDate dateByAddingTimeInterval:interval];
    template.createDate = newDate;
    template.section = [self getYearAndMonthWithDateStr:newDate];

    ///for testpo
//    NSDateFormatter *f = [[NSDateFormatter alloc] init];
//    NSDate *d = [f dateFromString:@"2012-04-08 12:50:54.601"];
//    template.createDate = d;
//    template.section = [self getYearAndMonthWithDateStr:d];

    [self saveContext];
}
-(NSString*)getYearAndMonthWithDateStr:(NSDate*)date
{
    NSTimeZone *zone = [NSTimeZone systemTimeZone];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM"];
    [formatter setTimeZone:zone];
    NSString *dateStr = [formatter stringFromDate:date];
    
    return dateStr;
}

#pragma mask - load data and create managed object from plist
-(void)createManagedObjectFromPlistData
{
    //load data from plist
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"coreDataTestData" ofType:@"plist"];
    NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    [self printDictionary:dataDic];
    
    //if fetch result array count is 0 ,create managed object
    int count = [self fetchNSManagedObjectEntityCountWithName:@"Node"];
    if(count == 0) {
        //create managed object
        [self createManagedObjectEntityForNameNodeAndWithDicData:dataDic];
        [self saveContext];
    }

    //for test fetch
    NSArray *testArray = [self fetchNSManagedObjectEntityWithName:@"Node" withNSPredicate:nil setUpFetchRequestResultType:NSManagedObjectIDResultType isSetUpResultType:NO setUpFetchRequestSortDescriptors:nil isSetupSortDescriptors:NO];
    [self printArray:testArray];
}
#pragma  mask - fetch NSmanagedObject Template
///fetch NSManagedObject Template
-(NSArray*)fetchNSmanagedObjectEntityWithName:(NSString*)entityName
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"nodeName = %@",entityName];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createDate" ascending:YES];
    NSArray *tempArray = [self fetchNSManagedObjectEntityWithName:[Node entityName] withNSPredicate:predicate setUpFetchRequestResultType:NSCountResultType isSetUpResultType:NO setUpFetchRequestSortDescriptors:@[sortDescriptor] isSetupSortDescriptors:NO];
    
    if ([[tempArray firstObject] isKindOfClass:[Node class]]) {
        Node *tempNode = (Node*)[tempArray firstObject];
        
        array = [[NSMutableArray alloc] initWithArray:tempNode.templates.array];
    }
    return array;
}
#pragma mask - fetch NSmanagedObject count
-(int)fetchNSManagedObjectEntityCountWithName:(NSString*)entityName
{
    int count = 0;
    
    NSArray *countArray = [self fetchNSManagedObjectEntityWithName:entityName withNSPredicate:nil setUpFetchRequestResultType:NSCountResultType isSetUpResultType:YES setUpFetchRequestSortDescriptors:nil isSetupSortDescriptors:NO];
    
    count = [[countArray firstObject] intValue];
    
    return count;
}
#pragma mask - fetch NSmanagedObject
-(NSArray*)fetchNSManagedObjectEntityWithName:(NSString*)entityName withNSPredicate:(NSPredicate*)predicate setUpFetchRequestResultType:(NSFetchRequestResultType)fetchResultType isSetUpResultType:(BOOL)isSetUpResultType setUpFetchRequestSortDescriptors:(NSArray*)sortDescriptors isSetupSortDescriptors:(BOOL)isSetupSortDescriptors
{
    NSMutableArray *resultArray;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:entityName];
    if (predicate != nil) {
        fetchRequest.predicate = predicate;
    }

    if (isSetUpResultType) {
        fetchRequest.resultType = fetchResultType;
    }
    
    if (isSetupSortDescriptors) {
        fetchRequest.sortDescriptors = sortDescriptors;
    }
    NSError *error;
    
    NSArray *tempArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if(error){
        NSLog(@"fetch error %@",error.description);
    }
    if (tempArray.count == 0) {
        NSLog(@"you should first create entity : %@,then fetch it",entityName);
        NSLog(@"fetch error");
        NSLog(@"or because this is first run,so take easy");
        
    }
    resultArray = [[NSMutableArray alloc] initWithArray:tempArray];
    
    return resultArray ;
}


#pragma mask - medical case management
///doctor dic:dID,dName,dProfessionalTitle,dept,medicalTeam

///patients  is a array,elevment is a dictionary;
-(void)entityInitDoctorManagementWithDoctorDic:(NSDictionary*)doctorDic
{
    
    NSString *dName = doctorDic[@"dName"];
    NSString *dID  = doctorDic[@"dID"];
    NSArray *resultA = [self fetchDoctorEntityWithName:dName dID:dID];
    if (resultA.count == 0) {
        NSMutableArray *patients;
        Doctor *doctor = [self createDoctorEntityWithDataDic:doctorDic inContext:self.privateContext];
        
        if([doctorDic.allKeys containsObject:@"patients"]){
            NSArray *temp = (NSArray*)doctorDic[@"patients"];
            patients =[NSMutableArray arrayWithArray: temp];
        }
        [self.privateContext performBlockAndWait:^{
            
            for (NSDictionary *tempPatient in patients) {
                [self createPatientEntityWithDataDic:tempPatient inContext:self.privateContext forDoctor:doctor];
                ;
            }
            
            NSError *error;
            [self.privateContext save:&error];
            
            if (error== nil) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kDidCompletedAsyncInitEntity object:nil];
            }
        }];

    }else {
    
        [[NSNotificationCenter defaultCenter] postNotificationName:kDidCompletedAsyncInitEntity object:nil];
        NSLog(@"该医生的信息已经存在数据库中");
    }
}

///init record case depend on patient
-(void)createRecordCaseWithPatient:(Patient*)patient inContext:(NSManagedObjectContext*)context
{
    for (NSString *caseType in [self allCaseType]) {
        
        NSEntityDescription *entityDesc = [NSEntityDescription entityForName: [RecordBaseInfo entityName]inManagedObjectContext:context];
        RecordBaseInfo *recordBaseInfo = [[RecordBaseInfo alloc] initWithEntity:entityDesc insertIntoManagedObjectContext:context];
        
        recordBaseInfo.patient = patient;

        recordBaseInfo.caseType = caseType;
        recordBaseInfo.caseState = @"未创建";

      //  [context save:NULL];
    }
}

///create docotor only for a doctor
-(Doctor*)createDoctorEntityWithDataDic:(NSDictionary*)dataDic inContext:(NSManagedObjectContext*)context
{
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName: [Doctor entityName]inManagedObjectContext:context];
    Doctor *doctor = [[Doctor alloc] initWithEntity:entityDesc insertIntoManagedObjectContext:context];
    [self updateDoctor:doctor withDoctorInfo:dataDic];
    
    [context save:NULL];

    return doctor;
}
-(Doctor*)updateDoctor:(Doctor*)doctor withDoctorInfo:(NSDictionary*)dataDic
{
    if ([dataDic.allKeys containsObject:@"dID" ]) {
        doctor.dID = (NSString*)dataDic[@"dID"];
    }
    if ([dataDic.allKeys containsObject:@"dName"]) {
        doctor.dName = (NSString*)dataDic[@"dName"];
    }
    if ([dataDic.allKeys containsObject:@"dProfessionalTitle"]) {
        doctor.dProfessionalTitle = (NSString*)dataDic[@"dProfessionalTitle"];
    }
    if ([dataDic.allKeys containsObject:@"dept"]) {
        doctor.dept = (NSString*)dataDic[@"dept"];
    }
    if ([dataDic.allKeys containsObject:@"medicalTeam"]) {
        doctor.medicalTeam = (NSString*)dataDic[@"medicalTeam"];
    }

    return doctor;
}
/*
 #define    NSString *patientState = @"patientState";
 #define    NSString *createdTime = @"createdTime";
 #define    NSString *lastModifyTime = @"lastModifyTime"
 #define    NSString *archivedTime = @"archivedTime"
 #define    NSString *casePresenter = @"casePresenter"
 #define    NSString *caseContent = @"caseContent"
 #define    NSString *caseType = @"caseType"
 #define    NSString *caseState = @"caseState"

 */

///create patient entity
///doctorInfo dictionary residentDoctorName
///                      attendingPhysicianDoctorName
///                      chiefPhysicianDoctorName
///                      chiefPhysicianDoctorID
///attendingPhysicianDoctorID
///residentDoctorID
-(void)updatePatient:(Patient*)patient WithDictionary:(NSDictionary*)dataDic
{
    if ([dataDic.allKeys containsObject:@"residentDoctorName"]) {
        patient.residentDoctorname = dataDic[@"residentDoctorName"];
    }
    if ([dataDic.allKeys containsObject:@"residentDoctorID"]) {
        patient.residentDoctorID = dataDic[@"residentDoctorID"];
    }
    if ([dataDic.allKeys containsObject:@"pName"]) {
        patient.pName = (NSString*)dataDic[@"pName"];
    }
    if ([dataDic.allKeys containsObject:@"pID"]) {
        patient.pID = (NSString*)dataDic[@"pID"];
    }

    
    if ([dataDic.allKeys containsObject:@"attendingPhysicianDoctorName"]) {
        patient.attendingPhysicianDoctorName = dataDic[@"attendingPhysicianDoctorName"];
    }
    if ([dataDic.allKeys containsObject:@"attendingPhysicianDoctorID"]) {
        patient.attendingPhysicianDoctorID = dataDic[@"attendingPhysicianDoctorID"];
    }
    if ([dataDic.allKeys containsObject:@"chiefPhysicianDoctorID"]) {
        patient.chiefPhysicianDoctorID =dataDic[@"chiefPhysicianDoctorID"];
    }
    
    if ([dataDic.allKeys containsObject:@"chiefPhysicianDoctorName"]) {
        patient.chiefPhysicianDoctorName =dataDic[@"chiefPhysicianDoctorName"];
    }
    if ([dataDic.allKeys containsObject:@"pName"]) {
        patient.pName = (NSString*)dataDic[@"pName"];
    }
    if ([dataDic.allKeys containsObject:@"pID"]) {
        patient.pID = (NSString*)dataDic[@"pID"];
    }

    if ([dataDic.allKeys containsObject:@"pGender"]) {
        patient.pGender = (NSString*)dataDic[@"pGender"];
    }
    
    if ([dataDic.allKeys containsObject:@"pAge" ]) {
        patient.pAge = (NSString*)dataDic[@"pAge"];
    }
    if ([dataDic.allKeys containsObject:@"pCity"]) {
        patient.pCity = (NSString*)dataDic[@"pCity"];
    }
    if ([dataDic.allKeys containsObject:@"pProvince" ]) {
        patient.pProvince = (NSString*)dataDic[@"pProvince"];
    }
    if ([dataDic.allKeys containsObject:@"pDetailAddress"]) {
        patient.pDetailAddress = (NSString*)dataDic[@"pDetailAddress"];
    }
    if ([dataDic.allKeys containsObject:@"pDept" ]) {
        patient.pDept = (NSString*)dataDic[@"pDept"];
    }
    if ([dataDic.allKeys containsObject:@"pBedNum"]) {
        patient.pBedNum = (NSString*)dataDic[@"pBedNum"];
    }
    
    if ([dataDic.allKeys containsObject:@"pProfession" ]) {
        patient.pProfession = (NSString*)dataDic[@"pProfession"];
    }
    if ([dataDic.allKeys containsObject:@"pMaritalStatus"]) {
        patient.pMaritalStatus = (NSString*)dataDic[@"pMaritalStatus"];
    }
    if ([dataDic.allKeys containsObject:@"pMobileNum" ]) {
        patient.pMobileNum = (NSString*)dataDic[@"pMobileNum"];
    }
    if ([dataDic.allKeys containsObject:@"pLinkman"]) {
        patient.pLinkman = (NSString*)dataDic[@"pLinkman"];
    }
    if ([dataDic.allKeys containsObject:@"pLinkmanMobileNum"]) {
        patient.pLinkmanMobileNum = (NSString*)dataDic[@"pLinkmanMobileNum"];
    }
    if ([dataDic.allKeys containsObject:@"pCountOfHospitalized" ]) {
        patient.pMobileNum = (NSString*)dataDic[@"pCountOfHospitalized"];
    }

    if ([dataDic.allKeys containsObject:@"patientState"]) {
        patient.patientState = (NSString*)dataDic[@"patientState"];
    }
}
-(void)createPatientEntityWithDataDic:(NSDictionary*)dataDic inContext:(NSManagedObjectContext*)context forDoctor:(Doctor*)doctor
{

    NSEntityDescription *entityDesc = [NSEntityDescription entityForName: [Patient entityName]inManagedObjectContext:context];
        Patient *patient = [[Patient alloc] initWithEntity:entityDesc insertIntoManagedObjectContext:context];
    
       [self updatePatient:patient WithDictionary:dataDic];

       //[self createRecordCaseWithPatient:patient inContext:context];

        patient.doctor = doctor;
    
       [self createRecordCaseWithPatient:patient inContext:context];
    //   [context save:NULL];
    //    [self saveContext];
}
-(void)createAndSavePatientEntityWithDataDic:(NSDictionary*)dataDic inContext:(NSManagedObjectContext*)context forDoctor:(Doctor*)doctor
{
    [self createPatientEntityWithDataDic:dataDic inContext:self.managedObjectContext forDoctor:doctor];
    [self saveContext];
}

///fetch  a doctor
-(NSArray*)fetchDoctorEntityWithName:(NSString*)entityName dID:(NSString*)dID
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    NSPredicate *predicate;
    if (dID != nil && entityName!=nil) {
        predicate = [NSPredicate predicateWithFormat:@"dName=%@ AND dID= %@",entityName,dID];
    }
    if(entityName == nil){
        predicate = [NSPredicate predicateWithFormat:@"dID=%@",dID];
    }
    if (dID == nil) {
        predicate = [NSPredicate predicateWithFormat:@"dName = %@",entityName];
    }
    
    NSArray *tempArray = [self fetchNSManagedObjectEntityWithName:[Doctor entityName] withNSPredicate:predicate setUpFetchRequestResultType:NSCountResultType isSetUpResultType:NO setUpFetchRequestSortDescriptors:nil isSetupSortDescriptors:NO];
    
    if ([[tempArray firstObject] isKindOfClass:[Doctor class]]) {
       // Doctor *tempDoctor = (Doctor*)[tempArray firstObject];
        array = [NSMutableArray arrayWithArray:tempArray];
    }
    return array;
}

//create Record base info
///data dic:
//@property (nonatomic, retain) NSDate * archivedTime;
//@property (nonatomic, retain) NSString * caseContent;
//@property (nonatomic, retain) NSString * casePresenter;
//@property (nonatomic, retain) NSString * caseState; 1
//@property (nonatomic, retain) NSString * caseType; 1
//@property (nonatomic, retain) NSDate * createdTime;
//@property (nonatomic, retain) NSDate * lastModifyTime;
///patientDIC : pName,pID
///创建病人的所有类型的病例
-(NSArray*)allCaseType{
    return @[@"入院记录",@"首次病程记录"];
}
///patient dic : pName,pID
///为一个病人创建所有类型的病例
-(void)createAllRecordCaseWithPatientDic:(NSDictionary*)patientDic {
    
    for (NSString *caseType in [self allCaseType]) {
        NSDictionary *dataDic = @{@"caseType":caseType,@"caseState":@"未创建"};

        [self createRecordBaseInfoEntityWithDataDic:dataDic forPatientDic:patientDic];
    }
    [self saveContext];
}
-(void)createRecordBaseInfoEntityWithDataDic:(NSDictionary*)dataDic forPatientDic:(NSDictionary*)patientDic
{
    NSString *tempPName = [patientDic objectForKey:@"pName"];
    NSString *tempPID = [patientDic objectForKey:@"pID"];
    
    NSArray *tempArray = [self fetchDoctorEntityWithName:tempPName dID:tempPID];
    if (tempArray.count == 1) {
        
        Patient *patient  =(Patient*)[tempArray firstObject];
        
        NSEntityDescription *entityDesc = [NSEntityDescription entityForName: [RecordBaseInfo entityName]inManagedObjectContext:self.managedObjectContext];
        RecordBaseInfo *recordBaseInfo = [[RecordBaseInfo alloc] initWithEntity:entityDesc insertIntoManagedObjectContext:self.managedObjectContext];
        
        recordBaseInfo.patient = patient;
        
        if ([dataDic.allKeys containsObject:@"caseType"]) {
            recordBaseInfo.caseType = [dataDic objectForKey:@"caseType"];
        }
        if ([dataDic.allKeys containsObject:@"caseState"]) {
            recordBaseInfo.caseState = [dataDic objectForKey:@"caseState"];
        }
      //  [self saveContext];
    }else {
        NSLog(@"根据所提供的病人姓名和病人ID得到了多个病人,病例的所属病人必须是唯一的");
        abort();
    }
}
///ceate record base info
///dataDIc: pName pID,caseState,lastModifyTime
///archivedTime;caseContent;casePresenter,createdTime
-(void)updateRecordBaseInfoEntityWithDataDic:(NSDictionary*)dataDic
{
    NSString *patientName = [dataDic objectForKey:@"pName"];
    NSString *patientID = [dataDic objectForKey:@"pID"];
    NSString *caseType = [dataDic objectForKey:@"caseType"];
//    if (caseType == nil) {
//        NSLog(@"传入参数的caseType不能为nil");
//        abort();
//    }
    if (patientName == nil && patientID == nil) {
        NSLog(@"传入参数的pName与pID不能同时为nil");
        abort();
    }
    
    RecordBaseInfo *tempCase = [self fetchRecordBaseInfoWithCaseType:caseType patientName:patientName patientID:patientID];
    
    if ([dataDic.allKeys containsObject:@"caseState"]) {
        tempCase.caseState = [dataDic objectForKey:@"caseState"];
    }
    if ([dataDic.allKeys containsObject:@"lastModifyTime"]) {
        tempCase.lastModifyTime = [dataDic objectForKey:@"lastModifyTime"];
    }
    if ([dataDic.allKeys containsObject:@"archivedTime"]) {
        tempCase.archivedTime = [dataDic objectForKey:@"archivedTime"];
    }
    if ([dataDic.allKeys containsObject:@"caseContent"]) {
        tempCase.caseContent = [dataDic objectForKey:@"caseContent"];
    }
    if ([dataDic.allKeys containsObject:@"casePresenter"]) {
        tempCase.casePresenter = [dataDic objectForKey:@"casePresenter"];
    }
    if ([dataDic.allKeys containsObject:@"createdTime"]) {
        tempCase.createdTime = [dataDic objectForKey:@"createdTime"];
    }

    [self saveContext];
    
}
///fetch patient all recordBaseInfo
-(NSArray*)fetchRecordBaseInfoWithPatientName:(NSString*)patientName patientID:(NSString*)patientID
{
    NSPredicate *predicate;
    if (patientName != nil && patientID!=nil ) {
        predicate = [NSPredicate predicateWithFormat:@"patient.pName = %@,patient.pID = %@",patientName,patientID];
    }
    if(patientID == nil){
        predicate = [NSPredicate predicateWithFormat:@"patient.pName = %@",patientName];
    }
    if (patientName == nil) {
        predicate = [NSPredicate predicateWithFormat:@"patient.pID = %@",patientID];
    }

    NSArray *tempArray = [self fetchNSManagedObjectEntityWithName:[RecordBaseInfo entityName] withNSPredicate:predicate setUpFetchRequestResultType:NO isSetUpResultType:NO setUpFetchRequestSortDescriptors:nil isSetupSortDescriptors:NO];
    return tempArray;
}
///fetch a special record case
-(RecordBaseInfo*)fetchRecordBaseInfoWithCaseType:(NSString*)caseType patientName:(NSString*)pName patientID:(NSString*)pID
{
    NSArray *tempArray = [self fetchRecordBaseInfoWithPatientName:pName patientID:pID];
    if ([tempArray.firstObject isKindOfClass:[RecordBaseInfo class]]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"caseType=%@",caseType];

        NSArray *result = [tempArray filteredArrayUsingPredicate:predicate];
        if (result.count == 1) {
            return (RecordBaseInfo*)result.firstObject;
        }else if (result.count == 0){
            NSLog(@"没有病人所对应的病例类型的病例");
            return nil;
        }else {
            NSLog(@"core data stack RecordBaseInfo:同一病人同一病例类型返回了多个病例");
            abort();
        }
    }else {
        return nil;
    }
    
}
///fetch  a patient
-(NSArray*)fetchPatientEntityWithName:(NSString*)pName dID:(NSString*)pID
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    NSPredicate *predicate;
    if (pID != nil && pName!=nil) {
        predicate = [NSPredicate predicateWithFormat:@"pName = %@,pID = %@",pName,pID];
    }
    if(pName == nil){
        predicate = [NSPredicate predicateWithFormat:@"pID = %@",pID];
    }
    if (pID == nil) {
        predicate = [NSPredicate predicateWithFormat:@"pName = %@",pName];
    }
    NSArray *tempArray = [self fetchNSManagedObjectEntityWithName:[Patient entityName] withNSPredicate:predicate setUpFetchRequestResultType:NSCountResultType isSetUpResultType:NO setUpFetchRequestSortDescriptors:nil isSetupSortDescriptors:NO];
    
    if ([[tempArray firstObject] isKindOfClass:[Doctor class]]) {
        // Doctor *tempDoctor = (Doctor*)[tempArray firstObject];
        array = [NSMutableArray arrayWithArray:tempArray];
    }
    return array;
}
///update patient
-(void)updatePatientWithPatientInfo:(NSDictionary*)patientInfo
{
    NSString *patientName = [patientInfo objectForKey:@"pName"];
    NSString *patientID = [patientInfo objectForKey:@"pID"];
    
  NSArray *result = [self fetchPatientEntityWithName:patientName dID:patientID];
    if (result.count == 1) {
        Patient *patient =(Patient*) [result firstObject];
        [self updatePatient:patient WithDictionary:patientInfo];
        
        [self saveContext];
    }else if(result.count == 0){
        NSLog(@"没有找到病人 %@，id:%@",patientName,patientID);

    }else {
        NSLog(@"找到多个病人 %@，id:%@",patientName,patientID);
        abort();
    }
}
///update doctor
-(void)updateDoctorWithDoctorInfo:(NSDictionary*)doctorInfo
{
    NSString *dName = [doctorInfo objectForKey:@"dName"];
    NSString *dID = [doctorInfo objectForKey:@"dID"];
    
    NSArray *result = [self fetchDoctorEntityWithName:dName dID:dID];
    if (result.count == 1) {
        Doctor *doctor =(Doctor*) [result firstObject];
        [self updateDoctor:doctor withDoctorInfo:doctorInfo];
        
        [self saveContext];
    }else if(result.count == 0){
        NSLog(@"没有找到医生 %@，id:%@",dName,dID);
        
    }else {
        NSLog(@"找到多个医生 %@，id:%@",dName,dID);
        abort();
    }
}
#pragma mask - ii
-(void)printDictionary:(NSDictionary*)dic
{
    for (NSString *key in dic.allKeys) {
        
        id value = [dic objectForKey:key];
        if ([value isKindOfClass:[NSString class]]) {
            NSLog(@"%@ : %@",key,value);
        }else {
            if ([value isKindOfClass:[NSArray class]]) {
                NSArray *tempArray = (NSArray*)value;
                NSLog(@"%@ : %@",key,[NSNumber numberWithLong:tempArray.count]);
            }
        }
    }
}
#pragma mask - helper
-(void)printArray:(NSArray*)arr
{
    for (id idObj in arr) {
        if ([idObj isKindOfClass:[Node class]]) {
            Node *tempNode = (Node*)idObj;
            NSLog(@"nodeName is %@",tempNode.nodeName);
            NSLog(@"nodeContent is %@",tempNode.nodeContent);
            NSLog(@"nodeIndex is %@",tempNode.nodeIndex);
            NSLog(@"nodeType is %@",tempNode.nodeType);
           // NSLog(@"node childs count is %@",[[NSNumber alloc] initWithLong:tempNode.nodes.count ]);
        }
    }
}
@end
