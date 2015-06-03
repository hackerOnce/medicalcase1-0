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

@property (nonatomic,strong) NSString *pID;
@property (nonatomic,strong) NSString *pName;

@property (nonatomic,strong) NSString *residentID; //住院医师ID
@property (nonatomic,strong) NSString *residentName;//住院医师姓名
@property (nonatomic,strong) NSString *attendingPhysiciandName;//主治医师姓名
@property (nonatomic,strong) NSString *attendingPhysiciandID;//主治医师ID
@property (nonatomic,strong) NSString *chiefPhysiciandName;//主任医师姓名
@property (nonatomic,strong) NSString *chiefPhysiciandID;//主任医师ID

-(instancetype)initWithCaseInfoDic:(NSDictionary*)caseInfoDic;

@end
