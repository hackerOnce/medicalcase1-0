//
//  CaseContent.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/18.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "CaseContent.h"
#import "RecordBaseInfo.h"


@implementation CaseContent

@dynamic menstrualHistory;
@dynamic chiefComplaint;
@dynamic historyOfPresentillness;
@dynamic personHistory;
@dynamic pastHistory;
@dynamic familyHistory;
@dynamic obstericalHistory;
@dynamic physicalExamination;
@dynamic systemsReview;
@dynamic specializedExamination;
@dynamic tentativeDiagnosis;
@dynamic admittingDiagnosis;
@dynamic confirmedDiagnosis;
@dynamic recordBaseInfo;
@dynamic recordCaseType;
@dynamic pID;
+(NSString*)entityName
{
    return @"CaseContent";
}

@end
