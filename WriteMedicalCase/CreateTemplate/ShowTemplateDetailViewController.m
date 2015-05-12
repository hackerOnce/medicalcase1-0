//
//  ShowTemplateDetailViewController.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/12.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "ShowTemplateDetailViewController.h"

@interface ShowTemplateDetailViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ShowTemplateDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"模板概览";
    
    [self setUptableView];
}

-(void)setUptableView
{
    self.tableView.tableFooterView = [[UIView alloc] init];
    //self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
}

#pragma mask - table data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3+2;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *conditionCellID = @"ConditionCell";
    NSString *contentCellID = @"ContentCell";
    NSString *otherCellID = @"OtherCell";
    
    UITableViewCell *cell;
    if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:conditionCellID];
       // cell.se
        [self configConditionCell:cell atIndexPath:indexPath];
        //cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, cell.bounds.size.width);
    }else if(indexPath.row == 4) {///最后一个cell
        cell = [tableView dequeueReusableCellWithIdentifier:otherCellID];
        [self configOtherCell:cell atIndexPath:indexPath];
        //cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, cell.bounds.size.width);
        
    }else {
        cell = [tableView dequeueReusableCellWithIdentifier:contentCellID];
        [self configContentCell:cell atIndexPath:indexPath];
        cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width+16, 0, 0);

    }
    return cell;
}
-(void)configConditionCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    UILabel *conditionLabel = (UILabel*)[cell viewWithTag:1001];
    conditionLabel.text = @"性别男，心内科，性别男，心内科性别男，心内科性别男，心内科性别男，心内科性别男，心内科，性别男，心内科性别男，心内科性别男，心内科性别男，心内科性别男，心内科，性别男，心内科性别男，心内科性别男，心内科性别男，心内科性别男，心内科，性别男，心内科性别男，心内科性别男，心内科性别男，心内科性别男，心内科，性别男，心内科性别男，心内科性别男，心内科性别男，心内科性别男，心内科，性别男，心内科性别男，心内科性别男，心内科性别";
}
-(void)configContentCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    UILabel *titleLabel = (UILabel*)[cell viewWithTag:1001];
    UILabel *contentLabel = (UILabel*)[cell viewWithTag:1002];
    
    titleLabel.text = @"住宿";
    contentLabel.text = @"性别男，心内科，性别男，心内科性别男，心内科性别男，心内科性别男，心内科性别男，心内科，性别男，心内科性别男，心内科性别男，心内科性别男，心内科性别男，心内科，性别男，心内科性别男，心内科性别男，心内科性别男，心内科性别男，心内科，性别男，心内科性别男，心内科性别男，心内科性别男，心内科性别男，心内科，性别男，心内科性别男，心内科性别男，心内科性别男，心内科性别男，心内科，性别男，心内科性别男，心内科性别男，心内科性别男，心内科";

}
-(void)configOtherCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    UILabel *createLabel = (UILabel*)[cell viewWithTag:1001];
    UILabel *sourceLabel = (UILabel*)[cell viewWithTag:1002];

    createLabel.text = @"创建人:王刚";
    sourceLabel.text = @"来源: 个人分享";
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 || indexPath.row == 4) {
        
    }else {
        cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width+16, 0, 0);

    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self heightForBasicCellAtIndexPath:indexPath];
}
- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath {
    static UITableViewCell *sizingCell = nil;
    if (indexPath.row == 0) {
            sizingCell = [self.tableView dequeueReusableCellWithIdentifier:@"ConditionCell"];
            [self configConditionCell:sizingCell atIndexPath:indexPath];
        }else if(indexPath.row == 4) {/// cell 最后一行
            sizingCell = [self.tableView dequeueReusableCellWithIdentifier:@"OtherCell"];
            [self configOtherCell:sizingCell atIndexPath:indexPath];
        }else {
            sizingCell = [self.tableView dequeueReusableCellWithIdentifier:@"ContentCell"];
            [self configContentCell:sizingCell atIndexPath:indexPath];
           // sizingCell.separatorInset = UIEdgeInsetsMake(0, 16, 0, sizingCell.bounds.size.width);

        }
    
    return [self calculateHeightForConfiguredSizingCell:sizingCell];
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell {
    
    sizingCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.frame), CGRectGetHeight(sizingCell.bounds));
    
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    if (size.height < 43) {
        size.height = 43;
    }
    return size.height + 1.0f; // Add 1.0f for the cell separator height
}
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
}

@end
