//
//  WLKMultiTableView.m
//  MedCase
//
//  Created by ihefe36 on 15/1/6.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import "WLKMultiTableView.h"
#import "WLKTableView.h"
#import "WLKCaseNodeTableView.h"
#import "KeyValueObserver.h"


#define SingleTableLeftMargin 200
#define SingleTableTopMargin 100
#define SingleTableBottomMargin 200

static NSString *kDidSelectedTableViewCell = @"kDidSelectedTableViewCell";

@interface WLKMultiTableView ()

@property (nonatomic,strong) id kNodeContentObserKey;

@end
@implementation WLKMultiTableView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self buildUI];
        //[self addObserver];
    }
    else
    {
        self = nil;
    }
    return self;
}
-(void)addObserver
{
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectedTableViewCell:) name:kDidSelectedTableViewCell object:nil];
   // [self.caseNode addObserver:self forKeyPath:@"nodeContent" options:NSKeyValueObservingOptionNew context:nil];
    
  //  self.kNodeContentObserKey = [KeyValueObserver observeObject:self.caseNode keyPath:@"nodeContent" target:self selector:@selector(nodeContentDidChange:) options:NSKeyValueObservingOptionInitial];
    
}
-(void)dealloc
{
   // [self.caseNode removeObserver:self forKeyPath:@"nodeContent"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
//{
//    NSLog(@"%@", change);
//    self.selectedStr = change[@"new"];
//}
//-(void)nodeContentDidChange:(NSDictionary *)change
//{
//    NSLog(@"%@", change);
//    self.selectedStr = change[@"new"];
//}
-(void)didSelectedTableViewCell:(NSNotification*)info
{
    self.selectedStr = self.caseNode.nodeContent;
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self buildUI];
    }
    else
    {
        self = nil;
    }
    return self;
}

- (NSMutableArray *)tableViews
{
    if (!_tableViews) {
        _tableViews = [NSMutableArray array];
    }
    return _tableViews;
}

- (void)clearSubviews
{
    [super clearSubviews];
    [self.tableViews removeAllObjects];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self updateTableViewsFrame];
}

- (void)updateTableViewsFrame
{
    NSInteger tableViewCount = self.caseNode.countOfChildNodesHierarchy;
    if (tableViewCount == 0) {
        return;
    }
    CGFloat width = (NSInteger)self.frame.size.width / tableViewCount;
    CGFloat height = self.frame.size.height;
    CGFloat y = 0;
    CGFloat baseX = 0;
    
    for (int i = 0; i < self.tableViews.count; i++) {
        CGRect rect = CGRectMake(baseX + i * width, y, width, height);
        [self.tableViews[i] setFrame:rect];
    }
}

- (void)setCaseNode:(WLKCaseNode *)caseNode
{
    if (![_caseNode isEqual:caseNode]) {
        _caseNode = caseNode;
        _caseNode.rootNode = _caseNode;
        [self buildUI];
    }
}

- (void)buildUI
{
    if (self.caseNode && self.caseNode.nodeType >= 0 && self.caseNode.countOfChildNodesHierarchy > 0) {
        //TODO: 此处应做复用处理，而不是清空
        [self clearSubviews];
        NSInteger tableViewCount = self.caseNode.countOfChildNodesHierarchy;
        WLKCaseNode *currentNode = self.caseNode;
        WLKCaseNodeTableView *lastTableView = nil;
        for (int i = 0; i < tableViewCount + 5; i++) {
            WLKCaseNodeTableView *tableView = [[WLKCaseNodeTableView alloc] initWithFrame:CGRectZero];
            tableView.caseNode = currentNode;
            lastTableView.nextTableView = tableView;
            lastTableView = tableView;
            
            if (currentNode.tableViewConfig) {
                tableView.tableViewConfig = currentNode.tableViewConfig;
            }
            
            [self.tableViews addObject:tableView];
            if(currentNode.childNodes.count){
                currentNode = currentNode.childNodes[0];
            }
            else
            {
                currentNode = nil;
            }
            [self addSubview:tableView];
        }
    }
    [self addObserver];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
