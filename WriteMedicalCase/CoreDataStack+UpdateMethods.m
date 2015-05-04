//
//  CoreDataStack+UpdateMethods.m
//  WriteMedicalCase
//
//  Created by GK on 15/5/1.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "CoreDataStack+UpdateMethods.h"

@implementation CoreDataStack (UpdateMethods)

-(int)getManagedObjectEntityCountWithName:(NSString*)entityName predicate:(NSPredicate *)predicate
{
    int count = 0;
    
    NSArray *countArray = [self fetchNSManagedObjectEntityWithName:entityName withNSPredicate:predicate setUpFetchRequestResultType:NSCountResultType isSetUpResultType:YES setUpFetchRequestSortDescriptors:nil isSetupSortDescriptors:NO];
    
    count = [[countArray firstObject] intValue];
    
    return count;
}



///create patient NSmanagedObject
-(void)createPatientManagedObjectWithDataDic:(NSMutableDictionary*)dataDic failedToCreated:(void (^)(NSError *error,NSString * errorInfo))failure successfulCreated:(void (^)())successfully
{
    NSString *patientName;
    NSString *patientID;
    
    if ([dataDic.allKeys containsObject:@"pName"]) {
        patientName = (NSString*)dataDic[@"pName"];
    }
    if ([dataDic.allKeys containsObject:@"pID"]) {
        patientID = (NSString*)dataDic[@"pID"];
    }

    if (patientID == nil || patientName == nil) {
        abort();
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pName=%@ and pID=%@",patientName,patientID];
   int count =  [self getManagedObjectEntityCountWithName:[Patient entityName] predicate:predicate];
    
    if (count == 0) {
        NSEntityDescription *entityDesc = [NSEntityDescription entityForName: [Patient entityName]inManagedObjectContext:self.managedObjectContext];
        Patient *patient = [[Patient alloc] initWithEntity:entityDesc insertIntoManagedObjectContext:self.managedObjectContext];
        
        [self updatePatient:patient WithDictionary:dataDic];
        
        [self saveContextFailToSave:^(NSError *error, NSString *errorInfo) {
            failure(error,errorInfo);
        } successfulCreated:^{
            successfully();
        }];
    }
}
///update patient info
-(void)updatePatientInContext:(NSManagedObjectContext*)context ManagedObjectWithDataDic:(NSMutableDictionary*)dataDic successfulUpdated:(void (^)())successfully failedToUpdated:(void (^)(NSError *error,NSString * errorInfo))failure
{
    NSPredicate *predicate;
    
    NSString *pID,*pName;
    
    if([dataDic.allKeys containsObject:@"pID"]){
        pID = dataDic[@"pID"];
    }
    if([dataDic.allKeys containsObject:@"pName"]){
        pName = dataDic[@"pName"];
    }
    if (pID != nil && pName!=nil) {
        predicate = [NSPredicate predicateWithFormat:@"pName = %@,pID = %@",pName,pID];
    }else {
        abort();
    }
    if(pName == nil){
        predicate = [NSPredicate predicateWithFormat:@"pID = %@",pID];
    }
    if (pID == nil) {
        predicate = [NSPredicate predicateWithFormat:@"pName = %@",pName];
    }
    
    [self fetchManagedObjectInContext:context WithEntityName:[Patient entityName] withPredicate:predicate successfulFetched:^(NSArray *resultArray) {
        
        if (resultArray.count == 1) {
            if ([[resultArray firstObject] isMemberOfClass:[Patient class]]) {
                Patient *patient = (Patient*)[resultArray firstObject];
                
                [self updatePatient:patient WithDictionary:dataDic];
                
                [self saveContextFailToSave:^(NSError *error, NSString *errorInfo) {
                    failure(error,errorInfo);
                } successfulCreated:^{
                    successfully();
                }];
            }
        }else {
            NSLog(@"存在多个医生对应相同的名字或ID 或着不存在该医生");
        }
        
    } failedToFetched:^(NSError *error, NSString *errorInfo) {
        failure(error,errorInfo);
    }];
    
    
}




///create template nsmanagedObject required : content, dId,dName
-(void)createTemplateManagedObjectWithDataDic:(NSMutableDictionary*)dic  successfulCreated:(void (^)())successfully failedToCreated:(void (^)(NSError *error,NSString * errorInfo))failure
{
    NSString *doctorID;
    NSString *doctorName;
    NSString *templateID;
    NSString *section;
    if ([dic.allKeys containsObject:@"dID"]) {
        doctorID = (NSString*)dic[@"dID"];
    }
    if ([dic.allKeys containsObject:@"dName"]) {
        doctorName = (NSString*)dic[@"dName"];
    }
    if ([dic.allKeys containsObject:@[@"templateID"]]) {
        templateID = (NSString*)dic[@"templateID"];
    }
    if ([dic.allKeys containsObject:@"section"]) {
        section = dic[@"section"];
    }

    if (doctorName == nil || doctorID == nil) {
        abort();
    }
   // NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dName=%@ and dID=%@ and templateID=%@ ",doctorName,doctorID,templateID];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dName=%@ and dID=%@ and section = %@",doctorName,doctorID,section];
    int count =  [self getManagedObjectEntityCountWithName:[Template entityName] predicate:predicate];
    
    if (count==0) {
        NSEntityDescription *templateDesc = [NSEntityDescription entityForName: [Template entityName]inManagedObjectContext:self.managedObjectContext];
        Template *template = [[Template alloc] initWithEntity:templateDesc insertIntoManagedObjectContext:self.managedObjectContext];
        
        if ([dic.allKeys containsObject:@"condition"]) {
            template.condition = dic[@"condition"];
        }
        if ([dic.allKeys containsObject:@"content"] && !([dic[@"content"] isEqualToString:@""])) {
            template.content = dic[@"content"];
            NSLog(@"%@",template.content);
        }else {
            [self showAlertViewWithTitle:@"创建模板必须有内容"];
            failure(nil,@"创建模板必须有内容");
            abort();
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
        if ([dic.allKeys containsObject:@"sourceType"]) {
            template.sourceType = dic[@"sourceType"];
        }
        if ([dic.allKeys containsObject:@"createPeople"]) {
            template.createPeople = dic[@"createPeople"];
        }

        if ([dic.allKeys containsObject:@"nodeID"]) {
            template.nodeID = dic[@"nodeID"];
        }
        if ([dic.allKeys containsObject:@"updatedTime"]) {
            template.updatedTime = dic[@"updatedTime"];
        }
        if ([dic.allKeys containsObject:@"dName"] && ![dic[@"dName"] isEqualToString:@""]) {
            template.dName = dic[@"dName"];
            NSLog(@"template dName:%@",template.dName);
        }else{
            [self showAlertViewWithTitle:@"创建模板必须包含医生姓名"];
            failure(nil,@"创建模板必须包含医生姓名");
            
            //abort();
        }
        if ([dic.allKeys containsObject:@[@"templateID"]]) {
            template.templateID = (NSString*)dic[@"templateID"];
        }

        if ([dic.allKeys containsObject:@"dID"] && (![dic[@"dID"] isEqualToString:@""])) {
            template.dID = dic[@"dID"];
        }else {
            [self showAlertViewWithTitle:@"创建模板必须包含医生ID"];
            failure(nil,@"创建模板必须包含医生ID");
            
            // abort();
        }
        if ([dic.allKeys containsObject:@"section"] && (![dic[@"section"] isEqualToString:@""])) {
            template.section = dic[@"section"];
        }else {
            [self showAlertViewWithTitle:@"创建模板必须包含模板类别"];
            failure(nil,@"创建模板必须包含模板类别");
            
            // abort();
        }

       // [self saveContext];
        [self saveContextFailToSave:^(NSError *error, NSString *errorInfo) {
            failure(error,errorInfo);
            
            
        } successfulCreated:^{
            successfully();
            
        }];
 
    }    
}
-(void)updateTemplateInContext:(NSManagedObjectContext*)context ManagedObjectWithDataDic:(NSMutableDictionary*)dic  successfulCreated:(void (^)())successfully failedToCreated:(void (^)(NSError *error,NSString * errorInfo))failure
{
    NSString *doctorID;
    NSString *doctorName;
    NSString *templateID;
    
    if ([dic.allKeys containsObject:@"dID"]) {
        doctorID = (NSString*)dic[@"dID"];
    }
    if ([dic.allKeys containsObject:@"dName"]) {
        doctorName = (NSString*)dic[@"dName"];
    }
    if ([dic.allKeys containsObject:@"templateID"]) {
        templateID = dic[@"templateID"];
    }
    
    if (doctorID==nil || doctorName == nil || templateID == nil) {
        abort();
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dName=%@ and dID=%@ and templateID=%@ ",doctorName,doctorID,templateID];
    
    [self fetchManagedObjectInContext:context WithEntityName:[Template entityName] withPredicate:predicate successfulFetched:^(NSArray *resultArray) {
        
        if (resultArray.count == 1) {
            if ([[resultArray firstObject] isMemberOfClass:[Template class]]) {
                Template *template = (Template*)[resultArray firstObject];
                if ([dic.allKeys containsObject:@"sourceType"]) {
                    template.sourceType = dic[@"sourceType"];
                }
                if ([dic.allKeys containsObject:@"createPeople"]) {
                    template.createPeople = dic[@"createPeople"];
                }
                if ([dic.allKeys containsObject:@"content"]) {
                    template.content = dic[@"content"];
                }
                if ([dic.allKeys containsObject:@"updatedTime"]) {
                    template.nodeID = dic[@"updatedTime"];
                }

                [self saveContextFailToSave:^(NSError *error, NSString *errorInfo) {
                         failure(error,errorInfo);
                    
                    } successfulCreated:^{
                        successfully();
                }];

            }
        }
    } failedToFetched:^(NSError *error, NSString *errorInfo) {
        failure(error,errorInfo);
    }];
}
///create medical case managedObject
-(void)createMedicalCaseManagedObjectWithDataDic:(NSMutableDictionary*)dataDic failedToCreated:(void (^)(NSError *error,NSString * errorInfo))failure successfulCreated:(void (^)())successfully
{
    NSString *patientName;
    NSString *patientID;
    NSString *doctorName;
    NSString *doctorID;
    
    NSPredicate *predicate;
    if ([dataDic.allKeys containsObject:@"pName"]) {
        patientName = (NSString*)dataDic[@"pName"];
    }
    if ([dataDic.allKeys containsObject:@"pID"]) {
        patientID = (NSString*)dataDic[@"pID"];
    }
    if ([dataDic.allKeys containsObject:@"dName"]) {
        doctorName = (NSString*)dataDic[@"dName"];
    }
    if ([dataDic.allKeys containsObject:@"dID"]) {
        doctorID = (NSString*)dataDic[@"dID"];
    }

    BOOL isAllFlag = NO;
    if (patientID == nil || patientName == nil || doctorID==nil || doctorName == nil) {
        isAllFlag = YES;
    }else {
        predicate =[NSPredicate predicateWithFormat:@"dID=%@ and pID=%@ and dName = %@ and pName = %@",doctorID,patientID,doctorName,patientName];
    }
    if (isAllFlag) {
        if (patientID == nil || doctorID == nil) {
            abort();
        }else {
            predicate =[NSPredicate predicateWithFormat:@"dID=%@ and pID=%@",doctorID,patientID];
        }
    }
    int count = [self getManagedObjectEntityCountWithName:[RecordBaseInfo   entityName] predicate:predicate];
    if (count == 0) {
        NSEntityDescription *entityDesc = [NSEntityDescription entityForName: [RecordBaseInfo entityName]inManagedObjectContext:self.managedObjectContext];
        RecordBaseInfo *recordBaseInfo = [[RecordBaseInfo alloc] initWithEntity:entityDesc insertIntoManagedObjectContext:self.managedObjectContext];
        
        if ([dataDic.allKeys containsObject:@"caseType"]) {
            recordBaseInfo.caseType = [dataDic objectForKey:@"caseType"];
        }
        if ([dataDic.allKeys containsObject:@"caseState"]) {
            recordBaseInfo.caseState = [dataDic objectForKey:@"caseState"];
        }
        
        if ([dataDic.allKeys containsObject:@"caseContent"]) {
            recordBaseInfo.caseContent = [dataDic objectForKey:@"caseContent"];
        }
        if ([dataDic.allKeys containsObject:@"archivedTime"]) {
            recordBaseInfo.archivedTime = [dataDic objectForKey:@"archivedTime"];
        }
        
        if ([dataDic.allKeys containsObject:@"casePresenter"]) {
            recordBaseInfo.casePresenter = [dataDic objectForKey:@"casePresenter"];
        }
        if ([dataDic.allKeys containsObject:@"createdTime"]) {
            recordBaseInfo.createdTime = [dataDic objectForKey:@"createdTime"];
        }
        
        if ([dataDic.allKeys containsObject:@"isCompleted"]) {
            recordBaseInfo.isCompleted = [dataDic objectForKey:@"isCompleted"];
        }
        if ([dataDic.allKeys containsObject:@"lastModifyTime"]) {
            recordBaseInfo.lastModifyTime = [dataDic objectForKey:@"lastModifyTime"];
        }
        
        if ([dataDic.allKeys containsObject:@"dID"]) {
            recordBaseInfo.dID = [dataDic objectForKey:@"dID"];
        }else{
            [self showAlertViewWithTitle:@"创建病例必须要有医生ID"];
            failure(nil,@"创建病例必须要有医生ID");
        }
        
        if ([dataDic.allKeys containsObject:@"dName"]) {
            recordBaseInfo.dName = [dataDic objectForKey:@"dName"];
        }else{
            [self showAlertViewWithTitle:@"创建病例必须要有医生姓名"];
            failure(nil,@"创建病例必须要有医生姓名");
        }
        
        if ([dataDic.allKeys containsObject:@"pID"]) {
            recordBaseInfo.pID = [dataDic objectForKey:@"pID"];
        }else {
            [self showAlertViewWithTitle:@"创建病例必须要有病人ID"];
            failure(nil,@"创建病例必须要有病人ID");
        }
        if ([dataDic.allKeys containsObject:@"pName"]) {
            recordBaseInfo.pName = [dataDic objectForKey:@"pName"];
        }else {
            [self showAlertViewWithTitle:@"创建病例必须要有病姓名"];
            failure(nil,@"创建病例必须要有病人姓名");
            
        }
        [self saveContextFailToSave:^(NSError *error, NSString *errorInfo) {
            failure(error,errorInfo);
        } successfulCreated:^{
            successfully();
        }];

    }else {
        [self updateMedicalCaseInContext:self.managedObjectContext ManagedObjectWithDataDic:dataDic failedToUpdated:^(NSError *error, NSString *errorInfo) {
            
        } successfulUpdated:^{
            
        }];
    }
}
-(void)updateMedicalCaseInContext:(NSManagedObjectContext*)context ManagedObjectWithDataDic:(NSMutableDictionary*)dataDic failedToUpdated:(void (^)(NSError *error,NSString * errorInfo))failure successfulUpdated:(void (^)())successfully
{
    NSPredicate *predicate;
    
    NSString *pID,*pName,*dID,*dName;
    if ([dataDic.allKeys containsObject:@"pID"]) {
        pID = dataDic[@"pID"];
    }
    if ([dataDic.allKeys containsObject:@"pName"]) {
        pName = dataDic[@"pName"];
    }
    
    if ([dataDic.allKeys containsObject:@"dID"]) {
        dID = dataDic[@"dID"];
    }
    if ([dataDic.allKeys containsObject:@"dName"]) {
        dName = dataDic[@"dName"];
    }
    if (dID == nil && dName == nil) {
        abort();
    }
    if (pID == nil && pName == nil) {
        abort();
    }
    
    if (dID != nil && dName != nil && pID != nil && pName != nil) {
        predicate = [NSPredicate predicateWithFormat:@"dName = %@ and dID = %@ and pName = %@ and pID = %@",dName,dID,pName,pID];
    }else {
        if (dID != nil && pID != nil) {
            predicate = [NSPredicate predicateWithFormat:@"dID = %@ and pID = %@",dID,pID];
        }
 
    }
    

    [self fetchManagedObjectInContext:context WithEntityName:[RecordBaseInfo entityName] withPredicate:predicate successfulFetched:^(NSArray *resultArray) {
        
        if (resultArray.count == 1) {
            
                RecordBaseInfo *recordBaseInfo = (RecordBaseInfo*)[resultArray firstObject];
                [self updateCaseInfo:recordBaseInfo withDic:dataDic];
                
                [self saveContextFailToSave:^(NSError *error, NSString *errorInfo) {
                    failure(error,errorInfo);
                } successfulCreated:^{
                    successfully();
                }];
            
        }else {
            abort();
        }
        
    } failedToFetched:^(NSError *error, NSString *errorInfo) {
        failure(error,errorInfo);
    }];
}
-(void)updateCaseInfo:(RecordBaseInfo*)recordBaseInfo withDic:(NSDictionary*)dataDic
{
    if ([dataDic.allKeys containsObject:@"caseState"]) {
        recordBaseInfo.caseState = [dataDic objectForKey:@"caseState"];
    }
    
    
    if ([dataDic.allKeys containsObject:@"caseContent"]) {
        recordBaseInfo.caseType = [dataDic objectForKey:@"caseContent"];
    }
    if ([dataDic.allKeys containsObject:@"archivedTime"]) {
        recordBaseInfo.caseState = [dataDic objectForKey:@"archivedTime"];
    }
    
    if ([dataDic.allKeys containsObject:@"casePresenter"]) {
        recordBaseInfo.caseType = [dataDic objectForKey:@"casePresenter"];
    }
    if ([dataDic.allKeys containsObject:@"createdTime"]) {
        recordBaseInfo.caseState = [dataDic objectForKey:@"createdTime"];
    }
    
    if ([dataDic.allKeys containsObject:@"isCompleted"]) {
        recordBaseInfo.caseType = [dataDic objectForKey:@"isCompleted"];
    }
    if ([dataDic.allKeys containsObject:@"lastModifyTime"]) {
        recordBaseInfo.caseState = [dataDic objectForKey:@"lastModifyTime"];
    }
    
    if ([dataDic.allKeys containsObject:@"dID"]) {
        recordBaseInfo.caseType = [dataDic objectForKey:@"dID"];
    }
    if ([dataDic.allKeys containsObject:@"dName"]) {
        recordBaseInfo.caseState = [dataDic objectForKey:@"dName"];
    }
    if ([dataDic.allKeys containsObject:@"pID"]) {
        recordBaseInfo.caseType = [dataDic objectForKey:@"pID"];
    }    if ([dataDic.allKeys containsObject:@"pName"]) {
        recordBaseInfo.caseState = [dataDic objectForKey:@"pName"];
    }
}
///create doctor managedobject

-(void)createDoctorEntityWithDataDic:(NSDictionary*)dataDic inContext:(NSManagedObjectContext*)context successfulCreated:(void (^)())successfully failedToCreated:(void (^)(NSError *error,NSString * errorInfo))failure
{
    NSString *doctorName;
    NSString *doctorID;
    
    NSPredicate *predicate;
    if ([dataDic.allKeys containsObject:@"dName"]) {
        doctorName = (NSString*)dataDic[@"dName"];
    }
    if ([dataDic.allKeys containsObject:@"dID"]) {
        doctorID = (NSString*)dataDic[@"dID"];
    }
    
    BOOL isAllFlag = NO;
    if (doctorID==nil || doctorName==nil) {
        isAllFlag = YES;
    }else {
        predicate =[NSPredicate predicateWithFormat:@"dID=%@ and dName=%@",doctorID,doctorName];
    }
    if (isAllFlag) {
        if (doctorID == nil) {
            abort();
        }else {
            predicate =[NSPredicate predicateWithFormat:@"dID=%@",doctorID];
        }
    }
    int count = [self getManagedObjectEntityCountWithName:[Doctor   entityName] predicate:predicate];
    if (count == 0) {
        NSEntityDescription *entityDesc = [NSEntityDescription entityForName: [Doctor entityName]inManagedObjectContext:context];
        Doctor *doctor = [[Doctor alloc] initWithEntity:entityDesc insertIntoManagedObjectContext:context];
        if ([dataDic.allKeys containsObject:@"dID" ]) {
            doctor.dID = (NSString*)dataDic[@"dID"];
        }else {
            [self showAlertViewWithTitle:@"需要医生ID"];
            failure(nil,@"需要医生ID");
        }
        if ([dataDic.allKeys containsObject:@"dName"]) {
            doctor.dName = (NSString*)dataDic[@"dName"];
        }else {
            [self showAlertViewWithTitle:@"需要医生姓名"];
            failure(nil,@"需要医生姓名");
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
        
        if ([dataDic.allKeys containsObject:@"isAttendingPhysican"]) {
            doctor.dept = (NSString*)dataDic[@"isAttendingPhysican"];
        }
        if ([dataDic.allKeys containsObject:@"isChiefPhysician"]) {
            doctor.medicalTeam = (NSString*)dataDic[@"isChiefPhysician"];
        }
        if ([dataDic.allKeys containsObject:@"isResident"]) {
            doctor.medicalTeam = (NSString*)dataDic[@"isResident"];
        }
        
        [self saveContextFailToSave:^(NSError *error, NSString *errorInfo) {
            failure(error,errorInfo);
        } successfulCreated:^{
            successfully();
        }];
  
    }
}
///update doctor info
-(void)updateDoctorEntityWithDataDic:(NSDictionary*)dataDic inContext:(NSManagedObjectContext*)context successfulUpdated:(void (^)())successfully failedToUpdated:(void (^)(NSError *error,NSString * errorInfo))failure
{
    NSPredicate *predicate;
    
    NSString *dID,*dName;
    
    if([dataDic.allKeys containsObject:@"dID"]){
        dID = dataDic[@"dID"];
    }
    if([dataDic.allKeys containsObject:@"dName"]){
        dName = dataDic[@"dName"];
    }
    
    if (dID != nil && dName!=nil) {
        predicate = [NSPredicate predicateWithFormat:@"dName = %@,dID = %@",dName,dID];
    }
    if(dName == nil){
        predicate = [NSPredicate predicateWithFormat:@"dID = %@",dID];
    }
    if (dID == nil) {
        predicate = [NSPredicate predicateWithFormat:@"dName = %@",dName];
    }
    
    [self fetchManagedObjectInContext:context WithEntityName:[Doctor entityName] withPredicate:predicate successfulFetched:^(NSArray *resultArray) {
        
        NSLog(@"fetch %@,  with predicate : %@,result array count is %@",[Doctor entityName],predicate,@(resultArray.count));
        
        if (resultArray.count == 1) {
            if ([[resultArray firstObject] isKindOfClass:[Doctor class]]){
                Doctor *doctor = (Doctor*)[resultArray firstObject];
                if ([dataDic.allKeys containsObject:@"dProfessionalTitle"]) {
                    doctor.dProfessionalTitle = (NSString*)dataDic[@"dProfessionalTitle"];
                }
                if ([dataDic.allKeys containsObject:@"dept"]) {
                    doctor.dept = (NSString*)dataDic[@"dept"];
                }
                if ([dataDic.allKeys containsObject:@"medicalTeam"]) {
                    doctor.medicalTeam = (NSString*)dataDic[@"medicalTeam"];
                }
                if ([dataDic.allKeys containsObject:@"isAttendingPhysican"]) {
                    doctor.dept = (NSString*)dataDic[@"isAttendingPhysican"];
                }
                if ([dataDic.allKeys containsObject:@"isChiefPhysician"]) {
                    doctor.medicalTeam = (NSString*)dataDic[@"isChiefPhysician"];
                }
                if ([dataDic.allKeys containsObject:@"isResident"]) {
                    doctor.medicalTeam = (NSString*)dataDic[@"isResident"];
                }
                
            }
            [self saveContextFailToSave:^(NSError *error, NSString *errorInfo) {
                failure(error,errorInfo);
            } successfulCreated:^{
                successfully();
            }];
        }else {
            NSLog(@"存在多个医生对应相同的名字或ID");
        }
        
    } failedToFetched:^(NSError *error, NSString *errorInfo) {
        failure(error,errorInfo);
    }];
}



- (void)saveContextFailToSave:(void (^)(NSError *error,NSString * errorInfo))failure  successfulCreated:(void (^)())successfully{
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            failure(error,@"save to core data error");
            abort();
        }else {
            successfully();
        }

    }}

///helper
-(void)fetchManagedObjectInContext:(NSManagedObjectContext*)context  WithEntityName:(NSString*)entityString withPredicate:(NSPredicate*)predicate successfulFetched:(void (^)(NSArray *resultArray))successfully failedToFetched:(void (^)(NSError *error,NSString * errorInfo))failure
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:entityString];
    if (predicate != nil) {
        fetchRequest.predicate = predicate;
    }
    NSError *error;
    
    NSArray *tempArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error) {
        failure(error,[NSString stringWithFormat:@"fetch entity %@ fail",entityString]);
    }else {
        successfully(tempArray);
    }
}


-(void)showAlertViewWithTitle:(NSString*)titleString
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:titleString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        NSLog(@"%@",titleString);
        [alert show];
        
    });
    
}

@end
