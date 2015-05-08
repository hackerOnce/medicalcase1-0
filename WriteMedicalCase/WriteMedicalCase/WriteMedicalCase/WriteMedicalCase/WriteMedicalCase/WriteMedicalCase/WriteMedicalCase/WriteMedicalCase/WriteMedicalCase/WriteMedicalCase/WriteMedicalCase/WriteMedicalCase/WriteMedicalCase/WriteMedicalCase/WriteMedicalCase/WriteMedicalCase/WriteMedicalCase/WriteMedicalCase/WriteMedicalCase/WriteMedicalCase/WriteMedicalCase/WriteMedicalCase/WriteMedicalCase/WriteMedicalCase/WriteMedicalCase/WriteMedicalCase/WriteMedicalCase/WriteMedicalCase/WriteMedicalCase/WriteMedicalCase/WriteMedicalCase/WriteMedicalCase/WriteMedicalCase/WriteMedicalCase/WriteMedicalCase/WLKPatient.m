//
//  WLKPatient.m
//  MedImageReader
//
//  Created by ihefe36 on 14/12/29.
//  Copyright (c) 2014年 ihefe. All rights reserved.
//

#import "WLKPatient.h"
#import "WLKCase.h"

@implementation WLKPatient
- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    //仅作为示例，具体字段根据接口文档确认。
    self.patientID = StringValue(dictionary[@"id"]);
    return self;
}

- (NSMutableArray *)cases
{
    if (!_cases) {
        _cases = [NSMutableArray array];
    }
    return _cases;
}

- (void)addCase:(WLKCase *)aCase
{
    BOOL canAdd = YES;
    for (int i = 0; i < self.cases.count; i++) {
        WLKCase *c = self.cases[i];
        if ([c.caseID isEqualToString:aCase.caseID]) {
            self.cases[i] = aCase;
            canAdd = NO;
        }
    }
    if (canAdd) {
        [self.cases addObject:aCase];
    }
}

@end
