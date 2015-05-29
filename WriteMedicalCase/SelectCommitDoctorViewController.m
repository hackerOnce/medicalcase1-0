//
//  SelectCommitDoctorViewController.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/20.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "SelectCommitDoctorViewController.h"
#import "TempDoctor.h"

@interface SelectCommitDoctorViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@property (nonatomic,strong) NSMutableArray *doctorArray;

@property (nonatomic,strong) IHMsgSocket *socket;
@end

@implementation SelectCommitDoctorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *dID = [TempDoctor setSharedDoctorWithDict:nil].dID;
    
    [MessageObject messageObjectWithUsrStr:@"1" pwdStr:@"test" iHMsgSocket:self.socket optInt:2007 dictionary:@{@"did":dID} block:^(IHSockRequest *request) {
        
        if ([request.responseData isKindOfClass:[NSArray class]]) {
            NSArray *doctorArray = (NSArray*)request.responseData;
            for (NSDictionary *doctorDict in doctorArray) {
                TempDoctor *tempDoctor = [[TempDoctor alloc] initWithTempDoctorDic:doctorDict];
                [self.doctorArray addObject:tempDoctor];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            self.spinner.hidden = YES;
        });
        
    } failConection:^(NSError *error) {
        self.spinner.hidden = YES;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"服务器端出错" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
        [alert show];
    }];
}

-(NSMutableArray *)doctorArray
{
    if (!_doctorArray) {
        _doctorArray = [[NSMutableArray alloc] init];
    }
    return _doctorArray;
}
#pragma mask - socket
-(IHMsgSocket *)socket
{
    if (!_socket) {
        _socket = [IHMsgSocket sharedRequest];
        if (![[_socket IHGCDSocket].asyncSocket isConnected]) {
            [_socket connectToHost:@"192.168.10.106" onPort:2323];
        }
    }
    return _socket;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   return self.doctorArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"doctorCell"];
    
    TempDoctor *doctor = [self.doctorArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = doctor.dName;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TempDoctor *doctor = [self.doctorArray objectAtIndex:indexPath.row];
    [self.delegate didSelectedDoctor:doctor];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
