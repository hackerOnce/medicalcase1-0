//
//  Patient.h
//  MedicalCase
//
//  Created by GK on 15/4/25.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Doctor, RecordBaseInfo;

@interface Patient : NSManagedObject

@property (nonatomic, retain) NSString * pAge;
@property (nonatomic, retain) NSString * patientState;
@property (nonatomic, retain) NSString * pBedNum;
@property (nonatomic, retain) NSString * pCity;
@property (nonatomic, retain) NSString * pCountOfHospitalized;
@property (nonatomic, retain) NSString * pDept;
@property (nonatomic, retain) NSString * pDetailAddress;
@property (nonatomic, retain) NSString * pGender;
@property (nonatomic, retain) NSString * pID;
@property (nonatomic, retain) NSString * pLinkman;
@property (nonatomic, retain) NSString * pLinkmanMobileNum;
@property (nonatomic, retain) NSString * pMaritalStatus;
@property (nonatomic, retain) NSString * pMobileNum;
@property (nonatomic, retain) NSString * pName;
@property (nonatomic, retain) NSString * pNation;
@property (nonatomic, retain) NSString * pProfession;
@property (nonatomic, retain) NSString * pProvince;
@property (nonatomic, retain) NSString * residentDoctorname;
@property (nonatomic, retain) NSString * attendingPhysicianDoctorName;
@property (nonatomic, retain) NSString * chiefPhysicianDoctorName;
@property (nonatomic, retain) NSString * chiefPhysicianDoctorID;
@property (nonatomic, retain) NSString * attendingPhysicianDoctorID;
@property (nonatomic, retain) NSString * residentDoctorID;
@property (nonatomic, retain) Doctor *doctor;
@property (nonatomic, retain) NSOrderedSet *medicalCases;
@end

@interface Patient (CoreDataGeneratedAccessors)
+(NSString*)entityName;

- (void)insertObject:(RecordBaseInfo *)value inMedicalCasesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromMedicalCasesAtIndex:(NSUInteger)idx;
- (void)insertMedicalCases:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeMedicalCasesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInMedicalCasesAtIndex:(NSUInteger)idx withObject:(RecordBaseInfo *)value;
- (void)replaceMedicalCasesAtIndexes:(NSIndexSet *)indexes withMedicalCases:(NSArray *)values;
- (void)addMedicalCasesObject:(RecordBaseInfo *)value;
- (void)removeMedicalCasesObject:(RecordBaseInfo *)value;
- (void)addMedicalCases:(NSOrderedSet *)values;
- (void)removeMedicalCases:(NSOrderedSet *)values;
@end
