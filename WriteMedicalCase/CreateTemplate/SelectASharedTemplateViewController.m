//
//  SelectASharedTemplateViewController.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/13.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "SelectASharedTemplateViewController.h"
#import "SelectedASharedTemplateTableViewCell.h"

@interface SelectASharedTemplateViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation SelectASharedTemplateViewController
- (IBAction)cancelButtonClicked:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpTableView];
}
-(void)setUpTableView
{
    [self.tableView setEditing:YES animated:NO];
}

#pragma mask - tableView delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SelectedASharedTemplateTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SelectASharedTemplateCell"];
    
//    cell.accessoryType = UITableViewCellAccessoryDetailButton;
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}
-(void)configureCell:(SelectedASharedTemplateTableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    NSString *contentStr = @"我是一个放暑假我是一个放暑假我是一个放暑假我是一个放暑假我是一个放暑我是一个放暑假我是一个放暑假我是一个放暑假我是一个放暑假我是一个放暑假假我是一个放暑假我是一个放暑假我是一个放暑假";
    NSString *content;
    if (contentStr.length > 100) {
        content = [NSString stringWithFormat:@"%@...", [contentStr substringToIndex:100]];
    }else {
        content = contentStr;
    }
    cell.conditionLabel.text = @"性别男我是一个放暑假我是一个放暑假我是一个放暑假我是一个放暑假我是一个放暑我是一个放暑假性别男性别男性别男性别男性别男";
    cell.contentLabel.text = content;
    
   // [cell setEditing:YES animated:NO];
    [cell setEditingAccessoryType:UITableViewCellAccessoryDetailButton];
}
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert ;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self heightForBasicCellAtIndexPath:indexPath];
}
- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath {
    static SelectedASharedTemplateTableViewCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [self.tableView dequeueReusableCellWithIdentifier:@"SelectASharedTemplateCell"];
    });
    
    [self configureCell:sizingCell atIndexPath:indexPath];
    return [self calculateHeightForConfiguredSizingCell:sizingCell];
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell {
    
    sizingCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.frame), CGRectGetHeight(sizingCell.bounds));
    
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height + 1.0f; // Add 1.0f for the cell separator height
}
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    

}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"shareDetailSegue" sender:nil];
}


#pragma mask - search bar 

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    if ([searchBar isFirstResponder]) {
        [searchBar resignFirstResponder];
    }
    searchBar.text = @"";
    //self.searchText = @"";
    [self.searchBar setShowsCancelButton:NO animated:YES];
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if ([searchBar isFirstResponder]) {
        [searchBar resignFirstResponder];
    }

}
-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    [self.searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
