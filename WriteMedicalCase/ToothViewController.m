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
#import "ToothView.h"


@interface ToothViewController ()<UIGestureRecognizerDelegate,SelectedDentalNumberDelegate,UITextViewDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *YDirectionBottomConstraints;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *XDirectionRightConstraints;
@property (weak, nonatomic) IBOutlet SelectedDentalNumber *leftUpView;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *TapGesture;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *YCenterConstraints;
@property (weak, nonatomic) IBOutlet SelectedDentalNumber *leftBottomView;
@property (weak, nonatomic) IBOutlet SelectedDentalNumber *rightBottomVIew;
@property (weak, nonatomic) IBOutlet SelectedDentalNumber *rightUpVIew;
@property (weak, nonatomic) IBOutlet UITextField *placeHolder;
@property (weak, nonatomic) IBOutlet UITextView *descriptionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *TextViewUpHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewHeightConstraints;

@property (nonatomic) CGFloat textViewUpOriginHeight;

@property (nonatomic) BOOL doubleClickedSameView;

@property (nonatomic) CGFloat YCenterOriginValue;
@property (nonatomic) CGFloat YDirectionOriginValue;
@end

@implementation ToothViewController
- (IBAction)TapClicked:(UITapGestureRecognizer *)sender
{
    CGPoint location = [sender locationInView:sender.view];
    
    self.doubleClickedSameView = !self.doubleClickedSameView;

    BOOL isClickedUpLeftView =  CGRectContainsPoint(self.leftUpView.frame, location);
    BOOL isClickedUpRightView = CGRectContainsPoint(self.rightUpVIew.frame, location);
    BOOL isClickedBottomLeftView = CGRectContainsPoint(self.leftBottomView.frame, location);
    BOOL isClickedBottomRightView = CGRectContainsPoint(self.rightBottomVIew.frame, location);

    if (isClickedBottomRightView) {
        if (self.doubleClickedSameView) {
            self.rightBottomVIew.isFace = YES;
            [self.rightBottomVIew addViewToMyView];
            
            self.YCenterOriginValue = self.YCenterConstraints.constant;
            self.YDirectionOriginValue = self.YDirectionBottomConstraints.constant;
            
            self.YCenterConstraints.constant = (self.view.frame.size.width - 50)/2.0;
            self.YDirectionBottomConstraints.constant = (self.view.frame.size.height - 20)/4;
            
            self.leftUpView.hidden = YES;
            self.rightUpVIew.hidden = YES;
            self.leftBottomView.hidden = YES;
            
        }else {
            self.rightBottomVIew.isFace = NO;
            [self.rightBottomVIew addViewToMyView];
            
            self.YCenterConstraints.constant = 0;
            self.YDirectionBottomConstraints.constant = 107;
            
            self.leftUpView.hidden = NO;
            self.rightUpVIew.hidden = NO;
            self.leftBottomView.hidden = NO;
        }
    }
    if (isClickedBottomLeftView) {
        if (self.doubleClickedSameView) {
            self.leftBottomView.isFace = YES;
            [self.leftBottomView addViewToMyView];
            
            self.YCenterOriginValue = self.YCenterConstraints.constant;
            self.YDirectionOriginValue = self.YDirectionBottomConstraints.constant;
            
            self.YCenterConstraints.constant = -(self.view.frame.size.width - 50)/2.0;
            self.YDirectionBottomConstraints.constant = (self.view.frame.size.height - 20)/4;
            
            self.leftUpView.hidden = YES;
            self.rightUpVIew.hidden = YES;
            self.rightBottomVIew.hidden = YES;
            
        }else {
            self.leftBottomView.isFace = NO;
            [self.leftBottomView addViewToMyView];
            
            self.YCenterConstraints.constant = 0;
            self.YDirectionBottomConstraints.constant = 107;
            
            self.leftUpView.hidden = NO;
            self.rightUpVIew.hidden = NO;
            self.rightBottomVIew.hidden = NO;
        }
    }
    if (isClickedUpRightView) {
        if (self.doubleClickedSameView) {
            self.rightUpVIew.isFace = YES;
            [self.rightUpVIew addViewToMyView];
            
            self.YCenterOriginValue = self.YCenterConstraints.constant;
            self.YDirectionOriginValue = self.YDirectionBottomConstraints.constant;
            
            self.YCenterConstraints.constant = (self.view.frame.size.width - 50)/2.0;
            self.YDirectionBottomConstraints.constant = 20;
            
            self.leftUpView.hidden = YES;
            self.leftBottomView.hidden = YES;
            self.rightBottomVIew.hidden = YES;

        }else {
            self.rightUpVIew.isFace = NO;
            [self.rightUpVIew addViewToMyView];
            
            self.YCenterConstraints.constant = 0;
            self.YDirectionBottomConstraints.constant = 107;
            
            self.leftUpView.hidden = NO;
            self.leftBottomView.hidden = NO;
            self.rightBottomVIew.hidden = NO;
        }
    }
    if (isClickedUpLeftView) {
        
        if (self.doubleClickedSameView) {
            
            self.leftUpView.isFace = YES;
            [self.leftUpView addViewToMyView];
            
            self.YCenterOriginValue = self.YCenterConstraints.constant;
            self.YDirectionOriginValue = self.YDirectionBottomConstraints.constant;
            
            self.YCenterConstraints.constant = -(self.view.frame.size.width - 50)/2.0;
            self.YDirectionBottomConstraints.constant = 20;
            
            self.rightUpVIew.hidden = YES;
            self.leftBottomView.hidden = YES;
            self.rightBottomVIew.hidden = YES;
            
        }else {
            
            self.leftUpView.isFace = NO;
            [self.leftUpView addViewToMyView];

            self.YCenterConstraints.constant = 0;
            self.YDirectionBottomConstraints.constant = 107;
            
            self.rightUpVIew.hidden = NO;
            self.leftBottomView.hidden = NO;
            self.rightBottomVIew.hidden = NO;

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
    if ([touch.view isKindOfClass:[self.rightUpVIew class]]) {
        return YES;
    }
    return NO;
    
}
#pragma mask - view life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.leftUpView.direction = 1;
    self.leftBottomView.direction = 3;
    self.rightUpVIew.direction = 2;
    self.rightBottomVIew.direction = 4;
    
    self.descriptionView.delegate = self;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.leftUpView.delegate = self;
    self.leftBottomView.delegate = self;
    self.rightBottomVIew.delegate = self;
    self.rightUpVIew.delegate = self;
    
    [self addKeyBoardNotification];
}

#pragma mask - Text view delegate
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    self.placeHolder.hidden = YES;
    return YES;
}
-(void)textViewDidChange:(UITextView *)textView
{
    if ([self.descriptionView.text isEqualToString:@""]) {
        self.placeHolder.placeholder = @"请输入症状描述";
        self.placeHolder.hidden = NO;
    }else {
        self.placeHolder.hidden = YES;
    }
}
#pragma mask - SelectedDentalNumberDelegate
-(void)didSelectedDentalNumber:(NSString *)number atIndexPath:(NSIndexPath *)indexPath department:(NSString *)selectedDepartment
{
    ToothView *view = [[ToothView alloc] initWithFrame:CGRectMake(100, 200, 50, 44)];
    view.number = number;
    view.position = selectedDepartment;
    
   // [view layoutSubviews];
    
    view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];
    
}

#pragma mask - keyboard 
-(void)addKeyBoardNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

}
-(void)keyboardWillShow:(NSNotification*)notificationInfo
{
    self.textViewUpOriginHeight = self.containerViewHeightConstraints.constant;
    self.containerViewHeightConstraints.constant = 1;
    [UIView animateWithDuration:0.5 delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self.containerView setNeedsLayout];
                     }
                     completion:nil];
    
    
}
-(void)keyboardWillHide:(NSNotification*)notificationInfo
{
    self.containerViewHeightConstraints.constant = self.textViewUpOriginHeight;
    [UIView animateWithDuration:0.5 delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self.containerView setNeedsLayout];
                     }
                     completion:nil];
}
@end
