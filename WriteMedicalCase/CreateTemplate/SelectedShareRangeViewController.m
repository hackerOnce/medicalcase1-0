//
//  SelectedShareRangeViewController.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/14.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "SelectedShareRangeViewController.h"
#import "SelectedDoctorViewController.h"

@interface SelectedShareRangeViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) NSArray *dataArray;
@end

@implementation SelectedShareRangeViewController
-(NSArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = @[@"个人分享",@"科室分享",@"全院分享"];
    }
   return _dataArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.preferredContentSize = CGSizeMake(300, 300);

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SharedRangeCell"];
    
    cell.textLabel.text = [self.dataArray objectAtIndex:indexPath.row];
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"showDoctorSegue" sender:nil];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showDoctorSegue"]) {
        
    }
}

@end
