//
//  WriteCaseSaveCell.h
//  WriteMedicalCase
//
//  Created by GK on 15/4/29.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WriteCaseSaveCellDelegate;

@interface WriteCaseSaveCell : UITableViewCell
@property (weak,nonatomic) id <WriteCaseSaveCellDelegate> textViewDelegate;

@end

@protocol WriteCaseSaveCellDelegate <NSObject>

@required
-(void)textViewCell:(WriteCaseSaveCell*)cell didChangeText:(NSString*)text;
-(void)textViewDidBeginEditing:(UITextView*)textView withCellIndexPath:(NSIndexPath*)indexPath;

@end
