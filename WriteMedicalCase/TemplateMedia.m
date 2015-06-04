//
//  TemplateMedia.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/6/4.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "TemplateMedia.h"



@implementation TemplateMedia
-(instancetype)initWithDict:(NSDictionary*)dict
{
    if (self = [super init]) {
        if ([dict.allKeys containsObject:@"dateType"]) {
            _dataType = dict[@"dateType"];
        }
        if ([dict.allKeys containsObject:@"location"]) {
            _location = dict[@"location"];
        }
        if ([dict.allKeys containsObject:@"noteID"]) {
            _noteID = dict[@"noteID"];
        }
        if ([dict.allKeys containsObject:@"data"]) {
            _data = dict[@"data"];
        }
        if ([dict.allKeys containsObject:@"contentType"]) {
            _contentType = dict[@"contentType"];
        }
        if ([dict.allKeys containsObject:@"mediaURL"]) {
            _mediaURL = dict[@"mediaURL"];
        }
        if ([dict.allKeys containsObject:@"mediaName"]) {
            _mediaName = dict[@"mediaName"];
        }
    }
    return self;
    
}
@end
