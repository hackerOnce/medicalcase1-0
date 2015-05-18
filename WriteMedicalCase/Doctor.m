//
//  Doctor.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/18.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "Doctor.h"
#import "RecordBaseInfo.h"


@implementation Doctor

@dynamic dept;
@dynamic dID;
@dynamic dName;
@dynamic dProfessionalTitle;
@dynamic isAttendingPhysican;
@dynamic isChiefPhysician;
@dynamic isResident;
@dynamic medicalTeam;
@dynamic medicalCases;
@dynamic patients;
+(NSString*)entityName
{
    return @"Doctor";
}
@end
