//
//  TempDoctor.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/4.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "TempDoctor.h"

@implementation TempDoctor

+(instancetype)loginDoctor
{
    static TempDoctor *sharedDoctor;
    static dispatch_once_t dispatch_oncet;
    dispatch_once(&dispatch_oncet,^{
        sharedDoctor = [[self alloc] init];
    });
    
    return sharedDoctor;
}

+(instancetype)setSharedDoctorWithDict:(NSDictionary*)doctorDic
{
    TempDoctor *doctor = [TempDoctor loginDoctor];
    if (doctorDic) {
        if ([doctorDic.allKeys containsObject:@"dID"]) {
            doctor.dID = doctorDic[@"dID"];
        }else if([doctorDic.allKeys containsObject:@"id"]) {
            doctor.dID = doctorDic[@"id"];
        }else {
            NSLog(@"医生必须包含dID");
            abort();
        }
        
        if ([doctorDic.allKeys containsObject:@"dName"]) {
            doctor.dName = doctorDic[@"dName"];
        }else if([doctorDic.allKeys containsObject:@"name"]) {
            doctor.dName = doctorDic[@"name"];
        }else{
            NSLog(@"医生必须包含dName");
            abort();
        }
        
        if ([doctorDic.allKeys containsObject:@"dProfessionalTitle"]) {
            doctor.dProfessionalTitle = doctorDic[@"dProfessionalTitle"];
        }
        if ([doctorDic.allKeys containsObject:@"dept"]) {
            doctor.dept = doctorDic[@"dept"];
        }
        if ([doctorDic.allKeys containsObject:@"medicalTeam"]) {
            doctor.medicalTeam = doctorDic[@"medicalTeam"];
        }
        
        if ([doctorDic.allKeys containsObject:@"isResidentDoctor"]) {
            doctor.isResidentDoctor = doctorDic[@"isResidentDoctor"];
        }
        if ([doctorDic.allKeys containsObject:@"isChiefPhysicianDoctor"]) {
            doctor.isChiefPhysicianDoctor = doctorDic[@"isChiefPhysicianDoctor"];
        }
        if ([doctorDic.allKeys containsObject:@"isAttendingPhysicianDoctor"]) {
            doctor.isAttendingPhysicianDoctor = doctorDic[@"isAttendingPhysicianDoctor"];
        }
    }

    return doctor;
}
-(instancetype)initWithTempDoctorDic:(NSDictionary*)doctorDic
{

    if (self = [super init]) {
        
        if ([doctorDic.allKeys containsObject:@"dID"]) {
            _dID = doctorDic[@"dID"];
        }else if([doctorDic.allKeys containsObject:@"id"]) {
            _dID = doctorDic[@"id"];
        }else {
            NSLog(@"医生必须包含dID");
            abort();
        }
        
        if ([doctorDic.allKeys containsObject:@"dName"]) {
            _dName = doctorDic[@"dName"];
        }else if([doctorDic.allKeys containsObject:@"name"]) {
            _dName = doctorDic[@"name"];
        }else{
            NSLog(@"医生必须包含dName");
            abort();
        }

        if ([doctorDic.allKeys containsObject:@"dProfessionalTitle"]) {
            self.dProfessionalTitle = doctorDic[@"dProfessionalTitle"];
        }
        if ([doctorDic.allKeys containsObject:@"dept"]) {
            self.dept = doctorDic[@"dept"];
        }
        if ([doctorDic.allKeys containsObject:@"medicalTeam"]) {
            self.medicalTeam = doctorDic[@"medicalTeam"];
        }

        if ([doctorDic.allKeys containsObject:@"isResidentDoctor"]) {
            self.isResidentDoctor = doctorDic[@"isResidentDoctor"];
        }
        if ([doctorDic.allKeys containsObject:@"isChiefPhysicianDoctor"]) {
            self.isChiefPhysicianDoctor = doctorDic[@"isChiefPhysicianDoctor"];
        }
        if ([doctorDic.allKeys containsObject:@"isAttendingPhysicianDoctor"]) {
            self.isAttendingPhysicianDoctor = doctorDic[@"isAttendingPhysicianDoctor"];
        }
    }
    
    return self;
}
@end
