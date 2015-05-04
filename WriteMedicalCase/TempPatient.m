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
            NSLog(@"病人必须包含pID");
            abort();
        }
        if ([patientDic.allKeys containsObject:@"pGender"]) {
            self.pGender = patientDic[@"pGender"];
        }else {
            NSLog(@"病人必须包含pGender");
            abort();
        }
        if ([patientDic.allKeys containsObject:@"pName"]) {
            self.pName = patientDic[@"pName"];
        }else {
            NSLog(@"病人必须包含pName");
            abort();
        }
        ////
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
        if ([patientDic.allKeys containsObject:@"pBedNum"]) {
            self.pBedNum = patientDic[@"pBedNum"];
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
        if ([patientDic.allKeys containsObject:@"pCountOfHospitalized"]) {
            self.pCountOfHospitalized = patientDic[@"pCountOfHospitalized"];
        }

    }
    
    
    return self;
}
@end
