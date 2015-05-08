//
//  writeCaseFirstItemViewController.h
//  WriteMedicalCase
//
//  Created by GK on 15/5/2.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol writeCaseFirstItemViewControllerDelegate <NSObject>
-(void)didWriteWithString:(NSString*)writeString;

@end

@interface writeCaseFirstItemViewController : UIViewController
@property (nonatomic) id <writeCaseFirstItemViewControllerDelegate> delegate;
@property (nonatomic,strong) NSString *titleString;
@property (nonatomic,strong) NSString *textViewContent;

@property (nonatomic,strong) UIView *rightSideSlideView;
@property (nonatomic) BOOL  rightSlideViewFlag;

@end
