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
#import "CaseContent.h"


@interface CoreDataStack()
@property (nonatomic,strong) NSArray *recordCaseTypes;
@end
@implementation CoreDataStack

static NSString *momdName = @"Model";

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
-(NSArray *)recordCaseTypes
{
    return @[@"入院记录",@"首次病程记录"];
}
- (NSURL *)applicationDocumentsDirectory {
        return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
+(CoreDataStack *)sharedCoreDataStack
{
    static CoreDataStack *coreDataStack;
    static dispatch_once_t token;
    
    dispatch_once(&token,^{
        coreDataStack = [[CoreDataStack alloc] initSingle];
        
    });
    return coreDataStack;
}
-(instancetype)initSingle
{
    if(self = [super init])
    {
        _nodeRow = 0;
        _nodeSection = 0;
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

    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:momdName withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}


- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
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

-(void)savePrivateContext
{
    NSManagedObjectContext *managedObjectContext = self.privateContext;
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
#pragma mask - save node field to core data
-(void)saveFieldNodeListToCoreData
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"FieldNodeList" ofType:@"plist"];
    NSArray *tempArray = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
    
    
    NSDictionary *tempDict = [tempArray firstObject];
    
    NSInteger count = [self fetchCountNSManagedObjectEntity:[Node entityName] WithNSPredicate:nil];
    if (count == 0) {
        
        [self createNodeManagedObjectWithDictData:tempDict];
        
        [self saveContext];
    }
    
}

-(Node*)createNodeManagedObjectWithDictData:(NSDictionary*)dictData
{
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName: [Node entityName]inManagedObjectContext:self.managedObjectContext];
    Node *node = [[Node alloc] initWithEntity:entityDesc insertIntoManagedObjectContext:self.managedObjectContext];
    
    if ([dictData.allKeys containsObject:@"nodeName"]) {
        node.nodeName =[dictData objectForKey:@"nodeName"];
    }
    if ([dictData.allKeys containsObject:@"nodeEnglish"]) {
        node.nodeEnglish =[dictData objectForKey:@"nodeEnglish"];
    }
    if ([dictData.allKeys containsObject:@"nodeContent"]) {
        node.nodeContent =[dictData objectForKey:@"nodeContent"];
    }
    if ([dictData.allKeys containsObject:@"nodeEnglish"]) {
        node.nodeEnglish =[dictData objectForKey:@"nodeEnglish"];
    }
    if ([dictData.allKeys containsObject:@"nodeIndex"]) {
        node.nodeIndex = @([[dictData objectForKey:@"nodeIndex"] integerValue]);
    }
    if ([dictData.allKeys containsObject:@"nodeAge"]) {
        node.nodeAge = [dictData objectForKey:@"nodeAge"];
    }
    
    if ([node.nodeName isEqualToString:@"rootField"]) {
        node.nodeSection = @(0);
        node.nodeRow = @(0);
    }
    if ([dictData.allKeys containsObject:@"nodeChilds"]) {
        
        NSArray *childArray = [dictData objectForKey:@"nodeChilds"];
        NSEntityDescription *parentDesc = [NSEntityDescription entityForName: [ParentNode entityName]inManagedObjectContext:self.managedObjectContext];
        ParentNode *nodeP = [[ParentNode alloc] initWithEntity:parentDesc insertIntoManagedObjectContext:self.managedObjectContext];
        nodeP.nodeName = node.nodeName;
        
        NSMutableOrderedSet *childNodes = [[NSMutableOrderedSet alloc] initWithOrderedSet:nodeP.nodes];
        
        for (NSDictionary *subNodeDict in childArray) {
            
            node.hasSubNode = [NSNumber numberWithBool:YES] ;
            Node *subNode = [self createNodeManagedObjectWithDictData:subNodeDict];
            [childNodes addObject:subNode];
        }
        nodeP.nodes = [[NSOrderedSet alloc] initWithOrderedSet:childNodes];
    }
    
    return node;
}

