//
//  CoreDataStack.h
//  CoreData
//
//  Created by GK on 15/4/4.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "RecordBaseInfo.h"
#import "ParentNode.h"

@interface CoreDataStack : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic,strong) NSManagedObjectContext *privateContext;

@property (nonatomic) NSInteger nodeRow;
@property (nonatomic) NSInteger nodeSection;

- (void)saveContext;

- (NSURL *)applicationDocumentsDirectory;

-(ParentNode*)fetchParentNodeWithNodeEntityName:(NSString*)parentName;

-(void)saveFieldNodeListToCoreData;

-(RecordBaseInfo*)fetchRecordWithDict:(NSDictionary*)dict isReturnNil:(BOOL)isReturnNil;

-(Patient*)patientFetchWithDict:(NSDictionary*)dict;

-(void)recordUpdatedWithDict:(NSDictionary*)dict;

-(void)updateCaseContent:(CaseContent*)caseContent dataWithDict:(NSDictionary*)dict;


@end
