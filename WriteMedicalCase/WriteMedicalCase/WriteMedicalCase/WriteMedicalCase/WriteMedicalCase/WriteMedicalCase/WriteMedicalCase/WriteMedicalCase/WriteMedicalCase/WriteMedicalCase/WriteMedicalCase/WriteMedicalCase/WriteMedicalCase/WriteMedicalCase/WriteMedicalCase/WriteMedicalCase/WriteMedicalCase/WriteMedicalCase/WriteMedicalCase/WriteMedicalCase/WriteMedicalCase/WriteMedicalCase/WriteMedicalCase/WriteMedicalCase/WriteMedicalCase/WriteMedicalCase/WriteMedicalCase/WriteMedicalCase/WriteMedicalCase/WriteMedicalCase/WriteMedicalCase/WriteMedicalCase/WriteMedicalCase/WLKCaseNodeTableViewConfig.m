//
//  WLKCaseNodeTableViewConfig.m
//  MedCase
//
//  Created by ihefe36 on 15/1/7.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import "WLKCaseNodeTableViewConfig.h"

@implementation WLKCaseNodeTableViewConfig
- (instancetype)init
{
    if (self = [super init]) {
        self.cellSeparatorShouldShow = YES;
        self.cellSelectionStyle = -1;
        self.shouldSelectFirstCellDefault = YES;
        self.shouldAddVerticalSeparatorLine = YES;
    }
    return self;
}
@end
