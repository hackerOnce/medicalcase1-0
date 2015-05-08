//
//  UIView+FrameExtends.m
//  MedCase
//
//  Created by ihefe36 on 15/1/7.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import "UIView+FrameExtends.h"

@implementation UIView (FrameExtends)
- (void)setViewX:(CGFloat)x
{
    CGRect rect = self.frame;
    rect.origin.x = x;
    self.frame = rect;
}
- (void)setViewY:(CGFloat)y
{
    CGRect rect = self.frame;
    rect.origin.y = y;
    self.frame = rect;
}
- (void)setViewWidth:(CGFloat)width
{
    CGRect rect = self.frame;
    rect.size.width = width;
    self.frame = rect;
}
- (void)setViewHeight:(CGFloat)height
{
    CGRect rect = self.frame;
    rect.size.height = height;
    self.frame = rect;
}
- (void)setViewOrigin:(CGPoint)origin
{
    CGRect rect = self.frame;
    rect.origin = origin;
    self.frame = rect;
}
- (void)setViewSize:(CGSize)size
{
    CGRect rect = self.frame;
    rect.size = size;
    self.frame = rect;
}

- (void)clearSubviews
{
    for (int i = 0; i < self.subviews.count; i++) {
        [self.subviews.lastObject removeFromSuperview];
    }
}
@end
