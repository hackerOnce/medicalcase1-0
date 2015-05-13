//
//  ShowTemplateTableViewCell.h
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/12.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ShowTemplateTableViewCellDelegate <NSObject>

-(void)buttonMoreActionClicked:(UIButton*)sender;
-(void)buttonShareActionClicked:(UIButton*)sender;
-(void)buttonDeleteActionClicked:(UIButton*)sender;


@end
@interface ShowTemplateTableViewCell : UITableViewCell

@property (nonatomic,weak) id<ShowTemplateTableViewCellDelegate> delegate;

@end
