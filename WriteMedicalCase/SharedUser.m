//
//  SharedUser.m
//  WriteMedicalCase
//
//  Created by ihefe-JF on 15/5/18.
//  Copyright (c) 2015年 GK. All rights reserved.
//

#import "SharedUser.h"
#import "Template.h"


@implementation SharedUser

@dynamic sharedUserID;
@dynamic template;
+(NSString*)entityName
{
    return @"SharedUser";
}
@end
