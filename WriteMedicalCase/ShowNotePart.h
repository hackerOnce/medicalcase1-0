//
//  ShoNotePart.h
//  WriteMedicalCase
//
//  Created by GK on 15/6/6.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ShowNotePart : NSManagedObject

@property (nonatomic, retain) NSString * updatedTime;
@property (nonatomic, retain) NSString * titleString;
@property (nonatomic, retain) NSString * doctorID;
@property (nonatomic, retain) NSString * doctorName;
@property (nonatomic, retain) NSString * partContent;
@property (nonatomic, retain) NSString * noteID;
@property (nonatomic, retain) NSString * noteUUID;

+(NSString*)entityName;

@end
