//
//  TempPatient.h
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/4.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TempPatient : NSObject
@property (nonatomic,strong) NSString *pID;
@property (nonatomic,strong) NSString *pName;
@property (nonatomic,strong) NSString *pGender;
@property (nonatomic,strong) NSString *pAge;
@property (nonatomic,strong) NSString *pCity;
@property (nonatomic,strong) NSString *pProvince;
@property (nonatomic,strong) NSString *pDetailAddress;
@property (nonatomic,strong) NSString *pDept;
@property (nonatomic,strong) NSString *pBedNum;
@property (nonatomic,strong) NSString *pNation;
@property (nonatomic,strong) NSString *pProfession;
@property (nonatomic,strong) NSString *pMaritalStatus;
@property (nonatomic,strong) NSString *pMobileNum;
@property (nonatomic,strong) NSString *pLinkman;
@property (nonatomic,strong) NSString *pLinkmanMobileNum;
@property (nonatomic,strong) NSString *pCountOfHospitalized;

-(instancetype)initWithPatientID:(NSDictionary*)patientDic;

@end
