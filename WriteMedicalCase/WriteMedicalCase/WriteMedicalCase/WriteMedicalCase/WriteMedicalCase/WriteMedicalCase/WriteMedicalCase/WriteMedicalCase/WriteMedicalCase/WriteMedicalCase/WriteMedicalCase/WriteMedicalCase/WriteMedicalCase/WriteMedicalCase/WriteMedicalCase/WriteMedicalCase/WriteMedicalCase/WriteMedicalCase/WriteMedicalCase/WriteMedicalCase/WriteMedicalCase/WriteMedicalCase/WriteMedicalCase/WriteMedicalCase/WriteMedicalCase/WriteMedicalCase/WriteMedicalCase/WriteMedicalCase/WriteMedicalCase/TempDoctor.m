//
//  TempDoctor.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/4.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "TempDoctor.h"

@implementation TempDoctor
-(instancetype)initWithTempDoctorDic:(NSDictionary*)doctorDic
{
    if (self = [super init]) {
        if ([doctorDic.allKeys containsObject:@"dID"]) {
            self.dID = doctorDic[@"dID"];
        }else {
            NSLog(@"医生必须包含dID");
            abort();
        }
        
        if ([doctorDic.allKeys containsObject:@"dName"]) {
            self.dName = doctorDic[@"dName"];
        }else {
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
