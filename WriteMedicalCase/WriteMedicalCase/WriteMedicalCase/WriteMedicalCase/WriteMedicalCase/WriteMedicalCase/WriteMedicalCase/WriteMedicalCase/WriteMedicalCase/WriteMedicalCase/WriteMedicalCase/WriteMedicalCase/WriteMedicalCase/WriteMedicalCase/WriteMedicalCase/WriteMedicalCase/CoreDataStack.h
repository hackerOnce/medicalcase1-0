//
//  CoreDataStack.h
//  CoreData
//
//  Created by GK on 15/4/4.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "RecordBaseInfo.h"

@interface CoreDataStack : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic,strong) NSManagedObjectContext *privateContext;

- (void)saveContext;

-(void)updatePatient:(Patient*)patient WithDictionary:(NSDictionary*)dataDic;


-(NSArray*)fetchNSManagedObjectEntityWithName:(NSString*)entityName withNSPredicate:(NSPredicate*)predicate setUpFetchRequestResultType:(NSFetchRequestResultType)fetchResultType isSetUpResultType:(BOOL)isSetUpResultType setUpFetchRequestSortDescriptors:(NSArray*)sortDescriptors isSetupSortDescriptors:(BOOL)isSetupSortDescriptors;

-(void)createManagedObjectTemplateWithDic:(NSDictionary*)dic  ForNodeWithNodeName:(NSString *)nodeName;

///detch template
-(NSArray*)fetchNSmanagedObjectEntityWithName:(NSString*)entityName;

///初始化病例
///patient dic : pName,pID
-(void)createAllRecordCaseWithPatientDic:(NSDictionary*)patientDic;
///创建病例/更新病例
///ceate record base info
///dataDIc: pName pID,caseState,lastModifyTime
///archivedTime;caseContent;casePresenter,createdTime
-(void)updateRecordBaseInfoEntityWithDataDic:(NSDictionary*)dataDic;
///拿到病人的所有病例
///fetch patient all recordBaseInfo
-(NSArray*)fetchRecordBaseInfoWithPatientName:(NSString*)patientName patientID:(NSString*)patientID;
///拿到病人制定病例类型的病例
///fetch a special record case
-(RecordBaseInfo*)fetchRecordBaseInfoWithCaseType:(NSString*)caseType patientName:(NSString*)pName patientID:(NSString*)pID;

///doctor dic:dID,dName,dProfessionalTitle,dept,medicalTeam

////init a doctor and patients array
///patients  is a array,elevment is a dictionary;
-(void)entityInitDoctorManagementWithDoctorDic:(NSDictionary*)doctorDic;

///update patient
-(void)updatePatientWithPatientInfo:(NSDictionary*)patientInfo;
///update doctor
-(void)updateDoctorWithDoctorInfo:(NSDictionary*)doctorInfo;

///create a doctor
///create docotor only for a doctor
//-(Doctor*)createDoctorEntityWithDataDic:(NSDictionary*)dataDic;

///create a patient  并为病人创建所有类型的病例
-(void)createAndSavePatientEntityWithDataDic:(NSDictionary*)dataDic inContext:(NSManagedObjectContext*)context forDoctor:(Doctor*)doctor;

///fetch a doctor
-(NSArray*)fetchDoctorEntityWithName:(NSString*)entityName dID:(NSString*)dID;
///fetch a patient
-(NSArray*)fetchPatientEntityWithName:(NSString*)pName dID:(NSString*)pID;

@end
