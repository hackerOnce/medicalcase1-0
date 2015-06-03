//
//  SelectCommitDoctorViewController.h
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/20.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectCommitDoctorViewControllerDelegate <NSObject>

-(void)didSelectedDoctor:(TempDoctor*)doctor;

@end
@interface SelectCommitDoctorViewController : UIViewController
@property (nonatomic,weak) id <SelectCommitDoctorViewControllerDelegate> delegate;
@end
