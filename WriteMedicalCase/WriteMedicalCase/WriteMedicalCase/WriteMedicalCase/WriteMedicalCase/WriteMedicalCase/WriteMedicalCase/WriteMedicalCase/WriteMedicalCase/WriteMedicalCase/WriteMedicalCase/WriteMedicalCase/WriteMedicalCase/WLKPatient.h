//
//  WLKPatient.h
//  MedImageReader
//
//  Created by ihefe36 on 14/12/29.
//  Copyright (c) 2014年 ihefe. All rights reserved.
//

#import "WLKObject.h"
@class WLKCase;
@interface WLKPatient : WLKObject
/**
 * 病人id
 */
@property (strong, nonatomic) NSString *patientID;

/**
 * 病人姓名
 */
@property (strong, nonatomic) NSString *patientName;

/**
 * 病历数组
 */
@property (strong, nonatomic) NSMutableArray *cases;

#warning more properties

/**
 * 添加病历到病历数组，若已有相同ID的病历，则会替换，否则添加
 */
- (void)addCase:(WLKCase *)aCase;

@end
