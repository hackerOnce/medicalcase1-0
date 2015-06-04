//
//  TemplateNoteContent.h
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/6/4.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TemplateNoteContent : NSObject
@property (nonatomic, strong) NSString * content;
@property (nonatomic, strong) NSString * contentType;
@property (nonatomic, strong) NSMutableArray *medias;

-(instancetype)initWithDict:(NSDictionary*)dict;

@end
