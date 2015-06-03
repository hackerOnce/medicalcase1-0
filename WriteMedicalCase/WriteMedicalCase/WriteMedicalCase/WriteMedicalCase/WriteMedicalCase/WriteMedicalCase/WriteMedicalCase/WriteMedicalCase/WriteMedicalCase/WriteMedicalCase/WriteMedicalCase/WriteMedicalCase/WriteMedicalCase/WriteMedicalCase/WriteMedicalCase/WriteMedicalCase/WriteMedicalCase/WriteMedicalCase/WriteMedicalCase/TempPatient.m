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
        }else {
            if (patientDic == nil) {
                self.pID = @"086033";
            }else {
                NSLog(@"病人必须包含pID");
                abort();
            }
        }
        if ([patientDic.allKeys containsObject:@"pGender"]) {
            self.pGender = patientDic[@"pGender"];
        }else {
            if (patientDic == nil) {
                self.pGender = @"女";
            }else {
              NSLog(@"病人必须包含pGender");
              abort();
            }
        }
        if ([patientDic.allKeys containsObject:@"pName"]) {
            self.pName = patientDic[@"pName"];
        }else {
            if (patientDic == nil) {
                self.pName = @" ";
            }else {
                NSLog(@"病人必须包含pName");
                abort();
            }
        }
        
        if ([patientDic.allKeys containsObject:@"patientState"]) {
            self.patientState = patientDic[@"patientState"];
        }else {
            if (patientDic == nil) {
                self.patientState = @" ";
            }
        }
        ////
        if ([patientDic.allKeys containsObject:@"pAge"]) {
            self.pAge = patientDic[@"pAge"];
        }else {
            if (patientDic == nil) {
                self.pAge = @" ";
            }
        }
        if ([patientDic.allKeys containsObject:@"pCity"]) {
            self.pCity = patientDic[@"pCity"];
        }else {
            if (patientDic == nil) {
                self.pCity = @" ";
            }

        }
        if ([patientDic.allKeys containsObject:@"pProvince"]) {
            self.pProvince = patientDic[@"pProvince"];
        }else
        {
            if (patientDic == nil) {
                self.pProvince = @" ";
            }

        }
        if ([patientDic.allKeys containsObject:@"pDetailAddress"]) {
            self.pDetailAddress = patientDic[@"pDetailAddress"];
        }else {
            if (patientDic == nil) {
                self.pDetailAddress = @"  ";
            }

        }
        
        if ([patientDic.allKeys containsObject:@"pDept"]) {
            self.pDept = patientDic[@"pDept"];
        }else {
            if (patientDic == nil) {
                self.pDept = @" ";
            }

        }
        if ([patientDic.allKeys containsObject:@"pDept"]) {
            self.pDept = patientDic[@"pDept"];
        }else {
            if (patientDic == nil) {
                self.pDept = @" ";
            }
            
        }

        if ([patientDic.allKeys containsObject:@"patientState"]) {
            self.patientState = patientDic[@"patientState"];
        }else {
            if (patientDic == nil) {
                self.patientState = @" ";
            }

        }
        if ([patientDic.allKeys containsObject:@"pNation"]) {
            self.pNation = patientDic[@"pNation"];
        }else {
            if (patientDic == nil) {
                self.pNation = @" ";
            }

        }

        if ([patientDic.allKeys containsObject:@"pProfession"]) {
            self.pProfession = patientDic[@"pProfession"];
        }else {
            if (patientDic == nil) {
                self.pProfession = @" ";
            }

        }
        if ([patientDic.allKeys containsObject:@"pMaritalStatus"]) {
            self.pMaritalStatus = patientDic[@"pMaritalStatus"];
        }else {
            
        }
        
        if ([patientDic.allKeys containsObject:@"pMobileNum"]) {
            self.pMobileNum = patientDic[@"pMobileNum"];
        }else {
            if (patientDic == nil) {
                self.pMobileNum = @" ";
            }

        }
        if ([patientDic.allKeys containsObject:@"pLinkman"]) {
            self.pLinkman = patientDic[@"pLinkman"];
        }else {
            
        }
        
        if ([patientDic.allKeys containsObject:@"pLinkmanMobileNum"]) {
            self.pLinkmanMobileNum = patientDic[@"pLinkmanMobileNum"];
        }
        if ([patientDic.allKeys containsObject:@"presenter"]) {
            self.presenter = patientDic[@"presenter"];
        }else {
            if (patientDic == nil) {
                self.presenter = @" ";
            }

        }
        if ([patientDic.allKeys containsObject:@"pAdmissionTime"]) {
            self.pAdmissionTime = patientDic[@"pAdmissionTime"];
        }else {
            self.pAdmissionTime = @" ";
        }
        if ([patientDic.allKeys containsObject:@"pSubAdmissionTime"]) {
            self.pSubAdmissionTime = patientDic[@"pSubAdmissionTime"];
        }else {
            self.pSubAdmissionTime = @" ";
        }

        if ([patientDic.allKeys containsObject:@"pCountOfHospitalized"]) {
            self.pCountOfHospitalized = patientDic[@"pCountOfHospitalized"];
        }

    }
    
    
    return self;
}
@end
