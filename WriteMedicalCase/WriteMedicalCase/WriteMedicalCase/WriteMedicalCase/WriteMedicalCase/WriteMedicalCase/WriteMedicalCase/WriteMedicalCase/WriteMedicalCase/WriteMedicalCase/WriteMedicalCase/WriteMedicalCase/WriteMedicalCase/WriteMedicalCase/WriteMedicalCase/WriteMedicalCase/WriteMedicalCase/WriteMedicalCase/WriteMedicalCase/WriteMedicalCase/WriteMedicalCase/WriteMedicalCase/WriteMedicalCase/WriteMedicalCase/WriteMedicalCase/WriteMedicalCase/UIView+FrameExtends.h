//
//  UIView+FrameExtends.h
//  MedCase
//
//  Created by ihefe36 on 15/1/7.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (FrameExtends)
/**
 * 设置x
 */
- (void)setViewX:(CGFloat)x;
/**
 * 设置y
 */
- (void)setViewY:(CGFloat)y;
/**
 * 设置width
 */
- (void)setViewWidth:(CGFloat)width;
/**
 * 设置height
 */
- (void)setViewHeight:(CGFloat)height;
/**
 * 设置左上角坐标
 */
- (void)setViewOrigin:(CGPoint)origin;
/**
 * 设置size
 */
- (void)setViewSize:(CGSize)size;

/**
 * 清空子视图
 */
- (void)clearSubviews;
@end