///fetch managed object count
-(NSInteger)fetchCountNSManagedObjectEntity:(NSString*)entityName WithNSPredicate:(NSPredicate*)predicate
{
    NSInteger count = 0;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:entityName];
    if (predicate == nil) {
        
    }else {
        fetchRequest.predicate = predicate;
    }
    NSError *error;
    NSArray *tempArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if(error){
        NSLog(@"fetch entity %@ error %@",entityName,error.description);
        abort();
    }
    count = tempArray.count;
    return count;
}

-(ParentNode*)fetchParentNodeWithNodeEntityName:(NSString*)parentName
{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"nodeName = %@",parentName];
    
    //NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createDate" ascending:YES];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:[ParentNode entityName]];
    
    fetchRequest.predicate = predicate;
    
    NSError *error;
    
    NSArray *tempArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if(error){
        NSLog(@"fetch nodeName= %@ error %@",parentName,error.description);
        abort();
        
    }
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:tempArray];
    
    if (array.count == 1) {
        ParentNode *parentNode = (ParentNode*)[array firstObject];
        
        for (Node *node in parentNode.nodes) {
            NSLog(@"node name %@",node.nodeName);
        }
        return parentNode;
    }else {
        abort();
        return nil;
    }
    
}

-(NSArray*)fetchRecordWithDict:(NSDictionary*)dict isReturnNil:(BOOL)isReturnNil
{

    NSString *dID;
    NSString *pID;
    NSString *caseType = @"";
    NSPredicate *predicate;
   // RecordBaseInfo *recordBaseInfo;
    if ([dict.allKeys containsObject:@"dID"]) {
        dID = dict[@"dID"];
    }
    if ([dict.allKeys containsObject:@"pID"]) {
        pID = dict[@"pID"];
    }
    if ([dict.allKeys containsObject:@"did"]) {
        dID = dict[@"did"];
    }
    if ([dict.allKeys containsObject:@"pid"]) {
        pID = dict[@"pid"];
    }
    if ([dict.allKeys containsObject:@"caseType"]) {
        caseType = dict[@"caseType"];
    }
    if ([caseType isEqualToString:@""]) {
        predicate = [NSPredicate predicateWithFormat:@"pID = %@ AND dID = %@",pID,dID];
    }else {
        predicate = [NSPredicate predicateWithFormat:@"pID = %@ AND dID = %@ AND caseType=%@",pID,dID,caseType];
    }
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:[RecordBaseInfo entityName]];
    request.predicate = predicate;
    
    NSError *error;
    NSArray *tempArray = [self.managedObjectContext executeFetchRequest:request error:&error];

    if(error){
       NSLog(@"fetch error %@",error.description);
    }
    
    if (tempArray.count == 0) {
        
        if (isReturnNil) {
            return nil;
        }else {
            
            NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithDictionary:dict];
            [tempDict setObject:@"未创建" forKey:@"caseStatus"];
            for (NSString *caseType in self.recordCaseTypes) {
                [tempDict setObject:caseType forKey:@"caseType"];
                [self recordCreateWithDict:tempDict];
            }
           
          return [self fetchRecordWithDict:dict isReturnNil:NO];
        }
        
    }else {
        
        for (RecordBaseInfo *recordBaseInfo in tempArray) {
            if ([recordBaseInfo.caseType isEqualToString:@"入院记录" ]) {
                [self updateRecord:recordBaseInfo dataWithDict:dict];
                [self updateCaseContent:recordBaseInfo.caseContent dataWithDict:dict];
                [self updatePatient:recordBaseInfo.patient dataWithDict:dict];
            }else {
               //更新其他类型病历
            }
        }
        
        [self saveContext];
    }
    
    return tempArray;
}

