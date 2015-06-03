//
//  SelectedShareRangeViewController.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/14.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "SelectedShareRangeViewController.h"
#import "SelectedDoctorViewController.h"

@interface SelectedShareRangeViewController ()<UITableViewDataSource,UITableViewDelegate,SelectedDoctorViewControllerDelegate>
@property (nonatomic,strong) NSArray *dataArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property(nonatomic,strong) NSString *sharedStyle;
@end

@implementation SelectedShareRangeViewController
-(NSArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = @[@"个人分享",@"科室分享",@"全院分享"];
    }
   return _dataArray;
}


-(NSMutableArray *)selectedTemplates
{
    if (!_selectedTemplates) {
        _selectedTemplates = [[NSMutableArray alloc] init];
    }
    return _selectedTemplates;
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
    NSString *selectedStr = [self.dataArray objectAtIndex:indexPath.row];
    self.sharedStyle = selectedStr;
    
    [self performSegueWithIdentifier:@"showDoctorSegue" sender:nil];
}
#pragma mask -SelectedDoctorViewControllerDelegate
-(void)didSelectedDoctor:(NSDictionary *)sharedUser
{
    [self.delegate didSelectedSharedUsers:sharedUser];

}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showDoctorSegue"]) {
        
        SelectedDoctorViewController *selectedDoctor = (SelectedDoctorViewController*)segue.destinationViewController;
        selectedDoctor.selectedTemplates = [NSMutableArray arrayWithArray:self.selectedTemplates];
        selectedDoctor.selectedSharedStyle =[NSString stringWithFormat:@"%@",self.sharedStyle];
        selectedDoctor.delegate = self;
        selectedDoctor.isForOthers = self.isForOthers;
        
    }
}

@end
