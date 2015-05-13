//
//  ShowAllTemplateCell.h
//  MedicalCase
//
//  Created by ihefe-JF on 15/4/14.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  ShowAllTemplateCellDelegate;


@interface ShowAllTemplateCell : UITableViewCell<UITextViewDelegate,UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UITextView *conditionTextView;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewRightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewLeftConstraint;
@property (nonatomic,weak) id<ShowAllTemplateCellDelegate> showAllTemplateDelegate;
@property (weak, nonatomic) IBOutlet UIView *myContainerView;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

@property (nonatomic,strong) UIPanGestureRecognizer *panRecognizer;
@property (nonatomic) CGPoint panStartPoint;
@property (nonatomic) CGFloat startingRightLayoutConstraintConstant;
- (void)openCell;

@end

@protocol  ShowAllTemplateCellDelegate<NSObject>

//-(void)buttonMoreActionClicked:(UIButton*)sender;
//-(void)buttonShareActionClicked:(UIButton*)sender;
//-(void)buttonDeleteActionClicked:(UIButton*)sender;


-(void)showAllTemplateCell:(ShowAllTemplateCell*)cell didChangeText:(NSString*)text withTextView:(UITextView*)textVIew;
-(void)textViewDidBeginEditing:(UITextView *)textView withCellIndexPath:(NSIndexPath *)indexPath;

- (void)cellDidOpen:(UITableViewCell *)cell;
- (void)cellDidClose:(UITableViewCell *)cell;
@end