-(void)recordUpdatedWithDict:(NSDictionary*)dict
{
    NSArray *records = [self fetchRecordWithDict:dict isReturnNil:NO];
    
    for (RecordBaseInfo *recordToUpdated in records) {
        [self updatePatient:recordToUpdated.patient dataWithDict:dict];
        [self updateCaseContent:recordToUpdated.caseContent dataWithDict:dict];
        [self updateRecord:recordToUpdated dataWithDict:dict];
        
        [self saveContext];
    }
}
-(void)recordCreateWithDict:(NSDictionary*)dict
{
    NSString *dID;
    NSString *pID;
    NSString *caseType = @"";
    NSPredicate *predicate;

    if ([dict.allKeys containsObject:@"dID"]) {
        dID = dict[@"dID"];
    }
    if ([dict.allKeys containsObject:@"pID"]) {
        pID = dict[@"pID"];
    }
    if ([dict.allKeys containsObject:@"dID"]) {
        dID = dict[@"dID"];
    }
    if ([dict.allKeys containsObject:@"pID"]) {
        pID = dict[@"pID"];
    }
    if ([dict.allKeys containsObject:@"did"]) {
        dID = dict[@"did"];
    }
    if ([dict.allKeys containsObject:@"pid"]) {
        pID = dict[@"pid"];
    }
    
    if ([dict.allKeys containsObject:@"caseType"]) {
        caseType = dict[@"caseType"];
    }else {
        abort();
    }
    
    predicate = [NSPredicate predicateWithFormat:@"pID = %@ AND dID = %@ AND caseType=%@",pID,dID,caseType];

    NSInteger count = [self fetchCountNSManagedObjectEntity:[RecordBaseInfo  entityName] WithNSPredicate:predicate];
    if (count == 0) {
        //create
        NSEntityDescription *entityDesc = [NSEntityDescription entityForName: [RecordBaseInfo entityName]inManagedObjectContext:self.managedObjectContext];
        RecordBaseInfo *recordBaseInfo = [[RecordBaseInfo alloc] initWithEntity:entityDesc insertIntoManagedObjectContext:self.managedObjectContext];
        [self updateRecord:recordBaseInfo dataWithDict:dict];
        
        NSEntityDescription *entityDesc1 = [NSEntityDescription entityForName: [CaseContent entityName]inManagedObjectContext:self.managedObjectContext];
        CaseContent *caseContent = [[CaseContent alloc] initWithEntity:entityDesc1 insertIntoManagedObjectContext:self.managedObjectContext];
        [self updateCaseContent:caseContent dataWithDict:dict];
        
        recordBaseInfo.caseContent =  caseContent;
        
        NSEntityDescription *entityDesc2 = [NSEntityDescription entityForName: [Patient entityName]inManagedObjectContext:self.managedObjectContext];
        Patient *patient = [[Patient alloc] initWithEntity:entityDesc2 insertIntoManagedObjectContext:self.managedObjectContext];
        [self updatePatient:patient dataWithDict:dict];
        recordBaseInfo.patient = patient;
        [self saveContext];
    }else {
        
    }
    
}
-(void)updateCaseContent:(CaseContent*)caseContent dataWithDict:(NSDictionary*)dict
{
    if ([dict.allKeys containsObject:@"pID"]) {
        caseContent.pID = dict[@"pID"];
    }
    
    if ([dict.allKeys containsObject:@"pid"]) {
       caseContent.pID = dict[@"pid"];
    }
    
    if ([dict.allKeys containsObject:@"recordCaseType"]) {
        caseContent.recordCaseType = dict[@"recordCaseType"];
    }
    
    if ([dict.allKeys containsObject:@"chiefComplaint"]) {
        caseContent.chiefComplaint = dict[@"chiefComplaint"];
    }
    if ([dict.allKeys containsObject:@"historyOfPresentillness"]) {
        caseContent.historyOfPresentillness = dict[@"historyOfPresentillness"];
    }
    
    if ([dict.allKeys containsObject:@"personHistory"]) {
        caseContent.personHistory = dict[@"personHistory"];
    }
    if ([dict.allKeys containsObject:@"pastHistory"]) {
        caseContent.pastHistory = dict[@"pastHistory"];
    }
    
    if ([dict.allKeys containsObject:@"familyHistory"]) {
        caseContent.familyHistory = dict[@"familyHistory"];
    }
    if ([dict.allKeys containsObject:@"obstericalHistory"]) {
        caseContent.obstericalHistory = dict[@"obstericalHistory"];
    }
    
    
    if ([dict.allKeys containsObject:@"physicalExamination"]) {
        caseContent.physicalExamination = dict[@"physicalExamination"];
    }
    if ([dict.allKeys containsObject:@"systemsReview"]) {
        caseContent.systemsReview = dict[@"systemsReview"];
    }
    
    if ([dict.allKeys containsObject:@"specializedExamination"]) {
        caseContent.specializedExamination = dict[@"specializedExamination"];
    }
    if ([dict.allKeys containsObject:@"tentativeDiagnosis"]) {
        caseContent.tentativeDiagnosis = dict[@"tentativeDiagnosis"];
    }
    
    if ([dict.allKeys containsObject:@"admittingDiagnosis"]) {
        caseContent.admittingDiagnosis = dict[@"admittingDiagnosis"];
    }
    if ([dict.allKeys containsObject:@"confirmedDiagnosis"]) {
        caseContent.confirmedDiagnosis = dict[@"confirmedDiagnosis"];
    }
    
}
-(void)updateRecord:(RecordBaseInfo*)recordBaseInfo dataWithDict:(NSDictionary*)dict
{
    if ([dict.allKeys containsObject:@"dID"]) {
        recordBaseInfo.dID = dict[@"dID"];
    }
    if ([dict.allKeys containsObject:@"did"]) {
        recordBaseInfo.dID = dict[@"did"];
    }
    if ([dict.allKeys containsObject:@"dName"]) {
        recordBaseInfo.dName = dict[@"dName"];
    }
   
    if ([dict.allKeys containsObject:@"pID"]) {
        recordBaseInfo.pID = dict[@"pID"];
    }
    if ([dict.allKeys containsObject:@"pid"]) {
        recordBaseInfo.pID = dict[@"pid"];
    }
    if ([dict.allKeys containsObject:@"pName"]) {
        recordBaseInfo.pName = dict[@"pName"];
    }
    
    if ([dict.allKeys containsObject:@"caseID"]) {
        recordBaseInfo.caseID = dict[@"caseID"];
    }
    if ([dict.allKeys containsObject:@"casePresenter"]) {
        recordBaseInfo.casePresenter = dict[@"casePresenter"];
    }
    if ([dict.allKeys containsObject:@"caseEditStatus"]) {
        recordBaseInfo.caseEditStatus = dict[@"caseEditStatus"];
    }
    
    if ([dict.allKeys containsObject:@"caseStatus"]) {
        recordBaseInfo.caseStatus = dict[@"caseStatus"];
    }
    if ([dict.allKeys containsObject:@"caseType"]) {
        recordBaseInfo.caseType = dict[@"caseType"];
    }
    
    
    if ([dict.allKeys containsObject:@"residentdID"]) {
        recordBaseInfo.residentdID = dict[@"residentdID"];
    }
    if ([dict.allKeys containsObject:@"attendingPhysiciandID"]) {
        recordBaseInfo.attendingPhysiciandID = dict[@"attendingPhysiciandID"];
    }
    
    if ([dict.allKeys containsObject:@"createdDate"]) {
        recordBaseInfo.caseStatus = dict[@"createdDate"];
    }
    if ([dict.allKeys containsObject:@"updatedDate"]) {
        recordBaseInfo.updatedDate = dict[@"updatedDate"];
    }
    
    if ([dict.allKeys containsObject:@"dof"]) {
        recordBaseInfo.dof = dict[@"dof"];
    }
    if ([dict.allKeys containsObject:@"residentdName"]) {
        recordBaseInfo.residentdName = dict[@"residentdName"];
    }
    
    if ([dict.allKeys containsObject:@"attendingPhysiciandName"]) {
        recordBaseInfo.attendingPhysiciandName = dict[@"attendingPhysiciandName"];
    }
    if ([dict.allKeys containsObject:@"chiefPhysiciandID"]) {
        recordBaseInfo.chiefPhysiciandID = dict[@"chiefPhysiciandID"];
    
    }
    
}


