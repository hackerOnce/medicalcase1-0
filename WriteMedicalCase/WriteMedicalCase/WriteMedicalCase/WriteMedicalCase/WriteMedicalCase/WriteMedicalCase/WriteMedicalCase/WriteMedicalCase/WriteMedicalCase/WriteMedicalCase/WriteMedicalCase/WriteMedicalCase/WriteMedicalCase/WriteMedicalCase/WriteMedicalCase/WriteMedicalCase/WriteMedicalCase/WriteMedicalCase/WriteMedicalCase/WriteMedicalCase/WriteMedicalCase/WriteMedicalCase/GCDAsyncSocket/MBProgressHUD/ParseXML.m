//
//  ParseXML.m
//  CoreData
//
//  Created by ihefe-JF on 15/1/21.
//  Copyright (c) 2015年 JFAppHourse.app. All rights reserved.
//

#import "ParseXML.h"
#import "XMLReader.h"
#import "WLKCaseNode.h"

@interface ParseXML()


@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *extendName;

@property (nonatomic,strong) NSArray *allKeys;

@end


@implementation ParseXML

-(instancetype)initWithXMLName:(NSString*)name extendName:(NSString *)extendName
{
    if(self = [super init])
    {
        self.name = name;
        self.extendName = extendName;
    }
    return self;
}

-(NSArray *)allKeys
{
    if(!_allKeys){
        _allKeys = @[@"其他病史基本信息",@"主诉",@"现病史",@"既往史",@"系统回顾",@"个人史",@"月经史",@"婚育史",@"家族史",@"体格检查",@"专科检查",@"辅助检查",@"初步诊断",@"入院诊断",@"补充诊断"];
    }
    return _allKeys;
}
-(WLKCaseNode *)getNodeWithKey:(NSString *)strKey
{
   
    
    WLKCaseNode *node = [WLKCaseNode nodeWithDictionary:self.rawDic];
   
    return [node getNodeFromNodeChildArrayWithNodeName:strKey];
   
}

//-(NSMutableDictionary*)getDictionaryWithKey:(NSString*)stringKey
//{
//    NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
//    
//    tempDic = self.rawDic[stringKey];
//    
//    return tempDic;
//}
-(NSMutableDictionary *)rawDic
{
    if(!_rawDic){
        NSString *filePath = [self dataFilePathXMLName:self.name extendName:self.extendName];
        NSData *xmlData = [[NSMutableData alloc] initWithContentsOfFile:filePath];
        NSError *error;
        NSDictionary *dic = [XMLReader dictionaryForXMLData:xmlData options:XMLReaderOptionsProcessNamespaces error:&error];
       // NSMutableArray *dicArray = dic[@"opml"][@"body"][@"outline"][@"outline"][0][@"_text"];
        
        dic = dic[@"opml"][@"body"][@"outline"];
        _rawDic = [[NSMutableDictionary alloc] initWithDictionary:dic];
    }
    return _rawDic;
}

- (NSString *)dataFilePathXMLName:(NSString*)name extendName:(NSString *)extendName {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *documentsPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",name,extendName]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:documentsPath]) {
        return documentsPath;
    } else {
        return [[NSBundle mainBundle] pathForResource:self.name ofType:self.extendName];
    }
    
}

@end
