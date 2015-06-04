//
//  TemplateNoteContent.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/6/4.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "TemplateNoteContent.h"
#import "TemplateMedia.h"

@implementation TemplateNoteContent
-(instancetype)initWithDict:(NSDictionary*)dict
{
    if (self = [super init]) {
        
        if ([dict.allKeys containsObject:@"content"]) {
            _content = dict[@"content"];
        }
        if ([dict.allKeys containsObject:@"contentType"]) {
            _contentType = dict[@"contentType"];
        }
        
        if ([dict.allKeys containsObject:@"meidas"]) {
            NSArray *mediasArray = dict[@"medias"];
            for (NSDictionary *mediaDict in mediasArray) {
                TemplateMedia *media = [[TemplateMedia alloc] initWithDict:mediaDict];
                [self.medias addObject:media];
            }
        }
        
    }
    return self;
}
-(NSMutableArray *)medias
{
    if (!_medias) {
        _medias = [[NSMutableArray alloc] init];
    }
    return _medias;
}
@end
