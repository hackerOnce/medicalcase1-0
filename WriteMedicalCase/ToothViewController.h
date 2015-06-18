//
//  ToothViewController.h
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/6/15.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ToothViewControllerDelegate<NSObject>

-(void)toothNumberSelectedResultString:(NSString*)selectedString;

@end

@interface ToothViewController : UIViewController

@property (nonatomic,weak) id<ToothViewControllerDelegate> delegate;

@end
