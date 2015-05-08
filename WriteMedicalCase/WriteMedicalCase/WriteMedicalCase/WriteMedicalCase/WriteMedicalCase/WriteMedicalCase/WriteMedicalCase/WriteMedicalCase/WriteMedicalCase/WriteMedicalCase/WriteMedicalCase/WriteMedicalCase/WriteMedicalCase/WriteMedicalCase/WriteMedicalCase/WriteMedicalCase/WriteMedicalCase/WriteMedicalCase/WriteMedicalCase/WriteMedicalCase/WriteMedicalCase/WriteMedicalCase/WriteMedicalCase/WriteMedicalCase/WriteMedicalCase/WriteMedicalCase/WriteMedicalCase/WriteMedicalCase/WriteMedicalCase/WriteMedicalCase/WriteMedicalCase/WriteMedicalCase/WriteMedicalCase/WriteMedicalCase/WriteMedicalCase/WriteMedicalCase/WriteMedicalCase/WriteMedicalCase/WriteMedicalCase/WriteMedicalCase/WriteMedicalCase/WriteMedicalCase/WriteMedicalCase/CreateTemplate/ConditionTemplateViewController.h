//
//  ConditionTemplateViewController.h
//  MedicalCase
//
//  Created by ihefe-JF on 15/4/22.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ConditionTemplateViewControllerDelegate <NSObject>
-(void)didSelectedTemplateWithNode:(Template*)templated;;

@end
@interface ConditionTemplateViewController : UIViewController
@property (nonatomic,strong) NSString *templateName;

@property (nonatomic,weak) id <ConditionTemplateViewControllerDelegate> delegate;
@end
