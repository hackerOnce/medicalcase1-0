//
//  WLKTableView.h
//  MedImageReader
//
//  Created by ihefe36 on 14/12/29.
//  Copyright (c) 2014年 ihefe. All rights reserved.
//

#import "WLKView.h"

@interface WLKTableView : WLKView <UITableViewDelegate, UITableViewDataSource>
/**
 * tableview
 */
@property (strong, nonatomic) UITableView *tableView;
/**
 * 存放数据的数组，用于tableview的datasource
 */
@property (strong, nonatomic) NSMutableArray *dataArray;
/**
 * 下拉刷新控件
 */
@property (strong, nonatomic) UIRefreshControl *refreshControl;

/**
 * 建议在此方法内加载需要加载的数据，便于管理，若根据不同操作有后续的加载需求，可另写方法加载
 */
- (void)loadData;

/**
 * 下拉刷新触发的方法
 */
- (void)refreshTableView:(id)sender;

@end
