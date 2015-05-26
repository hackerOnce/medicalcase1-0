//
//  TempDoctor.h
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/4.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TempDoctor : NSObject
@property (nonatomic,strong) NSString *dID;
@property (nonatomic,strong) NSString *dName;
@property (nonatomic,strong) NSString *dProfessionalTitle;
@property (nonatomic,strong) NSString *dept;
@property (nonatomic,strong) NSString *medicalTeam;
@property (nonatomic,strong) NSString *isResidentDoctor;
@property (nonatomic,strong) NSString *isChiefPhysicianDoctor;
@property (nonatomic,strong) NSString *isAttendingPhysicianDoctor;

-(instancetype)initWithTempDoctorDic:(NSDictionary*)doctorDic;
+(instancetype)setSharedDoctorWithDict:(NSDictionary*)doctorDic;

@end
