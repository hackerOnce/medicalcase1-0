//
//  Doctor.h
//  MedicalCase
//
//  Created by GK on 15/4/25.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Patient, RecordBaseInfo;

@interface Doctor : NSManagedObject

@property (nonatomic, retain) NSString * dept;
@property (nonatomic, retain) NSString * dID;
@property (nonatomic, retain) NSString * dName;
@property (nonatomic, retain) NSString * dProfessionalTitle;
@property (nonatomic, retain) NSNumber * isAttendingPhysican;
@property (nonatomic, retain) NSNumber * isChiefPhysician;
@property (nonatomic, retain) NSNumber * isResident;
@property (nonatomic, retain) NSString * medicalTeam;
@property (nonatomic, retain) NSOrderedSet *medicalCases;
@property (nonatomic, retain) NSOrderedSet *patients;
@end

@interface Doctor (CoreDataGeneratedAccessors)
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
- (void)insertObject:(Patient *)value inPatientsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromPatientsAtIndex:(NSUInteger)idx;
- (void)insertPatients:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removePatientsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInPatientsAtIndex:(NSUInteger)idx withObject:(Patient *)value;
- (void)replacePatientsAtIndexes:(NSIndexSet *)indexes withPatients:(NSArray *)values;
- (void)addPatientsObject:(Patient *)value;
- (void)removePatientsObject:(Patient *)value;
- (void)addPatients:(NSOrderedSet *)values;
- (void)removePatients:(NSOrderedSet *)values;
@end
