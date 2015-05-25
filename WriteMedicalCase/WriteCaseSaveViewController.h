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

@protocol WriteCaseSaveViewControllerDelegate <NSObject>

-(void)didExitEditRecordCaseWithCurrentPatient:(TempPatient*)patient;


@end

@interface WriteCaseSaveViewController : UIViewController
@property (nonatomic,strong) NSString *caseType;

@property (nonatomic,strong) TempPatient *tempPatient;

@property(nonatomic,strong) RecordBaseInfo *recordBaseInfo;
@property (nonatomic) BOOL isRemoveLeftButton;

@property (nonatomic,weak) id<WriteCaseSaveViewControllerDelegate> delegate;
@end
