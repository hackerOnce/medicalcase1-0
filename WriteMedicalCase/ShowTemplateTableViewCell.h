//
//  ShowTemplateTableViewCell.h
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/12.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ShowTemplateTableViewCell;

@protocol ShowTemplateTableViewCellDelegate <NSObject>

-(void)buttonMoreActionClicked:(UIButton*)sender withCell:(ShowTemplateTableViewCell*)cell;
-(void)buttonShareActionClicked:(UIButton*)sender withCell:(ShowTemplateTableViewCell*)cell ;
-(void)buttonDeleteActionClicked:(UIButton*)sender withCell:(ShowTemplateTableViewCell*)cell;

-(void)buttonIgnoreActionClicked:(UIButton*)sender withCell:(ShowTemplateTableViewCell*)cell;
-(void)buttonAcceptActionClicked:(UIButton*)sender withCell:(ShowTemplateTableViewCell*)cell;
-(void)buttonCancellationOfShareActionClicked:(UIButton*)sender withCell:(ShowTemplateTableViewCell*)cell;

- (void)cellDidOpen:(UITableViewCell *)cell;
- (void)cellDidClose:(UITableViewCell *)cell;


@end
@interface ShowTemplateTableViewCell : UITableViewCell

- (void)openCell;

@property (nonatomic,weak) id<ShowTemplateTableViewCellDelegate> delegate;
@property (nonatomic) BOOL isNewsPage;
@property (nonatomic) BOOL isShareTemplate;
@property (nonatomic,strong) TemplateModel *templateModel;
@end
