//
//  TempPatient.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/4.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "TempPatient.h"

@implementation TempPatient

-(instancetype)initWithPatientID:(NSDictionary*)patientDic
{
    self = [super init];
    
    if (self){
        
        
        if ([patientDic.allKeys containsObject:@"pID"]) {
            self.pID = patientDic[@"pID"];
        }
        if ([patientDic.allKeys containsObject:@"pGender"]) {
            self.pGender = patientDic[@"pGender"];
        }
        if ([patientDic.allKeys containsObject:@"pName"]) {
            self.pName = patientDic[@"pName"];
        }
        
        if ([patientDic.allKeys containsObject:@"patientState"]) {
            self.patientState = patientDic[@"patientState"];
        }        ////
        if ([patientDic.allKeys containsObject:@"pAge"]) {
            self.pAge = patientDic[@"pAge"];
        }
        if ([patientDic.allKeys containsObject:@"pCity"]) {
            self.pCity = patientDic[@"pCity"];
        }
        if ([patientDic.allKeys containsObject:@"pProvince"]) {
            self.pProvince = patientDic[@"pProvince"];
        }
        if ([patientDic.allKeys containsObject:@"pDetailAddress"]) {
            self.pDetailAddress = patientDic[@"pDetailAddress"];
        }
        
        if ([patientDic.allKeys containsObject:@"pDept"]) {
            self.pDept = patientDic[@"pDept"];
        }
        if ([patientDic.allKeys containsObject:@"pDept"]) {
            self.pDept = patientDic[@"pDept"];
        }

        if ([patientDic.allKeys containsObject:@"patientState"]) {
            self.patientState = patientDic[@"patientState"];
        }
        if ([patientDic.allKeys containsObject:@"pNation"]) {
            self.pNation = patientDic[@"pNation"];
        }

        if ([patientDic.allKeys containsObject:@"pProfession"]) {
            self.pProfession = patientDic[@"pProfession"];
        }
        if ([patientDic.allKeys containsObject:@"pMaritalStatus"]) {
            self.pMaritalStatus = patientDic[@"pMaritalStatus"];
        }
        
        if ([patientDic.allKeys containsObject:@"pMobileNum"]) {
            self.pMobileNum = patientDic[@"pMobileNum"];
        }
        if ([patientDic.allKeys containsObject:@"pLinkman"]) {
            self.pLinkman = patientDic[@"pLinkman"];
        }
        
        if ([patientDic.allKeys containsObject:@"pLinkmanMobileNum"]) {
            self.pLinkmanMobileNum = patientDic[@"pLinkmanMobileNum"];
        }
        if ([patientDic.allKeys containsObject:@"presenter"]) {
            self.presenter = patientDic[@"presenter"];
        }
        if ([patientDic.allKeys containsObject:@"pAdmissionTime"]) {
            self.pAdmissionTime = patientDic[@"pAdmissionTime"];
        }
        if ([patientDic.allKeys containsObject:@"pSubAdmissionTime"]) {
            self.pSubAdmissionTime = patientDic[@"pSubAdmissionTime"];
        }
        if ([patientDic.allKeys containsObject:@"pCountOfHospitalized"]) {
            self.pCountOfHospitalized = patientDic[@"pCountOfHospitalized"];
        }
        if ([patientDic.allKeys containsObject:@"pAdmitDate"]) {
            self.pAdmitDate = patientDic[@"pAdmitDate"];
        }
        
    }
    
    
    return self;
}
-(instancetype)initPatientWithPatient:(TempPatient*)patient
{
    if (self = [super init]) {
        _pID = patient.pID;
        _pGender = patient.pGender;
        _pName = patient.pName;
        _patientState = patient.patientState;
        _pAge = patient.pAge;
        _pCity = patient.pCity;
        _pProvince = patient.pProvince;
        _pDetailAddress = patient.pDetailAddress;
        
//        if ([patientDic.allKeys containsObject:@"pDept"]) {
//            self.pDept = patientDic[@"pDept"];
//        }
//        if ([patientDic.allKeys containsObject:@"pDept"]) {
//            self.pDept = patientDic[@"pDept"];
//        }
//        
//        if ([patientDic.allKeys containsObject:@"patientState"]) {
//            self.patientState = patientDic[@"patientState"];
//        }
//        if ([patientDic.allKeys containsObject:@"pNation"]) {
//            self.pNation = patientDic[@"pNation"];
//        }
//        
//        if ([patientDic.allKeys containsObject:@"pProfession"]) {
//            self.pProfession = patientDic[@"pProfession"];
//        }
//        if ([patientDic.allKeys containsObject:@"pMaritalStatus"]) {
//            self.pMaritalStatus = patientDic[@"pMaritalStatus"];
//        }
//        
//        if ([patientDic.allKeys containsObject:@"pMobileNum"]) {
//            self.pMobileNum = patientDic[@"pMobileNum"];
//        }
//        if ([patientDic.allKeys containsObject:@"pLinkman"]) {
//            self.pLinkman = patientDic[@"pLinkman"];
//        }
//        
//        if ([patientDic.allKeys containsObject:@"pLinkmanMobileNum"]) {
//            self.pLinkmanMobileNum = patientDic[@"pLinkmanMobileNum"];
//        }
//        if ([patientDic.allKeys containsObject:@"presenter"]) {
//            self.presenter = patientDic[@"presenter"];
//        }
//        if ([patientDic.allKeys containsObject:@"pAdmissionTime"]) {
//            self.pAdmissionTime = patientDic[@"pAdmissionTime"];
//        }
//        if ([patientDic.allKeys containsObject:@"pSubAdmissionTime"]) {
//            self.pSubAdmissionTime = patientDic[@"pSubAdmissionTime"];
//        }
//        if ([patientDic.allKeys containsObject:@"pCountOfHospitalized"]) {
//            self.pCountOfHospitalized = patientDic[@"pCountOfHospitalized"];
//        }
//        if ([patientDic.allKeys containsObject:@"pAdmitDate"]) {
//            self.pAdmitDate = patientDic[@"pAdmitDate"];
//        }
    }
    return self;
}
@end
