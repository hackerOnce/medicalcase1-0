//
//  CurrentDoctor.h
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/7.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TempDoctor.h"
@interface CurrentDoctor : NSObject
@property (nonatomic,strong) NSString *dID;
@property (nonatomic,strong) NSString *dName;
@property (nonatomic,strong) NSString *dProfessionalTitle;
@property (nonatomic,strong) NSString *dept;
@property (nonatomic,strong) NSString *medicalTeam;

@property (nonatomic,strong) TempDoctor *tempDoctor;

+(instancetype)currentDoctor;

@end