-(Patient*)patientFetchWithDict:(NSDictionary*)dict isReturnNil:(BOOL)isReturnNil
{
    NSString *dID;
    NSString *pID;
    NSPredicate *predicate;
    Patient *patient;
    if ([dict.allKeys containsObject:@"dID"]) {
        dID = dict[@"dID"];
    } else if ([dict.allKeys containsObject:@"did"]) {
        dID = dict[@"did"];
    }
    if ([dict.allKeys containsObject:@"pid"]) {
        pID = dict[@"pid"];
    }else if ([dict.allKeys containsObject:@"pID"]) {
        pID = dict[@"pID"];
    }else{
        abort();
    }
    
    if (dID && pID) {
        predicate = [NSPredicate predicateWithFormat:@"pID = %@ AND dID = %@",pID,dID];
    }else if(pID) {
        predicate = [NSPredicate predicateWithFormat:@"pID = %@",pID];
    }
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:[Patient entityName]];
    request.predicate = predicate;
    
    NSError *error;
    NSArray *tempArray = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if(error){
        NSLog(@"fetch error %@",error.description);
    }
    
    if (tempArray.count == 0) {
        
        if (isReturnNil) {
            return nil;
        }else {
            [self patientCreateWithDict:dict];
            return [self patientFetchWithDict:dict isReturnNil:YES];
        }
        
    }else {
        patient = (Patient*)[tempArray firstObject];
        
        [self updatePatient:patient dataWithDict:dict];
        [self saveContext];
    }
    
    return patient;

}
-(void)patientCreateWithDict:(NSDictionary*)dict
{
    NSString *dID;
    NSString *pID;
    NSPredicate *predicate;
    
    if ([dict.allKeys containsObject:@"dID"]) {
        dID = dict[@"dID"];
    } else if ([dict.allKeys containsObject:@"did"]) {
        dID = dict[@"did"];
    }else {
        abort();
    }
    if ([dict.allKeys containsObject:@"pid"]) {
        pID = dict[@"pid"];
    }else if ([dict.allKeys containsObject:@"pID"]) {
        pID = dict[@"pID"];
    }else {
        abort();
    }
    
    predicate = [NSPredicate predicateWithFormat:@"pID = %@ AND dID = %@",pID,dID];
    
    NSInteger count = [self fetchCountNSManagedObjectEntity:[Patient  entityName] WithNSPredicate:predicate];
    if (count == 0) {
        //create
        NSEntityDescription *entityDesc = [NSEntityDescription entityForName: [Patient entityName]inManagedObjectContext:self.managedObjectContext];
        Patient *patient = [[Patient alloc] initWithEntity:entityDesc insertIntoManagedObjectContext:self.managedObjectContext];
        [self updatePatient:patient dataWithDict:dict];
        
        [self saveContext];
    }else {
        
    }
}
-(void)updatePatient:(Patient*)patient dataWithDict:(NSDictionary*)dict
{

    if ([dict.allKeys containsObject:@"pAdmitDate"]) {
        patient.pAdmitDate = dict[@"pAdmitDate"];
    }
    
    if ([dict.allKeys containsObject:@"dID"]) {
        patient.dID = dict[@"dID"];
    } else if ([dict.allKeys containsObject:@"did"]) {
        patient.dID = dict[@"did"];
    }
    if ([dict.allKeys containsObject:@"pid"]) {
        patient.pID = dict[@"pid"];
    }else if ([dict.allKeys containsObject:@"pID"]) {
        patient.pID = dict[@"pID"];
    }
    if ([dict.allKeys containsObject:@"pBedNum"]) {
        patient.pBedNum = dict[@"pBedNum"];
    }
    if ([dict.allKeys containsObject:@"pCity"]) {
        patient.pCity = dict[@"pCity"];
    }
    if ([dict.allKeys containsObject:@"pCountOfHospitalized"]) {
        patient.pCountOfHospitalized = dict[@"pCountOfHospitalized"];
    }
    if ([dict.allKeys containsObject:@"pDept"]) {
        patient.pDept = dict[@"pDept"];
    }
    
    if ([dict.allKeys containsObject:@"pDetailAddress"]) {
        patient.pDetailAddress = dict[@"pDetailAddress"];
    }
    if ([dict.allKeys containsObject:@"pGender"]) {
        patient.pGender = dict[@"pGender"];
    }
    if ([dict.allKeys containsObject:@"pLinkman"]) {
        patient.pBedNum = dict[@"pLinkman"];
    }
    
    if ([dict.allKeys containsObject:@"pLinkmanMobileNum"]) {
        patient.pLinkmanMobileNum = dict[@"pLinkmanMobileNum"];
    }
    if ([dict.allKeys containsObject:@"pMaritalStatus"]) {
        patient.pMaritalStatus = dict[@"pMaritalStatus"];
    }
    if ([dict.allKeys containsObject:@"pMobileNum"]) {
        patient.pMobileNum = dict[@"pMobileNum"];
    }
    if ([dict.allKeys containsObject:@"pName"]) {
        patient.pName = dict[@"pName"];
    }
    
    if ([dict.allKeys containsObject:@"pNation"]) {
        patient.pNation = dict[@"pNation"];
    }
    if ([dict.allKeys containsObject:@"pProfession"]) {
        patient.pProfession = dict[@"pProfession"];
    }
    if ([dict.allKeys containsObject:@"pProvince"]) {
        patient.pProvince = dict[@"pProvince"];
    }
    if ([dict.allKeys containsObject:@"pAge"]) {
        patient.pAge = dict[@"pAge"];
    }
    if ([dict.allKeys containsObject:@"dName"]) {
        patient.dName = dict[@"dName"];
    }
}


