//
//  ToothViewController.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/6/15.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "ToothViewController.h"
#import "SelectedDentalNumber.h"
#import "SelectedDentalNumberCell.h"

@interface ToothViewController ()<UIGestureRecognizerDelegate,SelectedDentalNumberDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *YDirectionBottomConstraints;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *XDirectionRightConstraints;
@property (weak, nonatomic) IBOutlet SelectedDentalNumber *leftUpView;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *TapGesture;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *YCenterConstraints;

@property (nonatomic) BOOL doubleClickedSameView;

@property (nonatomic) CGFloat YCenterOriginValue;
@property (nonatomic) CGFloat YDirectionOriginValue;
@end

@implementation ToothViewController
- (IBAction)TapClicked:(UITapGestureRecognizer *)sender
{
    CGPoint location = [sender locationInView:sender.view];
    
    self.doubleClickedSameView = !self.doubleClickedSameView;
    
    BOOL isClickedUpView =  [self.leftUpView pointInside:location withEvent:UIEventTypeTouches];
    if (isClickedUpView) {
        
        if (self.doubleClickedSameView) {
            
            self.leftUpView.isFace = YES;
            [self.leftUpView addViewToMyView];
            
            self.YCenterOriginValue = self.YCenterConstraints.constant;
            self.YDirectionOriginValue = self.YDirectionBottomConstraints.constant;
            
            self.YCenterConstraints.constant = -(self.view.frame.size.width - 50)/2;
            self.YDirectionBottomConstraints.constant = 20;
            
        }else {
            
            self.leftUpView.isFace = NO;
            [self.leftUpView addViewToMyView];

            self.YCenterConstraints.constant = self.YCenterOriginValue;
            self.YDirectionBottomConstraints.constant = self.YDirectionOriginValue;

        }
    }
    [UIView animateWithDuration:0.3 animations:^{
        [self.containerView setNeedsUpdateConstraints];
        [self.containerView layoutIfNeeded];
    }];
}
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    
    if ([touch.view.superview isKindOfClass:[SelectedDentalNumberCell class]]) {
        return NO;
    }
    if ([touch.view isKindOfClass:[self.leftUpView class]]) {
        return YES;
    }
    return NO;
    
}
#pragma mask - view life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.leftUpView.direction = 1;
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.leftUpView.delegate = self;
}
#pragma mask - SelectedDentalNumberDelegate
-(void)didSelectedDentalNumber:(NSString *)number atIndexPath:(NSIndexPath *)indexPath
{
    
}
@end
