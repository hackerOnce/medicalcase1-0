//
//  ShowTemplateTableViewCell.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/12.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "ShowTemplateTableViewCell.h"
@interface ShowTemplateTableViewCell()<UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewRightConstraint;
@property (weak, nonatomic) IBOutlet UIView *myContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *templateTitleHeightConstraints;

@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;
@property (nonatomic, assign) CGPoint panStartPoint;
@property (nonatomic, assign) CGFloat startingRightLayoutConstraintConstant;
@property (weak, nonatomic) IBOutlet UILabel *templateTitleLabel;

@end

static CGFloat const kBounceValue = 20.0f;

@implementation ShowTemplateTableViewCell
- (IBAction)buttonsClicked:(UIButton *)sender
{
    if (sender == self.moreButton) {
        [self.delegate buttonDeleteActionClicked:sender withCell:self];
    }else if(sender == self.deleteButton){
        if ([sender.titleLabel.text isEqualToString:@"删除"]) {
            [self.delegate buttonDeleteActionClicked:sender withCell:self];
        }else if([sender.titleLabel.text isEqualToString:@"接收"]) {
            [self.delegate buttonAcceptActionClicked:sender withCell:self];
        }
    }else if (sender == self.shareButton){
        if ([sender.titleLabel.text isEqualToString:@"分享"]) {
            [self.delegate buttonShareActionClicked:sender withCell:self];
        }else if([sender.titleLabel.text isEqualToString:@"忽略"]) {
            [self.delegate buttonIgnoreActionClicked:sender withCell:self];
        }
    }
}

- (void)awakeFromNib {
    // Initialization code
    
    self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panThisCell:)];
    self.panRecognizer.delegate = self;
    [self.myContainerView addGestureRecognizer:self.panRecognizer];
   
    
   //接受到消息时 需设置
   // self.templateTitleLabel.hidden = YES;
   // self.templateTitleHeightConstraints.constant = -self.templateTitleHeightConstraints.constant;
    
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.isNewsPage) {
        self.templateTitleLabel.hidden = NO;
        if (self.templateTitleHeightConstraints.constant <= 0) {
            self.templateTitleHeightConstraints.constant = 21;
        }
    }else {
        self.templateTitleLabel.hidden = YES;
        
        self.templateTitleHeightConstraints.constant = 0;
    }
}
- (void)prepareForReuse
{
    [super prepareForReuse];
    [self resetConstraintContstantsToZero:NO notifyDelegateDidClose:NO];
}

- (void)openCell
{
    [self setConstraintsToShowAllButtons:NO notifyDelegateDidOpen:NO];
}

- (CGFloat)buttonTotalWidth
{
    if (self.isNewsPage) {
        [self.shareButton setTitle:@"忽略" forState:UIControlStateNormal];
        [self.deleteButton setTitle:@"接收" forState:UIControlStateNormal];
        [self.moreButton setTitle:@" " forState:UIControlStateNormal];
        self.moreButton.backgroundColor = [UIColor clearColor];
        return CGRectGetWidth(self.frame) - CGRectGetMinX(self.shareButton.frame);

    }else {
        [self.shareButton setTitle:@"分享" forState:UIControlStateNormal];
        [self.deleteButton setTitle:@"删除" forState:UIControlStateNormal];
        [self.moreButton setTitle:@"更多" forState:UIControlStateNormal];
        self.moreButton.backgroundColor = [UIColor darkGrayColor];
        return CGRectGetWidth(self.frame) - CGRectGetMinX(self.moreButton.frame);
    }
}