///for note book
-(NoteBook*)noteBookFetchWithDict:(NSDictionary*)dict
{
    NSString *dID;
    NSString *noteUUID;
    NSString *noteID;
    NSPredicate *predicate;
    
    if ([dict.allKeys containsObject:@"dID"]) {
        dID = [dict objectForKey:@"dID"];
    }
    assert(dID != nil);

    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithDictionary:dict];

    if ([dict.allKeys containsObject:@"noteID"]) {
        
        noteID = dict[@"noteID"];
        assert(noteID!=nil);
        predicate = [NSPredicate predicateWithFormat:@"dID=%@ AND noteID=%@",dID,noteID];

    }else {
        
        noteUUID = [self noteUUIDForNoteIdentifier];
        assert(noteUUID != nil);
        
        predicate = [NSPredicate predicateWithFormat:@"dID=%@ AND noteUUID=%@",dID,noteUUID];
        [tempDict setObject:noteUUID forKey:@"noteUUID"];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:noteUUID forKey:@"noteUUID"];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:[NoteBook entityName]];
    request.predicate = predicate;
    
    NSError *error;
    NSArray *tempArray = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (tempArray.count == 0) {
       return [self noteBookCreateWithDict:tempDict];
    }else {
        assert(tempArray.count == 1);
        NoteBook *note = (NoteBook*)[tempArray firstObject];
        
        [self updateNote:note withDict:tempDict];
        for (NoteContent *noteContent in note.contents) {
            
            if ([tempDict.allKeys containsObject:noteContent.contentType]) {
                NSDictionary *noteContentDict = tempDict[noteContent.contentType];
                [self updateNoteContent:noteContent WithDict:noteContentDict];
            }
        }
        return note;
    }
}

