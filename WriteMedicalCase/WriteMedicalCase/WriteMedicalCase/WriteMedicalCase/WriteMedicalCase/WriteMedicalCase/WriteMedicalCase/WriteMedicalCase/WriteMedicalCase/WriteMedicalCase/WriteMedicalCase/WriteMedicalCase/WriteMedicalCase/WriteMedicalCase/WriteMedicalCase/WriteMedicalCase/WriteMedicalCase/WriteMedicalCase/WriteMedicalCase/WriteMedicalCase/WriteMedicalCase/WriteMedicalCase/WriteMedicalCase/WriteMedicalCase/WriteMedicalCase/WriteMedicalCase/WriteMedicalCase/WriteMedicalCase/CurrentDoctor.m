//
//  CurrentDoctor.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/7.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "CurrentDoctor.h"

@implementation CurrentDoctor

+(CurrentDoctor *)currentDoctor
{
    static CurrentDoctor *currentDoctor;
    static dispatch_once_t token;
    
    dispatch_once(&token,^{
        currentDoctor = [[CurrentDoctor alloc] init];
    });
    return currentDoctor;
}
-(instancetype)init
{
    if (self = [super init]) {
        self.dept = self.tempDoctor.dept;
        self.dProfessionalTitle = self.tempDoctor.dProfessionalTitle;
        self.dName = self.tempDoctor.dName;
        self.dID = self.tempDoctor.dID;
    }
    return self;
}
-(TempDoctor *)tempDoctor
{
    if (!_tempDoctor) {
        NSString *dID = @"88888";
        NSString *dName = @"测试医生";
        NSString *dProfessionalTitle = @"小医生";
        NSString *dept = @"心内科";
        NSString *medicalTeam = @"无";
        _tempDoctor = [[TempDoctor alloc] initWithTempDoctorDic:NSDictionaryOfVariableBindings(dID,dName,dProfessionalTitle,dept,medicalTeam)];
    }
    return _tempDoctor;
}

@end
