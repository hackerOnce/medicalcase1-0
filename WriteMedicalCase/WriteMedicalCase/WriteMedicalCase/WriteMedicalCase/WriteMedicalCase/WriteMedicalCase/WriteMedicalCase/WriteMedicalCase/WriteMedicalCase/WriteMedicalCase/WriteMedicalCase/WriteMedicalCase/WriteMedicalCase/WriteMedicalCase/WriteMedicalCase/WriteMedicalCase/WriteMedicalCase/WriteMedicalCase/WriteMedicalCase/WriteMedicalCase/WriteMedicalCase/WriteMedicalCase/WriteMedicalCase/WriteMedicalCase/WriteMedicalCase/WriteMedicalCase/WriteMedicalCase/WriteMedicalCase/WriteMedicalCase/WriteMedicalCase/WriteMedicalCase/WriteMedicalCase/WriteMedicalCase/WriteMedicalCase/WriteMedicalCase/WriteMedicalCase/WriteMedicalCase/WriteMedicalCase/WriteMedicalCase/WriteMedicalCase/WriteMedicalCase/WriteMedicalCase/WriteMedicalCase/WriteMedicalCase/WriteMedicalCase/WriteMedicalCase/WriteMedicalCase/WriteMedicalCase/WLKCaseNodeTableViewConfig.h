//
//  WLKCaseNodeTableViewConfig.h
//  MedCase
//
//  Created by ihefe36 on 15/1/7.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WLKCaseNodeTableViewConfig : NSObject
/**
 * cell的普通accessoryType
 */
@property (assign, nonatomic) UITableViewCellAccessoryType normalAccessoryType;
/**
 * cell的选中accessoryType
 */
@property (assign, nonatomic) UITableViewCellAccessoryType selectedAccessoryType;
/**
 * 是否在tableView右边添加一条竖分割线
 */
@property (assign, nonatomic) BOOL shouldAddVerticalSeparatorLine;
/**
 * cell的背景View
 */
@property (strong, nonatomic) UIView *cellBackgroundView;
/**
 * cell的选中背景View
 */
@property (strong, nonatomic) UIView *cellSelectedBackgroundView;
/**
 * cell的选中style
 */
@property (assign, nonatomic) UITableViewCellSelectionStyle cellSelectionStyle;
/**
 * table的背景view
 */
@property (strong, nonatomic) UIView *tableBackgroundView;
/**
 * cell的背景颜色
 */
@property (strong, nonatomic) UIColor *cellBackgroundColor;
/**
 * cell的选中背景颜色
 */
@property (strong, nonatomic) UIColor *cellSelectedBackgroundColor;
/**
 * table的背景颜色
 */
@property (strong, nonatomic) UIColor *tableBackgroundColor;

/**
 * label选中字体颜色
 */
@property (strong, nonatomic) UIColor *labelTextSelectedColor;

/**
 * cell分割线左空白
 */
@property (assign, nonatomic) CGFloat cellSeparatorLeftMargin;
/**
 * cell分割线右空白
 */
@property (assign, nonatomic) CGFloat cellSeparatorRightMargin;

/**
 * 是否显示cell分割线
 */
@property (assign, nonatomic) BOOL cellSeparatorShouldShow;

/**
 * 是否默认选择第一个cell
 */
@property (assign, nonatomic) BOOL shouldSelectFirstCellDefault;

/**
 * 是否允许最后一个tableView多选
 */
@property (assign, nonatomic) BOOL allowMultiSelected;

//@property (assign, nonatomic) BOOL isSelected;

@end
