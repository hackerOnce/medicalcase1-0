//
//  CurrentPatient.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/7.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "CurrentPatient.h"

@implementation CurrentPatient

-(instancetype)init
{
    if (self = [super init]) {
        self.pID = self.tempPatient.pID;
        self.pName = self.tempPatient.pName;
        self.pGender = self.tempPatient.pGender;
        self.pAge = self.tempPatient.pAge;
        self.pCity = self.tempPatient.pCity;
        self.pProvince = self.tempPatient.pProvince;
        self.pDetailAddress = self.tempPatient.pDetailAddress;
        self.pDept = self.tempPatient.pDept;
        self.pBedNum = self.tempPatient.pBedNum;
        self.pNation = self.tempPatient.pNation;
        self.pProfession = self.tempPatient.pProfession;
        self.pMaritalStatus = self.tempPatient.pMaritalStatus;
        self.pMobileNum = self.tempPatient.pMobileNum;
        self.pLinkman = self.tempPatient.pLinkman;
        self.pLinkmanMobileNum = self.tempPatient.pLinkmanMobileNum;
        self.pCountOfHospitalized = self.tempPatient.pCountOfHospitalized;
        self.presenter = self.tempPatient.presenter;//病史陈述者
        self.pAdmissionTime = self.tempPatient.pAdmissionTime;//入院时间 //年月日
        self.pSubAdmissionTime = self.tempPatient.pSubAdmissionTime; //时分秒
        
        self.patientState = self.tempPatient.patientState;//未出院
    }
    return self;
}
-(TempPatient *)tempPatient
{
    if (!_tempPatient) {
        NSString *pID = @"99999";
        NSString *pName = @"王天找";
        NSString *pGender = @"男";
        NSString *pAge = @"22";
        NSString *pCity = @"上海";
        NSString *pProvince = @"上海";
        NSString *pDetailAddress = @"上海闸北区彭江路";
        NSString *pDept = @"心内科";
        NSString *pBedNum = @"086";
        NSString *pNation = @"东突";
        NSString *pProfession = @"律师";
        NSString *pMaritalStatus = @"未婚";
        NSString *pMobileNum = @"13778126754";
        NSString *pLinkman = @"王天华";
        NSString *pLinkmanMobileNum = @"13787865676";
        NSString *pCountOfHospitalized = @"1";
        NSString *presenter = @"本人";//病史陈述者
        NSString *pAdmissionTime = @"2015-09-09";//入院时间 //年月日
        NSString *pSubAdmissionTime = @"上午 09:00:09"; //时分秒
        NSString *patientState = @"0";//0：未出院 1： 已出院

        _tempPatient = [[TempPatient alloc] initWithPatientID:NSDictionaryOfVariableBindings(pID,pNation,pName,pGender,pAge,pCity,pProvince,pDetailAddress,pDept,pBedNum,pProvince,pMaritalStatus,pMobileNum,pLinkmanMobileNum,pLinkman,pCountOfHospitalized,presenter,pAdmissionTime,pSubAdmissionTime,patientState,pProfession)];
    }
    return _tempPatient;
}


@end
