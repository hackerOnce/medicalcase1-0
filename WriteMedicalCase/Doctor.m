//
//  Doctor.m
//  MedicalCase
//
//  Created by GK on 15/4/25.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import "Doctor.h"
#import "Patient.h"
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
+(NSString*)entityName{
    return @"Doctor";
}

@end
