//
//  RecordNoteWarningViewController.h
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/6/2.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RecordNoteWarningViewControllerDelegate <NSObject>

-(void)didSelectedDateString:(NSDictionary*)dict;

@end
@interface RecordNoteWarningViewController : UIViewController
@property (nonatomic,weak) id<RecordNoteWarningViewControllerDelegate> delegate;
@end
