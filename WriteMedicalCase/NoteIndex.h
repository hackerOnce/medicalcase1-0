//
//  NoteIndex.h
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/6/3.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface NoteIndex : NSManagedObject

@property (nonatomic, retain) NSString * dID;
@property (nonatomic, retain) NSNumber * index;
+(NSString*)entityName;

@end
