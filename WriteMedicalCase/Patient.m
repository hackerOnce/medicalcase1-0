//
//  Patient.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/18.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "Patient.h"
#import "Doctor.h"


@implementation Patient

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
@dynamic pAge;
@dynamic dID;
@dynamic dName;
@dynamic doctor;

+(NSString*)entityName
{
    return @"Patient";
}

@end
