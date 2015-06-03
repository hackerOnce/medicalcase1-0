//
//  TempRecord.h
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/19.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TempRecord : NSObject
@property (nonatomic,strong) NSString *caseType;
@property (nonatomic,strong) NSString *caseStatus;

-(instancetype)initWithDic:(NSDictionary*)dict;

@end
