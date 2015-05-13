//
//  ShowTemplateTableViewCell.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/12.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "ShowTemplateTableViewCell.h"
@interface ShowTemplateTableViewCell()
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;

@end

@implementation ShowTemplateTableViewCell
- (IBAction)buttonsClicked:(UIButton *)sender
{
    if (sender == self.moreButton) {
        [self.delegate buttonDeleteActionClicked:sender];
    }else if(sender == self.deleteButton){
        [self.delegate buttonDeleteActionClicked:sender];
    }else if (sender == self.shareButton){
        [self.delegate buttonShareActionClicked:sender];
    }
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
