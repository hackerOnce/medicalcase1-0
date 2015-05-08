//
//  ShowAllTemplateCell.h
//  MedicalCase
//
//  Created by ihefe-JF on 15/4/14.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  ShowAllTemplateCellDelegate;


@interface ShowAllTemplateCell : UITableViewCell<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *conditionTextView;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (nonatomic,weak) id<ShowAllTemplateCellDelegate> showAllTemplateDelegate;
@end

@protocol  ShowAllTemplateCellDelegate<NSObject>

-(void)showAllTemplateCell:(ShowAllTemplateCell*)cell didChangeText:(NSString*)text withTextView:(UITextView*)textVIew;
-(void)textViewDidBeginEditing:(UITextView *)textView withCellIndexPath:(NSIndexPath *)indexPath;

@end
