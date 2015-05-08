//
//  CoreDataStack+UpdateMethods.h
//  WriteMedicalCase
//
//  Created by GK on 15/5/1.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "CoreDataStack.h"

@interface CoreDataStack (UpdateMethods)

-(int)getManagedObjectEntityCountWithName:(NSString*)entityName predicate:(NSPredicate *)predicate;


-(void)fetchPatientWithDic:(NSDictionary*)dataDic successfulFetched:(void (^)(NSArray *resultArray))successfully failedToFetched:(void (^)(NSError *error,NSString * errorInfo))failure;
///create patient NSmanagedObject
-(void)createPatientManagedObjectWithDataDic:(NSMutableDictionary*)dataDic failedToCreated:(void (^)(NSError *error,NSString * errorInfo))failure successfulCreated:(void (^)())successfully;
///update patient info
-(void)updatePatientInContext:(NSManagedObjectContext*)context ManagedObjectWithDataDic:(NSMutableDictionary*)dataDic successfulUpdated:(void (^)())successfully failedToUpdated:(void (^)(NSError *error,NSString * errorInfo))failure;


///update template
-(void)updateTemplateInContext:(NSManagedObjectContext*)context ManagedObjectWithDataDic:(NSMutableDictionary*)dic  successfulCreated:(void (^)())successfully failedToCreated:(void (^)(NSError *error,NSString * errorInfo))failure;
///create template nsmanagedObject required : content, dId,dName
-(void)createTemplateManagedObjectWithDataDic:(NSMutableDictionary*)dic  successfulCreated:(void (^)())successfully failedToCreated:(void (^)(NSError *error,NSString * errorInfo))failure;



///for sync
-(void)saveContext:(NSManagedObjectContext*)context failedToSync:(void (^)(NSError *error,NSString * errorInfo))failure successfulSync:(void (^)())successfully;
-(void)syncServerMedicalCaseWithDataDic:(NSDictionary*)dataDic inContext:(NSManagedObjectContext*)context failedToSync:(void (^)(NSError *error,NSString * errorInfo))failure successfulSync:(void (^)())successfully;
///create medical case managedObject
-(void)createMedicalCaseManagedObjectWithDataDic:(NSMutableDictionary*)dataDic  inContext:(NSManagedObjectContext*)context isSaveToCoreData:(BOOL)isSaveToCoreData failedToCreated:(void (^)(NSError *error,NSString * errorInfo))failure successfulCreated:(void (^)())successfully;
///update medical case
-(void)createMedicalCaseManagedObjectWithDataDic:(NSMutableDictionary*)dataDic  inContext:(NSManagedObjectContext*)context isSaveToCoreData:(BOOL)isSaveToCoreData failedToCreated:(void (^)(NSError *error,NSString * errorInfo))failure successfulCreated:(void (^)())successfully;

/// fetch record base info
-(void)fetchCaseInfoWithDic:(NSDictionary*)dataDic successfulFetched:(void (^)(NSArray *resultArray))successfully failedToFetched:(void (^)(NSError *error,NSString * errorInfo))failure;

////save
- (void)saveContextFailToSave:(void (^)(NSError *error,NSString * errorInfo))failure  successfulCreated:(void (^)())successfully;

///create doctor managedobject

-(void)createDoctorEntityWithDataDic:(NSDictionary*)dataDic inContext:(NSManagedObjectContext*)context successfulCreated:(void (^)())successfully failedToCreated:(void (^)(NSError *error,NSString * errorInfo))failure;

///update doctor info
-(void)updateDoctorEntityWithDataDic:(NSDictionary*)dataDic inContext:(NSManagedObjectContext*)context successfulUpdated:(void (^)())successfully failedToUpdated:(void (^)(NSError *error,NSString * errorInfo))failure;
///fetch doctor
-(void)fetchDoctorWithDic:(NSDictionary*)dataDic successfulFetched:(void (^)(NSArray *resultArray))successfully failedToFetched:(void (^)(NSError *error,NSString * errorInfo))failure;


/// fetch a managedobject
-(void)fetchManagedObjectInContext:(NSManagedObjectContext*)context  WithEntityName:(NSString*)entityString withPredicate:(NSPredicate*)predicate successfulFetched:(void (^)(NSArray *resultArray))successfully failedToFetched:(void (^)(NSError *error,NSString * errorInfo))failure;

@end
