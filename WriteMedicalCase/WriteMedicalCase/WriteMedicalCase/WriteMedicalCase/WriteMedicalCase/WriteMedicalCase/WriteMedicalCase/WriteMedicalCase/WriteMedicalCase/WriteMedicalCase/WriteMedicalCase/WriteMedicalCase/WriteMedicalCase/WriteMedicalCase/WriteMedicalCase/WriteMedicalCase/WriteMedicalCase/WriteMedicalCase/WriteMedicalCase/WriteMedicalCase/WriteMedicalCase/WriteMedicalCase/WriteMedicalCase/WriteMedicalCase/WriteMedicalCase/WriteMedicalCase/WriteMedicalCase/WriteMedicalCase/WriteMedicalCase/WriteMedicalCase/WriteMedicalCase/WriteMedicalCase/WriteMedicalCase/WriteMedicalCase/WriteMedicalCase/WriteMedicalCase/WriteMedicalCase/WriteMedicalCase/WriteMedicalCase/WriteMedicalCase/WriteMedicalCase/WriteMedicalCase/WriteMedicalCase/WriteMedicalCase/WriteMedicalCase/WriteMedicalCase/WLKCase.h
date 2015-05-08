//
//  WLKCase.h
//  MedCase
//
//  Created by ihefe36 on 14/12/31.
//  Copyright (c) 2014年 ihefe. All rights reserved.
//

#import "WLKTemplate.h"
@class WLKPatient;
@interface WLKCase : WLKTemplate

/**
 * 病历id
 */
@property (strong, nonatomic) NSString *caseID;

/**
 * 病历类型
 */
@property (strong, nonatomic) NSString *caseType;

/**
 * 病人，设置病人同时会把self加入到该病人的病历中
 */
@property (strong, nonatomic) WLKPatient *patient;

#warning more properties
@end
