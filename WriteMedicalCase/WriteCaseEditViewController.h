//
//  WriteCaseEditViewController.h
//  WriteMedicalCase
//
//  Created by GK on 15/4/29.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TempPatient.h"
#import "personInfoView.h"

@protocol WriteCaseEditViewControllerDelegate;

@interface WriteCaseEditViewController : UIViewController
@property (strong,nonatomic) NSString *labelString;
@property (weak,nonatomic) id <WriteCaseEditViewControllerDelegate> Editdelegate;
@property (weak, nonatomic) IBOutlet personInfoView *personInfoView;

@property (nonatomic,strong) UIView *rightSideSlideView;
@property (nonatomic) BOOL  rightSlideViewFlag;
@property (nonatomic,strong) NSString *textViewContent;

@property (nonatomic,strong) TempPatient *tempPatient;

@property (nonatomic,strong) RecordBaseInfo *recordBaseInfo;
@end

@protocol WriteCaseEditViewControllerDelegate <NSObject>
-(void)didWriteStringToMedicalRecord:(NSString*)writeString withKeyStr:(NSString *)keyStr;


@end

