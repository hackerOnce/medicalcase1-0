//
//  RecordNoteCreateCellTableViewCell.h
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/6/2.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  RecordNoteCreateCellTableViewCellDelegate;

@interface RecordNoteCreateCellTableViewCell : UITableViewCell<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeightConstraints;
@property (weak,nonatomic) id <RecordNoteCreateCellTableViewCellDelegate> delegate;
@property (nonatomic) NSInteger mediaCount;
@end

@protocol RecordNoteCreateCellTableViewCellDelegate <NSObject>

-(void)textViewCell:(RecordNoteCreateCellTableViewCell*)cell didChangeText:(NSString*)text;
-(void)textViewDidBeginEditing:(UITextView*)textView withCellIndexPath:(NSIndexPath*)indexPath;
-(void)textViewShouldBeginEditing:(UITextView*)textView withCellIndexPath:(NSIndexPath*)indexPath;
@end