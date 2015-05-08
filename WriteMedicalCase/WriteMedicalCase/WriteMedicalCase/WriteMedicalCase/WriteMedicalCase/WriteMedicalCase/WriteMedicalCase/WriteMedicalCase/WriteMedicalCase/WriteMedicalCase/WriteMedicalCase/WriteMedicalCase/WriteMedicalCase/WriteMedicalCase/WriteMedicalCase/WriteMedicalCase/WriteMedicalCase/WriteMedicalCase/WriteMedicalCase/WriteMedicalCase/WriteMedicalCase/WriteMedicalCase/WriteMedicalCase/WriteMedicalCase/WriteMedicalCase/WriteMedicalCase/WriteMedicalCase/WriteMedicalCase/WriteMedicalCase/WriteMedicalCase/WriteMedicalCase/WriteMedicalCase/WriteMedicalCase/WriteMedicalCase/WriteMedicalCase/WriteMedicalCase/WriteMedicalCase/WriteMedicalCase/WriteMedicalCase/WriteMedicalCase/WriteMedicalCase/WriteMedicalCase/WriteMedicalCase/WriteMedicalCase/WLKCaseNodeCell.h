//
//  WLKCaseNodeCell.h
//  MedCase
//
//  Created by ihefe36 on 15/1/7.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WLKCaseNodeCell : UITableViewCell
@property (strong, nonatomic) WLKCaseNodeTableViewConfig *tableViewConfig;
@property (strong, nonatomic) WLKCaseNode *caseNode;
@property (weak, nonatomic) UITableView *superTableView;
@end
