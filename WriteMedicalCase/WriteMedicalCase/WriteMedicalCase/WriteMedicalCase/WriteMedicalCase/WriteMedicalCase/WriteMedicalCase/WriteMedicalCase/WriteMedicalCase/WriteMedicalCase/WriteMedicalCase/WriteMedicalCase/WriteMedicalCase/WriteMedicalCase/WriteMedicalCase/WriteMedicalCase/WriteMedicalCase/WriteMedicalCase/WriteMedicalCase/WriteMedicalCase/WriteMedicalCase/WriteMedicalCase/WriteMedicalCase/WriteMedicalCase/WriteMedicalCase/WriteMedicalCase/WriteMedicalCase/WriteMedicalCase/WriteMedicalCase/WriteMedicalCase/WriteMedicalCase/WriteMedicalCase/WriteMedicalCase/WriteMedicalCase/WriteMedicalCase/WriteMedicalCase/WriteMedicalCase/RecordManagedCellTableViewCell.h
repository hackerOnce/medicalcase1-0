//
//  RecordManagedCellTableViewCell.h
//  MedicalCase
//
//  Created by ihefe-JF on 15/4/24.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RecordManagedCellTableViewCell;
@protocol RecordManagedCellTableViewCellDelegate <NSObject>

-(void)didSelectedCellButton:(UIButton*)button inCell:(RecordManagedCellTableViewCell*)cell;

@end

@interface RecordManagedCellTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *remainTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *caseTypeLabel;
@property (weak, nonatomic) IBOutlet UIButton *cellButton;

@property (nonatomic,weak) id <RecordManagedCellTableViewCellDelegate> delegate;
@end
