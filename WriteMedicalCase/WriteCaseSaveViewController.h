//
//  WriteCaseSaveViewController.h
//  WriteMedicalCase
//
//  Created by GK on 15/4/29.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TempPatient.h"
#import "TempDoctor.h"
#import "TempCaseBaseInfo.h"

@interface WriteCaseSaveViewController : UIViewController
@property (nonatomic,strong) NSString *caseType;

@property (nonatomic,strong) CurrentPatient *currentPatient;
@property (nonatomic,strong) CurrentDoctor *currentDoctor;

@property (nonatomic,strong) TempPatient *tempPatient;
@property (nonatomic,strong) TempDoctor *tempResidentDoctor;
//@property (nonatomic,strong) TempCaseBaseInfo *tempCaseBaseInfo;
@property (nonatomic,strong) TempDoctor *tempAttendingPhysicianDoctor;
@property (nonatomic,strong) TempDoctor *tempChiefPhysicianDoctor;

@property (nonatomic) BOOL isRemoveLeftButton;
@end