-(NoteBook*)noteBookCreateWithDict:(NSDictionary*)dict
{
    NSString *dID;
    NSString *noteUUID;
    
    if ([dict.allKeys containsObject:@"dID"]) {
        dID = [dict objectForKey:@"dID"];
    }
    assert(dID);

    if ([dict.allKeys containsObject:@"noteUUID"]) {
        noteUUID = [dict objectForKey:@"noteUUID"];
        assert(noteUUID != nil);

    }
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName: [NoteBook entityName]inManagedObjectContext:self.managedObjectContext];
    NoteBook *note = [[NoteBook alloc] initWithEntity:entityDesc insertIntoManagedObjectContext:self.managedObjectContext];
    
    NSMutableOrderedSet *orderSet = [[NSMutableOrderedSet alloc] initWithOrderedSet:note.contents];
    
    
    if ([dict.allKeys containsObject:@"noteContentS"]) {
        NSDictionary *tempDict = dict[@"noteContentS"];
        NoteContent *noteContent = [self noteContentCreateWithDict:tempDict];
        [orderSet addObject:noteContent];
    }
    if ([dict.allKeys containsObject:@"noteContentO"]) {
        NSDictionary *tempDict = dict[@"noteContentO"];
        NoteContent *noteContent = [self noteContentCreateWithDict:tempDict];
        [orderSet addObject:noteContent];
    }
    if ([dict.allKeys containsObject:@"noteContentA"]) {
        NSDictionary *tempDict = dict[@"noteContentA"];
        NoteContent *noteContent = [self noteContentCreateWithDict:tempDict];
        [orderSet addObject:noteContent];
    }
    if ([dict.allKeys containsObject:@"noteContentP"]) {
        NSDictionary *tempDict = dict[@"noteContentP"];
        NoteContent *noteContent = [self noteContentCreateWithDict:tempDict];
        [orderSet addObject:noteContent];
      //noteContent.noteBook = note;
    }
    
    note.contents = [[NSOrderedSet alloc] initWithOrderedSet:orderSet];
   
    [self updateNote:note withDict:dict];
    
    [self saveContext];
    
    return note;
    
}
-(NoteContent*)noteContentCreateWithDict:(NSDictionary*)dict
{
    NSEntityDescription *entityContent = [NSEntityDescription entityForName: [NoteContent entityName]inManagedObjectContext:self.managedObjectContext];
    NoteContent *noteContent = [[NoteContent alloc] initWithEntity:entityContent insertIntoManagedObjectContext:self.managedObjectContext];
    [self updateNoteContent:noteContent WithDict:dict];
    
    if ([dict.allKeys containsObject:@"medias"]) {
        
        NSArray *tempArray = (NSArray*)dict[@"medias"];
        for (NSDictionary *medict in tempArray) {
           MediaData *mediaData = [self mediaDataCreateWithDict:medict];
            mediaData.owner = noteContent;
        }
    }
    
    [self saveContext];
    
    return noteContent;
}
-(MediaData*)mediaDataCreateWithDict:(NSDictionary*)dict
{
    NSEntityDescription *entityContent = [NSEntityDescription entityForName: [MediaData entityName]inManagedObjectContext:self.managedObjectContext];
    MediaData *mediaData = [[MediaData alloc] initWithEntity:entityContent insertIntoManagedObjectContext:self.managedObjectContext];
    [self updateMediaData:mediaData withDict:dict];
    [self saveContext];
    
    return mediaData;
}
-(void)updateMediaData:(MediaData*)mediaData withDict:(NSDictionary*)dict
{
    if ([dict.allKeys containsObject:@"dataType"]) {
        mediaData.dataType = dict[@"dataType"];
    }
    if ([dict.allKeys containsObject:@"location"]) {
        mediaData.location = dict[@"location"];
    }
    if ([dict.allKeys containsObject:@"data"]) {
        mediaData.data = dict[@"data"];
    }
    if ([dict.allKeys containsObject:@"noteID"]) {
        mediaData.noteID = dict[@"noteID"];
    }
    if ([dict.allKeys containsObject:@"mediaURLString"]) {
        mediaData.mediaURLString = dict[@"mediaURLString"];
    }
    if ([dict.allKeys containsObject:@"mediaNameString"]) {
        mediaData.mediaURLString = dict[@"mediaNameString"];
    }
    if ([dict.allKeys containsObject:@"mediaID"]) {
        mediaData.mediaID = dict[@"mediaID"];
    }
    
}
-(void)updateNoteContent:(NoteContent*)noteContent WithDict:(NSDictionary*)dict
{
    if ([dict.allKeys containsObject:@"content"]){
        noteContent.content = [dict objectForKey:@"content"];
    }
    if ([dict.allKeys containsObject:@"contentType"]) {
        noteContent.contentType = [dict objectForKey:@"contentType"];
        noteContent.contentIndex = [[self contentIndexDict] objectForKey:@"contentType"];
    }
    if ([dict.allKeys containsObject:@"updatedContent"]){
        noteContent.updatedContent = [dict objectForKey:@"updatedContent"];
    }else {
        noteContent.updatedContent = noteContent.content;
    }
}
-(NSDictionary*)contentIndexDict
{
    return @{@"S":@(0),@"O":@(1),@"A":@(2),@"P":@(3)};
}
- (NSString *)noteUUIDForNoteIdentifier
{
    NSString *  result;
    CFUUIDRef   uuid;
    CFStringRef uuidStr;
    
    uuid = CFUUIDCreate(NULL);
    assert(uuid != NULL);
    
    uuidStr = CFUUIDCreateString(NULL, uuid);
    assert(uuidStr != NULL);
    
    result = [NSString stringWithFormat:@"%@",uuidStr];
    
    assert(result != nil);
    return result;
    
}
-(void)updateNote:(NoteBook*)note withDict:(NSDictionary*)dict
{
    if ([dict.allKeys containsObject:@"noteType"]) { //为某个病人写或随笔
        note.noteType = [dict objectForKey:@"noteType"];
    }
    if ([dict.allKeys containsObject:@"noteTitle"]){
        note.noteTitle = [dict objectForKey:@"noteTitle"];
    }
    if ([dict.allKeys containsObject:@"notePatientName"]) {
        note.notePatientName = [dict objectForKey:@"notePatientName"];
    }
    if ([dict.allKeys containsObject:@"noteID"]){
        note.noteID = [dict objectForKey:@"noteID"];
    }
    if ([dict.allKeys containsObject:@"notePatientID"]) {
        note.notePatientID = [dict objectForKey:@"notePatientID"];
    }
    
    if ([dict.allKeys containsObject:@"dID"]){
        note.dID = [dict objectForKey:@"dID"];
    }
    if ([dict.allKeys containsObject:@"dName"]) {
        note.dName = [dict objectForKey:@"dName"];
    }
    
    if ([dict.allKeys containsObject:@"createDate"]){
        note.createDate = [dict objectForKey:@"createDate"];
    }
    if ([dict.allKeys containsObject:@"updateDate"]) {
        note.updateDate = [dict objectForKey:@"updateDate"];
    }
    
    if ([dict.allKeys containsObject:@"createDate"]){
        note.createDate = [dict objectForKey:@"createDate"];
    }
    if ([dict.allKeys containsObject:@"contents"]) {
        note.contents = [dict objectForKey:@"contents"];
    }
    
    if ([dict.allKeys containsObject:@"noteUUID"]) {
        note.noteUUID = [dict objectForKey:@"noteUUID"];
    }
}
@end
