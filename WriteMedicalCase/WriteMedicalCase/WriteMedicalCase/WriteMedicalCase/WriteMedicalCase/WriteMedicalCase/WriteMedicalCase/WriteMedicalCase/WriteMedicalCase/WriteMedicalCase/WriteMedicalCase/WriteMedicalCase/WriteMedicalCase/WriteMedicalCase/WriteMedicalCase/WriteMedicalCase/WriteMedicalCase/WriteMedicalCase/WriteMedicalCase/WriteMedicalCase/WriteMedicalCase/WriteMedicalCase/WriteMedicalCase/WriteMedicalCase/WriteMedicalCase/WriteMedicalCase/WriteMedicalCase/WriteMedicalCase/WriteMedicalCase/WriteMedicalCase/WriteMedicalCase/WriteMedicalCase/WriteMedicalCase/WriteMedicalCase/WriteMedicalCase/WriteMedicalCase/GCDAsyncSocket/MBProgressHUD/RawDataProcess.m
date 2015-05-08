//
//  RawDataProcess.m
//  MedCase
//
//  Created by ihefe-JF on 15/1/30.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import "RawDataProcess.h"
#import "ParseXML.h"
#import "SBJsonWriter.h"

@interface RawDataProcess ()

@end

@implementation RawDataProcess

+(RawDataProcess *)sharedRawData
{
    static dispatch_once_t onceToken;
    static RawDataProcess *sharedRawData;
    
    dispatch_once(&onceToken, ^{
        sharedRawData = [[RawDataProcess alloc] init];
    });
    
    return sharedRawData;
}

-(instancetype)init
{
    if(self = [super init]){
        
        ParseXML *pa = [[ParseXML alloc] initWithXMLName:@"病历" extendName:@"opml"];
        self.XMLDic = [pa rawDic];
        WLKCaseNode *node = [WLKCaseNode nodeWithDictionary:self.XMLDic];
        WLKCaseNode *node1 = [node getNodeFromNodeChildArrayWithNodeName:@"住院志"];
        
        self.rootNode = [node1 getNodeFromNodeChildArrayWithNodeName:@"入院记录（可以做到各科专科内容）"];
        
    }
    
    return self;
}

-(NSString *)stringFromJsonDic:(NSMutableDictionary *)tempDic
{
    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
    return [jsonWriter stringWithObject:tempDic];
}
-(NSDictionary*)dicFromJsonString:(NSString*)tempStr
{
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    return [jsonParser objectWithString:tempStr];
}
//-(WLKCaseNode*)getRawNodeData
//{
//    //NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"test" ofType:@"plist"]];
//    ParseXML *pa = [[ParseXML alloc] initWithXMLName:@"病历" extendName:@"opml"];
//    
//    WLKCaseNode *caseNode = [pa getNodeWithKey:@"入院记录（可以做到各科专科内容）"];
//    return caseNode;
//}

@end
