//
//  RecordManagedCellTableViewCell.m
//  MedicalCase
//
//  Created by ihefe-JF on 15/4/24.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import "RecordManagedCellTableViewCell.h"

@implementation RecordManagedCellTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    [self.cellButton addTarget:self action:@selector(didSelectedCellButton:) forControlEvents:UIControlEventTouchUpInside];
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
   self =  [super initWithCoder:aDecoder];
    
    [self.cellButton addTarget:self action:@selector(didSelectedCellButton:) forControlEvents:UIControlEventTouchUpInside];
    
    
   return self;
}
-(void)didSelectedCellButton:(UIButton*)button
{
    if ([self.delegate respondsToSelector:@selector(didSelectedCellButton:inCell:)]) {
        [self.delegate didSelectedCellButton:button inCell:self];
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
