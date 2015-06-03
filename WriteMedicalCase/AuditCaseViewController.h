//
//  AuditCaseViewController.h
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/27.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TempCaseBaseInfo.h"


@protocol AuditCaseViewControllerDelegate <NSObject>

-(void)didExitAuditCaseViewController;

@end
@interface AuditCaseViewController : UIViewController

@property (nonatomic,strong) TempCaseBaseInfo *tempCaseInfo;
@property (nonatomic,strong) RecordBaseInfo *recordBaseInfo;

@property (weak,nonatomic) id<AuditCaseViewControllerDelegate> delegate;
@end
