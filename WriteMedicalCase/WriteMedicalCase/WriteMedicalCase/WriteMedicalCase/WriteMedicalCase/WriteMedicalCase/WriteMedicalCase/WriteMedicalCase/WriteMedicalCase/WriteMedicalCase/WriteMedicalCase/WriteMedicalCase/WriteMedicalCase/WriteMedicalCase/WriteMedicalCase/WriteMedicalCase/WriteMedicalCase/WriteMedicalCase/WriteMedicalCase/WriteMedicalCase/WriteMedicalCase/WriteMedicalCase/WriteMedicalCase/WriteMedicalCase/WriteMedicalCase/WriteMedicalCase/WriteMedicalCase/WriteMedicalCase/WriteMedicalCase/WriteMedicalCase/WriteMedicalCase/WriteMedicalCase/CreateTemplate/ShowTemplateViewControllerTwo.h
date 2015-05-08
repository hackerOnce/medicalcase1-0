//
//  ShowTemplateViewControllerTwo.h
//  MedicalCase
//
//  Created by ihefe-JF on 15/4/8.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Template.h"

@protocol ShowTemplateViewControllerTwo

@required
-(void)didSelectedTemplate:(Template*)template;

@end

@interface ShowTemplateViewControllerTwo : UIViewController
@property(nonatomic,strong) NSString *fetchStr;

@property (nonatomic,weak) id <ShowTemplateViewControllerTwo>  showTempDelegate;
@end
