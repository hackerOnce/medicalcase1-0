//
//  Patient.m
//  MedicalCase
//
//  Created by GK on 15/4/25.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import "Patient.h"
#import "Doctor.h"
#import "RecordBaseInfo.h"


@implementation Patient

@dynamic pAge;
@dynamic patientState;
@dynamic pBedNum;
@dynamic pCity;
@dynamic pCountOfHospitalized;
@dynamic pDept;
@dynamic pDetailAddress;
@dynamic pGender;
@dynamic pID;
@dynamic pLinkman;
@dynamic pLinkmanMobileNum;
@dynamic pMaritalStatus;
@dynamic pMobileNum;
@dynamic pName;
@dynamic pNation;
@dynamic pProfession;
@dynamic pProvince;
@dynamic residentDoctorname;
@dynamic attendingPhysicianDoctorName;
@dynamic chiefPhysicianDoctorName;
@dynamic chiefPhysicianDoctorID;
@dynamic attendingPhysicianDoctorID;
@dynamic residentDoctorID;
@dynamic doctor;
@dynamic medicalCases;
+(NSString*)entityName{
    return @"Patient";
}

@end
