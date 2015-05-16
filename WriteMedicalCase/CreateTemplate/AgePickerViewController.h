//
//  AgePickerViewController.h
//  MedCase
//
//  Created by ihefe-JF on 15/3/9.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AgePickerViewControllerDelegate

-(void)selectedAgeRangeIs:(NSString *)ageString;

@end

@interface AgePickerViewController : UIViewController

@property (nonatomic,weak) id <AgePickerViewControllerDelegate> ageDelegate;
@property (nonatomic,strong) Node *selectedHightNode;
@property (nonatomic,strong) Node *selectedLowNode;
@property (nonatomic,strong) NSString *defaultString;
@end
