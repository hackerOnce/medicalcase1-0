//
//  SelectedShareRangeViewController.h
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/14.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectedShareRangeViewControllerDelegate <NSObject>

-(void)didSelectedSharedUsers:(NSDictionary*)sharedUser;

@end
@interface SelectedShareRangeViewController : UIViewController
@property (nonatomic,strong) NSMutableArray *selectedTemplates;
@property (nonatomic,weak) id<SelectedShareRangeViewControllerDelegate> delegate;
@property (nonatomic) BOOL isForOthers;
@end
