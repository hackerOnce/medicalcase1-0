//
//  WLKMultiTableView.h
//  MedCase
//
//  Created by ihefe36 on 15/1/6.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import "WLKView.h"

@interface WLKMultiTableView : WLKView
@property (strong, nonatomic) WLKCaseNode *caseNode;

@property (strong, nonatomic) NSString *selectedStr;
/**
 * tableview数组
 */
@property (strong, nonatomic) NSMutableArray *tableViews;

- (void)buildUI;

@end
