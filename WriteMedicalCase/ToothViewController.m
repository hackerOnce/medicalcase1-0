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

#import "FHSView.h"
#import "MenstruationView.h"
#import "UIView+CaptureImage.h"


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

@property (nonatomic,strong) NSMutableDictionary *imageInfoDict;

@property (nonatomic) CGFloat textViewUpOriginHeight;

@property (nonatomic) BOOL doubleClickedSameView;

@property (nonatomic) CGFloat YCenterOriginValue;
@property (nonatomic) CGFloat YDirectionOriginValue;

@property (nonatomic,strong) ToothView *toothView;
@end

@implementation ToothViewController
- (IBAction)saveButtonClicked:(UIBarButtonItem *)sender
{
    NSString *textViewText = @"";
    if (self.descriptionView.text) {
        textViewText = self.descriptionView.text;
    }
    
    [self.imageInfoDict setObject:textViewText forKey:@"description"];
    NSError *error;
    NSString *resultString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:self.imageInfoDict options:NSJSONWritingPrettyPrinted error:&error] encoding:NSUTF8StringEncoding];
    if ([self.delegate respondsToSelector:@selector(toothNumberSelectedResultString:)]) {
        [self.delegate toothNumberSelectedResultString:resultString];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)cancelButonClicked:(UIBarButtonItem *)sender
{
    if ([self.delegate respondsToSelector:@selector(toothNumberSelectedResultString:)]) {
        [self.delegate toothNumberSelectedResultString:nil];
    }
}
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
            self.YDirectionBottomConstraints.constant = (self.containerView.frame.size.height - 20);
            
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
            
            self.YCenterConstraints.constant = -(self.containerView.frame.size.width - 50)/2.0;
            self.YDirectionBottomConstraints.constant = (self.containerView.frame.size.height - 20);
            
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
    
    
    self.preferredContentSize = CGSizeMake(630, 500);
    
    FHSView *hfsView = [[FHSView alloc] initWithFrame:CGRectMake(100, 240, 100, 44)];
    hfsView.direction=4;
    [self.view addSubview:hfsView];
    
    MenstruationView *mView = [[MenstruationView alloc] initWithFrame:CGRectMake(300, 200, 250, 80)];
    [self.view addSubview:mView];
    
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
    
    [self.imageInfoDict setObject:number forKey:@"number"];
    [self.imageInfoDict setObject:selectedDepartment forKey:@"selectedDepartment"];

    self.toothView.number = number;
    self.toothView.position = selectedDepartment;
    
}
-(ToothView *)toothView
{
    if (!_toothView) {
        _toothView = [[ToothView alloc] initWithFrame:CGRectMake(100, 200, 50, 44)];
        _toothView.backgroundColor = [UIColor whiteColor];
    }
    return _toothView;
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

-(NSMutableDictionary *)imageInfoDict
{
    if (!_imageInfoDict) {
        _imageInfoDict = [[NSMutableDictionary alloc] init];
       
    }
    return _imageInfoDict;
}
@end
