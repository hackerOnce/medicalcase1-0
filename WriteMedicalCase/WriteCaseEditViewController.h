//
//  WriteCaseEditViewController.h
//  WriteMedicalCase
//
//  Created by GK on 15/4/29.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WriteCaseEditViewControllerDelegate;

@interface WriteCaseEditViewController : UIViewController
@property (strong,nonatomic) NSString *labelString;
@property (weak,nonatomic) id <WriteCaseEditViewControllerDelegate> Editdelegate;

@property (nonatomic,strong) UIView *rightSideSlideView;
@property (nonatomic) BOOL  rightSlideViewFlag;
@property (nonatomic,strong) NSString *textViewContent;
@end

@protocol WriteCaseEditViewControllerDelegate <NSObject>
-(void)didWriteStringToMedicalRecord:(NSString*)writeString withKeyStr:(NSString *)keyStr;


@end