- (void)panThisCell:(UIPanGestureRecognizer *)recognizer
{
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            self.panStartPoint = [recognizer translationInView:self.myContainerView];
            self.startingRightLayoutConstraintConstant = self.contentViewRightConstraint.constant;
            
            break;
            
        case UIGestureRecognizerStateChanged: {
            CGPoint currentPoint = [recognizer translationInView:self.myContainerView];
            CGFloat deltaX = currentPoint.x - self.panStartPoint.x;
            BOOL panningLeft = NO;
            if (currentPoint.x < self.panStartPoint.x) {  //1
                panningLeft = YES;
            }
            
            if (self.startingRightLayoutConstraintConstant == 0) { //2
                //The cell was closed and is now opening
                if (!panningLeft) {
                    CGFloat constant = MAX(-deltaX, 0); //3
                    if (constant == 0) { //4
                        [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:NO]; //5
                    } else {
                        self.contentViewRightConstraint.constant = constant; //6
                    }
                } else {
                    CGFloat constant = MIN(-deltaX, [self buttonTotalWidth]); //7
                    if (constant == [self buttonTotalWidth]) { //8
                        [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:NO]; //9
                    } else {
                        self.contentViewRightConstraint.constant = constant; //10
                    }
                }
            }else {
                //The cell was at least partially open.
                CGFloat adjustment = self.startingRightLayoutConstraintConstant - deltaX; //11
                if (!panningLeft) {
                    CGFloat constant = MAX(adjustment, 0); //12
                    if (constant == 0) { //13
                        [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:NO]; //14
                    } else {
                        self.contentViewRightConstraint.constant = constant; //15
                    }
                } else {
                    CGFloat constant = MIN(adjustment, [self buttonTotalWidth]); //16
                    if (constant == [self buttonTotalWidth]) { //17
                        [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:NO]; //18
                    } else {
                        self.contentViewRightConstraint.constant = constant;//19
                    }
                }
            }
            
            self.contentViewLeftConstraint.constant = -self.contentViewRightConstraint.constant; //20
        }
            break;
            
        case UIGestureRecognizerStateEnded:
            if (self.startingRightLayoutConstraintConstant == 0) { //1
                //We were opening
                CGFloat halfOfButtonOne = CGRectGetWidth(self.deleteButton.frame) / 2; //2
                if (self.contentViewRightConstraint.constant >= halfOfButtonOne) { //3
                    //Open all the way
                    [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES];
                } else {
                    //Re-close
                    [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:YES];
                }
                
            } else {
                //We were closing
                CGFloat buttonOnePlusHalfOfButton2 = CGRectGetWidth(self.deleteButton.frame) + (CGRectGetWidth(self.shareButton.frame) / 2); //4
                
                if (self.contentViewRightConstraint.constant >= buttonOnePlusHalfOfButton2) { //5
                    //Re-open all the way
                    [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES];
                } else {
                    //Close
                    [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:YES];
                }
            }
            break;
            
        case UIGestureRecognizerStateCancelled:
            if (self.startingRightLayoutConstraintConstant == 0) {
                //We were closed - reset everything to 0
                [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:YES];
            } else {
                //We were open - reset to the open state
                [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES];
            }
            break;
            
        default:
            break;
    }
}

- (void)updateConstraintsIfNeeded:(BOOL)animated completion:(void (^)(BOOL finished))completion;
{
    float duration = 0;
    if (animated) {
        NSLog(@"Animated!");
        duration = 0.1;
    }
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self layoutIfNeeded];
    } completion:completion];
}


- (void)resetConstraintContstantsToZero:(BOOL)animated notifyDelegateDidClose:(BOOL)notifyDelegate
{
    if (notifyDelegate) {
        [self.delegate cellDidClose:self];
    }
    
    if (self.startingRightLayoutConstraintConstant == 0 &&
        self.contentViewRightConstraint.constant == 0) {
        //Already all the way closed, no bounce necessary
        return;
    }
    
    self.contentViewRightConstraint.constant = -kBounceValue;
    self.contentViewLeftConstraint.constant = kBounceValue;
    
    [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
        self.contentViewRightConstraint.constant = 0;
        self.contentViewLeftConstraint.constant = 0;
        
        [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
            self.startingRightLayoutConstraintConstant = self.contentViewRightConstraint.constant;
        }];
    }];
}


- (void)setConstraintsToShowAllButtons:(BOOL)animated notifyDelegateDidOpen:(BOOL)notifyDelegate
{
    if (notifyDelegate) {
        [self.delegate cellDidOpen:self];
    }
    
    if (self.startingRightLayoutConstraintConstant == [self buttonTotalWidth] &&
        self.contentViewRightConstraint.constant == [self buttonTotalWidth]) {
        return;
    }
    self.contentViewLeftConstraint.constant = -[self buttonTotalWidth] - kBounceValue;
    self.contentViewRightConstraint.constant = [self buttonTotalWidth] + kBounceValue;
    
    [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
        self.contentViewLeftConstraint.constant = -[self buttonTotalWidth];
        self.contentViewRightConstraint.constant = [self buttonTotalWidth];
        
        [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
            self.startingRightLayoutConstraintConstant = self.contentViewRightConstraint.constant;
        }];
    }];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end
