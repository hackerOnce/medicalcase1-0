//
//  TempPatient.h
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/4.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TempPatient : NSObject
@property (nonatomic) BOOL pAudit; //待审核的病人标志
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
@property (nonatomic,strong) NSString *presenter;//病史陈述者
@property (nonatomic,strong) NSString *pAdmissionTime;//入院时间 //年月日
@property (nonatomic,strong) NSString *pSubAdmissionTime; //时分秒
@property (nonatomic,strong) NSString *patientState;//未出院
@property (nonatomic,strong) NSString *pAdmitDate; //入院日期
//@property (nonatomic,strong) NSString *pRecordTime;
//@property (nonatomic,strong) NSString *pSubRecordTime;
-(instancetype)initWithPatientID:(NSDictionary*)patientDic;
-(instancetype)initPatientWithPatient:(TempPatient*)patient;

@end
