//
//  TempCaseBaseInfo.h
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/4.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TempCaseBaseInfo : NSObject
@property (nonatomic,strong) NSString *createdTime;
@property (nonatomic,strong) NSString *lastModifyTime;
@property (nonatomic,strong) NSString *archivedTime;
@property (nonatomic,strong) NSString *casePresenter;


@property (nonatomic,strong) NSDictionary *caseContent;
@property (nonatomic,strong) NSString *caseType;

-(instancetype)initWithCaseInfoDic:(NSDictionary*)caseInfoDic;

@end
