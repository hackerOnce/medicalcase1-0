//
//  HeaderView.h
//  MedicalCase
//
//  Created by ihefe-JF on 15/4/23.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol HeadViewDelegate;

@interface HeadView : UIView
@property (weak,nonatomic) id <HeadViewDelegate> delegate;
@property (nonatomic) NSInteger section;
@property (nonatomic,strong) UIButton *backBtn;
@property (nonatomic) BOOL open;

@end
           
@protocol HeadViewDelegate <NSObject>
           
-(void)selectedWith:(HeadView *)view;

@end
