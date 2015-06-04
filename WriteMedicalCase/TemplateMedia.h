//
//  TemplateMedia.h
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/6/4.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TemplateMedia : NSObject

@property (nonatomic, strong) NSString * dataType; //照片：0，音频：1
@property (nonatomic, strong) NSString * location;
@property (nonatomic, strong) NSString * noteID;
@property (nonatomic, strong) NSData * data;
@property (nonatomic, strong) NSString *contentType;//s,o,a,p
@property (nonatomic, strong) NSURL *mediaURL;
@property (nonatomic, strong) NSString *mediaName;

-(instancetype)initWithDict:(NSDictionary*)dict;

@end
