//
//  WriteCaseShowTemplateCell.h
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/4/30.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RWLabel.h"

@protocol WriteCaseShowTemplateCellDelegate;

@interface WriteCaseShowTemplateCell : UITableViewCell

@property (weak, nonatomic) IBOutlet RWLabel *contentLabel;
@property (weak, nonatomic) IBOutlet RWLabel *createPeopleLabel;
@property (weak, nonatomic) IBOutlet RWLabel *sourcelabel;

@property (nonatomic,weak) id <WriteCaseShowTemplateCellDelegate> delegate;

@end
@protocol WriteCaseShowTemplateCellDelegate <NSObject>

@required
-(void)textViewCell:(WriteCaseShowTemplateCell*)cell didChangeText:(NSString*)text;
-(void)textViewDidBeginEditing:(UITextView*)textView withCellIndexPath:(NSIndexPath*)indexPath;

@end
