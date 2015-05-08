//
//  WLKCaseNodeself.m
//  MedCase
//
//  Created by ihefe36 on 15/1/7.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import "WLKCaseNodeCell.h"
#import "WLKCaseNodeTableViewConfig.h"
#import "KeyValueObserver.h"

@implementation WLKCaseNodeCell
- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setTableViewConfig:(WLKCaseNodeTableViewConfig *)tableViewConfig
{
    if (![_tableViewConfig isEqual:tableViewConfig]) {
        _tableViewConfig = tableViewConfig;
        self.accessoryType = tableViewConfig.normalAccessoryType;
        self.selectedBackgroundView = tableViewConfig.cellSelectedBackgroundView;
        self.selectedBackgroundView.frame = self.contentView.frame;
        self.textLabel.highlightedTextColor = tableViewConfig.labelTextSelectedColor;
        self.detailTextLabel.highlightedTextColor = tableViewConfig.labelTextSelectedColor;
        self.backgroundView = tableViewConfig.cellBackgroundView;
        self.backgroundColor = tableViewConfig.cellBackgroundColor;
        self.selectionStyle = tableViewConfig.cellSelectionStyle;
    }
}

- (CGSize)sizeThatFits:(CGSize)size
{
//    NSLog(@"%@", NSStringFromCGSize(size));
    size.height = [self.textLabel.text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.textLabel.font} context:nil].size.height + 22;
//    NSLog(@"%@", NSStringFromCGSize(size));
    return size;
}

- (void)setCaseNode:(WLKCaseNode *)caseNode
{
    if (![_caseNode isEqual:caseNode]) {
        if (_caseNode) {
//            [_caseNode removeObserver:self forKeyPath:@"nodeContent"];
        }
        self.textLabel.numberOfLines = 0;
        _caseNode = caseNode;
//        [_caseNode addObserver:self forKeyPath:@"nodeContent" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
        self.textLabel.text = _caseNode.nodeName;
        if (_caseNode.nodeImageName) {
            self.imageView.image = [UIImage imageNamed:_caseNode.nodeImageName];
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
//    NSLog(@"%@, %@, self.caseNode.nodeContent:%@", keyPath, change, self.caseNode.nodeContent);
    self.textLabel.text = self.caseNode.nodeContent;
//    [self.caseNode.parentNode selectChildNode:self.caseNode];
    if ([self.superTableView isMemberOfClass:[UITableView class]]) {
//        UITableView *superView = self.superTableView;
        
//        [superView reloadRowsAtIndexPaths:@[([superView indexPathForCell:self])] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)dealloc
{
//    self.caseNode = nil;
}

@end
