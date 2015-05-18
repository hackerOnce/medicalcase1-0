//
//  CaseContent.h
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/18.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RecordBaseInfo;

@interface CaseContent : NSManagedObject

@property (nonatomic,retain) NSString *pID;
@property (nonatomic,retain) NSString *recordCaseType;

@property (nonatomic, retain) NSString * chiefComplaint;
@property (nonatomic, retain) NSString * historyOfPresentillness;
@property (nonatomic, retain) NSString * personHistory;
@property (nonatomic, retain) NSString * pastHistory;
@property (nonatomic, retain) NSString * familyHistory;
@property (nonatomic, retain) NSString * obstericalHistory;
@property (nonatomic, retain) NSString * physicalExamination;
@property (nonatomic, retain) NSString * systemsReview;
@property (nonatomic, retain) NSString * specializedExamination;
@property (nonatomic, retain) NSString * tentativeDiagnosis;
@property (nonatomic, retain) NSString * admittingDiagnosis;
@property (nonatomic, retain) NSString * confirmedDiagnosis;
@property (nonatomic, retain) RecordBaseInfo *recordBaseInfo;
+(NSString*)entityName;

@end
