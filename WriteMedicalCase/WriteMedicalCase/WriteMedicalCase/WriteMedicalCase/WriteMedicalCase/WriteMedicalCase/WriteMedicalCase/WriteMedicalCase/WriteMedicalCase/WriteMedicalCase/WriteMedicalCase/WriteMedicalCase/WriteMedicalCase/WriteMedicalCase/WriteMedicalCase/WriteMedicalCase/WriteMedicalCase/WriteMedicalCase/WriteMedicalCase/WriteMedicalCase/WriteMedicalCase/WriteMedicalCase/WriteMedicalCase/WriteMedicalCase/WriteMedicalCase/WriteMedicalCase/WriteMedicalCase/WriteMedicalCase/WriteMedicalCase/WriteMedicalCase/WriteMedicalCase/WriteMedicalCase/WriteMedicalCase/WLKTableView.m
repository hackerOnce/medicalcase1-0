//
//  WLKTableView.m
//  MedImageReader
//
//  Created by ihefe36 on 14/12/29.
//  Copyright (c) 2014年 ihefe. All rights reserved.
//

#import "WLKTableView.h"

@implementation WLKTableView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStylePlain];
        self.tableView = tableView;
    }
    else
    {
        self = nil;
    }
    return self;
}

- (void)setTableView:(UITableView *)tableView
{
    if (tableView) {
        _tableView = tableView;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"WLKCommonCell"];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        CGRect rect = _tableView.frame;
        rect.origin = CGPointZero;
        rect.size.height = 0;
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:rect];
        [self addSubview:_tableView];
//        _tableView.frame = self.bounds;
    }
}

- (NSMutableArray *)dataArray
{
    if (_dataArray) {
        return _dataArray;
    }
    _dataArray = [NSMutableArray array];
    return _dataArray;
}

- (UIRefreshControl *)refreshControl
{
#warning 效果待验证
    if (_refreshControl) {
        return _refreshControl;
    }
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self action:@selector(refreshTableView:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refreshControl];
    return _refreshControl;
}

- (void)refreshTableView:(id)sender
{
    NSLog(@"wlk table view %@", NSStringFromSelector(_cmd));
}

- (void)loadData
{
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[UITableViewCell alloc] init];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
