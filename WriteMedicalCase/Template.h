//
//  Template.h
//  MedicalCase
//
//  Created by ihefe-JF on 15/4/8.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Node;

@interface Template : NSManagedObject
+(NSString*)entityName;
@property (nonatomic, retain) NSString * dName;
@property (nonatomic, retain) NSString * dID;
@property (nonatomic, retain) NSString * templateID;

@property (nonatomic, retain) NSString * condition;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) NSNumber * ageHigh;
@property (nonatomic, retain) NSString * admittingDiagnosis;
@property (nonatomic, retain) NSString * simultaneousPhenomenon;
@property (nonatomic, retain) NSNumber * ageLow;
@property (nonatomic, retain) NSString * cardinalSymptom;
@property (nonatomic, retain) NSDate * createDate;
@property (nonatomic, retain) NSString * section;
@property (nonatomic, retain) Node *node;
@property (nonatomic, retain) NSString  * updatedTime;
@property (nonatomic, retain) NSString * nodeID;
@property (nonatomic,retain) NSString *sourceType;
@property (nonatomic,retain) NSString *createPeople;

@end
