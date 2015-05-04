//
//  RecordBaseInfo.m
//  MedicalCase
//
//  Created by GK on 15/4/25.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import "RecordBaseInfo.h"
#import "Doctor.h"
#import "Patient.h"


@implementation RecordBaseInfo
@dynamic dID;
@dynamic dName;
@dynamic pID;
@dynamic pName;
@dynamic isCompleted;

@dynamic archivedTime;
@dynamic caseContent;
@dynamic casePresenter;
@dynamic caseState;
@dynamic caseType;
@dynamic createdTime;
@dynamic lastModifyTime;
@dynamic doctors;
@dynamic patient;
+(NSString*)entityName{
    return @"RecordBaseInfo";
}

@end
