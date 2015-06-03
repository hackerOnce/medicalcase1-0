//
//  SelectedASharedTemplateTableViewCell.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/13.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "SelectedASharedTemplateTableViewCell.h"
@interface SelectedASharedTemplateTableViewCell()
@property (weak, nonatomic) IBOutlet UIView *selectedState;


@end
@implementation SelectedASharedTemplateTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
}
-(void)setUpStateView
{
    self.selectedState.layer.cornerRadius = self.selectedState.frame.size.width/2;
    self.selectedState.layer.backgroundColor = [UIColor darkGrayColor].CGColor;
    
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    
    [self setUpStateView];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
