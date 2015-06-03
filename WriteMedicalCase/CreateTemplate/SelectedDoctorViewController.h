//
//  SelectedDoctorViewController.h
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/14.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectedDoctorViewControllerDelegate <NSObject>

-(void)didSelectedDoctor:(NSDictionary*)sharedUser;

@end

@interface SelectedDoctorViewController : UIViewController

@property (nonatomic,weak) id<SelectedDoctorViewControllerDelegate> delegate;
@property (nonatomic) BOOL isForOthers;
@property (nonatomic,strong) NSMutableArray *selectedTemplates;
@property (nonatomic,strong) NSString *selectedSharedStyle;
@end
