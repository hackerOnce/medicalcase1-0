//
//  RecordBaseInfo.h
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/18.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CaseContent, Doctor, Patient;

@interface RecordBaseInfo : NSManagedObject

@property (nonatomic, retain) NSString * dID;
@property (nonatomic, retain) NSString * dName;
@property (nonatomic, retain) NSString * pID;
@property (nonatomic, retain) NSString * pName;
@property (nonatomic, retain) NSString * casePresenter;
@property (nonatomic, retain) NSString * caseEditStatus;
@property (nonatomic, retain) NSString * caseStatus;
@property (nonatomic, retain) NSString * caseType;
@property (nonatomic, retain) NSString * residentdID;
@property (nonatomic, retain) NSString * attendingPhysiciandID;
@property (nonatomic, retain) NSString * createdDate;
@property (nonatomic, retain) NSString * updatedDate;
@property (nonatomic, retain) NSString * dof;
@property (nonatomic, retain) NSString * residentdName;
@property (nonatomic, retain) NSString * attendingPhysiciandName;
@property (nonatomic, retain) NSString * chiefPhysiciandID;
@property (nonatomic, retain) NSString * chiefPhysiciandName;
@property (nonatomic, retain) NSOrderedSet *doctors;
@property (nonatomic, retain) Patient *patient;
@property (nonatomic, retain) CaseContent *caseContent;
@end

@interface RecordBaseInfo (CoreDataGeneratedAccessors)
+(NSString*)entityName;

- (void)insertObject:(Doctor *)value inDoctorsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromDoctorsAtIndex:(NSUInteger)idx;
- (void)insertDoctors:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeDoctorsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInDoctorsAtIndex:(NSUInteger)idx withObject:(Doctor *)value;
- (void)replaceDoctorsAtIndexes:(NSIndexSet *)indexes withDoctors:(NSArray *)values;
- (void)addDoctorsObject:(Doctor *)value;
- (void)removeDoctorsObject:(Doctor *)value;
- (void)addDoctors:(NSOrderedSet *)values;
- (void)removeDoctors:(NSOrderedSet *)values;
@end
