//
//  WLKCaseNodeTableView.m
//  MedCase
//
//  Created by ihefe36 on 15/1/6.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import "WLKCaseNodeTableView.h"

#define lineWidth 0.5

static NSString *kDidSelectedTableViewCell = @"kDidSelectedTableViewCell";
@implementation WLKCaseNodeTableView
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
//        self.tableView.ac
        self.isFirstLoadFirstCell = YES;
//        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8")) {
//            self.tableView.estimatedRowHeight = 44;
//        }
        [self.tableView registerClass:[WLKCaseNodeCell class] forCellReuseIdentifier:@"WLKCaseNodeCell"];
        [[NSNotificationCenter defaultCenter] addObserver:self.tableView selector:@selector(reloadData) name:nShouldReloadNodeTableView object:nil];
//        [self.tableView registerNib:[UINib nibWithNibName:@"WLKCaseNodeCell" bundle:nil] forCellReuseIdentifier:@"WLKCaseNodeCell"];
    }
    else
    {
        self = nil;
    }
    return self;
}

- (void)test
{
    
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    CGRect rect = self.frame;
    CGRect tableFrame = self.tableView.frame;
    if (self.tableViewConfig.shouldAddVerticalSeparatorLine) {
        self.tableView.frame = CGRectMake(0, tableFrame.origin.y, rect.size.width - lineWidth, rect.size.height - tableFrame.origin.y);
        self.separatorView.frame = CGRectMake(rect.size.width - lineWidth, 0, lineWidth, rect.size.height);
//        NSLog(@"-------%@", NSStringFromCGSize(self.tableView.frame.size));
//        NSLog(@"=======%@, %@", NSStringFromCGSize(self.frame.size), NSStringFromCGRect(self.separatorView.frame));
        
    }
    else
    {
        self.tableView.frame = CGRectMake(tableFrame.origin.x, tableFrame.origin.y, rect.size.width - tableFrame.origin.x, rect.size.height - tableFrame.origin.y);
    }
}

- (void)setTableViewConfig:(WLKCaseNodeTableViewConfig *)tableViewConfig
{
    static int tag = 0;
    if (![tableViewConfig isEqual:_tableViewConfig]) {
        _tableViewConfig = tableViewConfig;
        [self buildUI];
        NSLog(@"+++++%d", tag++);
    }
}

- (void)buildUI
{
    if (self.tableViewConfig.shouldAddVerticalSeparatorLine) {
        
        if (!self.separatorView) {
            self.separatorView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width - lineWidth, 0, lineWidth, self.frame.size.height)];
            self.separatorView.backgroundColor = [UIColor lightGrayColor];
            [self addSubview:self.separatorView];
        }
        
        CGRect rect = self.tableView.frame;
        rect.size.width = self.frame.size.width - lineWidth;
        self.tableView.frame = rect;
    }
    self.tableView.separatorInset = UIEdgeInsetsMake(self.tableView.separatorInset.top, self.tableViewConfig.cellSeparatorLeftMargin, self.tableView.separatorInset.bottom, self.tableViewConfig.cellSeparatorRightMargin);
    if (!self.tableViewConfig.cellSeparatorShouldShow) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    self.tableView.allowsMultipleSelection = self.tableViewConfig.allowMultiSelected;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
}

- (void)setCaseNode:(WLKCaseNode *)caseNode
{
    if (caseNode && ![_caseNode isEqual:caseNode]) {
        _caseNode = caseNode;
        [self.tableView reloadData];
        if (self.nextTableView) {
            
            if (self.caseNode.selectedChildNodes.count == 0) {
                if (_caseNode.childNodes.count > 0) {
                    self.nextTableView.caseNode = _caseNode.childNodes[0];
                }
                else
                {
                    self.nextTableView.caseNode = nil;
                }
            }
            else
            {
                self.nextTableView.caseNode = _caseNode.selectedChildNodes[0];
            }
        }
        self.hidden = NO;
        self.tableViewConfig = caseNode.tableViewConfig;
    }
    if (!caseNode) {
        _caseNode = nil;
        self.nextTableView.caseNode = nil;
        self.hidden = YES;
        [self.tableView reloadData];
    }
}

- (void)shouldSelectFirstCellDefault
{
    if (self.tableViewConfig.shouldSelectFirstCellDefault && self.caseNode.selectedChildNodes.count == 0) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
    }
}

- (void)setNextTableView:(WLKCaseNodeTableView *)nextTableView
{
    if (nextTableView) {
        _nextTableView = nextTableView;
        self.tableView.allowsMultipleSelection = YES;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.caseNode.childNodes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WLKCaseNodeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WLKCaseNodeCell"];
    WLKCaseNode *node = self.caseNode.childNodes[indexPath.row];
    cell.caseNode = node;
    if (self.caseNode.tableViewConfig) {
        WLKCaseNodeTableViewConfig *config = self.caseNode.tableViewConfig;
        cell.tableViewConfig = config;
    }
    if (indexPath.row != 0) {
//        [self shouldSelectFirstCellDefault];
    }
   
    if ([self.caseNode.selectedChildNodes containsObject:node]) {
        [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        cell.accessoryType = self.caseNode.tableViewConfig.selectedAccessoryType;
    }
    else
    {
        cell.accessoryType = self.caseNode.tableViewConfig.normalAccessoryType;
    }
//    NSLog(@"%@", cell.textLabel.font);
    cell.superTableView = self.tableView;
    return cell;
}

//#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_8_0
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"%@", testtttttt);
    NSString *string = [self.caseNode.childNodes[indexPath.row] nodeContent];
    return [string boundingRectWithSize:CGSizeMake(self.frame.size.width, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18]} context:nil].size.height + 24;
}
//#endif

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.caseNode selectChildNode:self.caseNode.childNodes[indexPath.row]];
    NSLog(@"%@", [self.caseNode.childNodes[indexPath.row] childNodes]);
    if (self.nextTableView) {
        self.nextTableView.caseNode = self.caseNode.childNodes[indexPath.row];
    }
    else
    {
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = self.caseNode.tableViewConfig.selectedAccessoryType;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectedTableViewCell object:nil];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.caseNode.tableViewConfig) {
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = self.caseNode.tableViewConfig.normalAccessoryType;
    }
    else
    {
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
    }
    [self.caseNode deselectChildNode:self.caseNode.childNodes[indexPath.row]];
    self.nextTableView.caseNode = self.caseNode.selectedChildNodes.firstObject;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectedTableViewCell object:nil];
}

@end
