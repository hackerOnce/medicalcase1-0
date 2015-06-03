//
//  TemplateModel.h
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/11.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TemplateModel : NSObject

@property (nonatomic, strong) NSString * dID;
@property (nonatomic, strong) NSString * dName;
@property (nonatomic, strong) NSString * templateID;
@property (nonatomic, strong) NSString * condition;
@property (nonatomic, strong) NSString * content;
@property (nonatomic, strong) NSString * gender;
@property (nonatomic, strong) NSString * ageHigh;
@property (nonatomic, strong) NSString * admittingDiagnosis;
@property (nonatomic, strong) NSString * simultaneousPhenomenon;
@property (nonatomic, strong) NSString * ageLow;
@property (nonatomic, strong) NSString * cardinalSymptom;
@property (nonatomic, strong) NSString *createDate;
@property (nonatomic, strong) NSString * section;
@property (nonatomic, strong) NSString * updatedTime;
@property (nonatomic, strong) NSString * sourceType;
@property (nonatomic, strong) NSString * createPeople;
@property (nonatomic, strong) NSString * templateType;
@property (nonatomic, strong) NSString * templatedName;

-(instancetype)initWithDic:(NSDictionary*)dic;

-(instancetype)initWithTemplate:(TemplateModel*)templateModel;
@end
