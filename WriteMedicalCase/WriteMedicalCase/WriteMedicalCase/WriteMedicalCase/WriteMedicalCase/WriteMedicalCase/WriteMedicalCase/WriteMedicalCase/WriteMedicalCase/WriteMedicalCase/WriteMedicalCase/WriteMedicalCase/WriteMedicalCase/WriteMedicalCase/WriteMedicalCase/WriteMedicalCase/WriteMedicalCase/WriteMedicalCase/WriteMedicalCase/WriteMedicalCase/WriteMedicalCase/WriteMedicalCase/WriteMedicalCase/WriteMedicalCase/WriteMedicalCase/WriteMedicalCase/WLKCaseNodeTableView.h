//
//  WLKCaseNodeTableView.h
//  MedCase
//
//  Created by ihefe36 on 15/1/6.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import "WLKTableView.h"

@interface WLKCaseNodeTableView : WLKTableView
@property (strong, nonatomic) WLKCaseNode *caseNode;
@property (weak, nonatomic) WLKCaseNodeTableView *nextTableView;
@property (strong, nonatomic) WLKCaseNodeTableViewConfig *tableViewConfig;
@property (strong, nonatomic) UIView *separatorView;
@property (assign, nonatomic) BOOL isFirstLoadFirstCell;
@end
