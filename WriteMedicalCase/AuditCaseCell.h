//
//  AuditCaseCell.h
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/28.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AuditCaseCellDelegate;

@interface AuditCaseCell : UITableViewCell

@property (weak,nonatomic) id <AuditCaseCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@end

@protocol AuditCaseCellDelegate <NSObject>

-(void)textViewCell:(AuditCaseCell*)cell didChangeText:(NSString*)text;
-(void)textViewDidBeginEditing:(UITextView*)textView withCellIndexPath:(NSIndexPath*)indexPath;
@end
