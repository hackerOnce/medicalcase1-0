//
//  RecordBaseInfo.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/18.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "RecordBaseInfo.h"
#import "CaseContent.h"


@implementation RecordBaseInfo

@dynamic dID;
@dynamic dName;
@dynamic pID;
@dynamic pName;
@dynamic casePresenter;
@dynamic caseEditStatus;
@dynamic caseStatus;
@dynamic caseType;
@dynamic residentdID;
@dynamic attendingPhysiciandID;
@dynamic createdDate;
@dynamic updatedDate;
@dynamic dof;
@dynamic residentdName;
@dynamic attendingPhysiciandName;
@dynamic chiefPhysiciandID;
@dynamic chiefPhysiciandName;
@dynamic doctors;
@dynamic patient;
@dynamic caseContent;
+(NSString*)entityName
{
    return @"RecordBaseInfo";
}

@end
