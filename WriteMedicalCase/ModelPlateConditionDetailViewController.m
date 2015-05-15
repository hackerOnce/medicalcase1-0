//
//  ModelPlateConditionDetailViewController.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/15.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "ModelPlateConditionDetailViewController.h"
#import "IHMsgSocket.h"
#import "MessageObject+DY.h"

@interface ModelPlateConditionDetailViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic) BOOL isHideSearchBar;
@property (nonatomic,strong) IHMsgSocket *socket;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchBarHeightConstraints;

@end

@implementation ModelPlateConditionDetailViewController
#pragma mask - socket
-(IHMsgSocket *)socket
{
    if (!_socket) {
        _socket = [IHMsgSocket sharedRequest];
        [_socket connectToHost:@"192.168.10.106" onPort:2323];
    }
    return _socket;
}

#pragma mask - view life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

#pragma mask -table view data source


@end
