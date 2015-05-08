//
//  WLKCaseNode.m
//  MedCase
//
//  Created by ihefe36 on 15/1/4.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import "WLKCaseNode.h"
#import "SBJson.h"

@implementation WLKCaseNode

@synthesize nodeContent = _nodeContent;
@synthesize nodeChangeStatus = _nodeChangeStatus;

- (instancetype)init
{
    if (self = [super init]) {
        //        self.allowChangeContentByChild = YES;
        //        _nodeContent = @"";
    }
    return self;
}

- (NSString *)jsonString
{
    SBJsonWriter *parser = [[SBJsonWriter alloc] init];
    return [parser stringWithObject:[self dictionaryForJson]];
}

- (NSDictionary *)dictionaryForJson
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (self.nodeContent) {
        [dic setObject:self.nodeContent forKey:@"nodeContent"];
    }
    if (self.nodeName) {
        [dic setObject:self.nodeName forKey:@"nodeName"];
    }
    [dic setObject:@(self.nodeType) forKey:@"nodeType"];
    [dic setObject:@(self.nodeSourceType) forKey:@"sourceType"];
    NSMutableArray *array = [NSMutableArray array];
    for (WLKCaseNode *node in self.childNodes) {
        [array addObject:[node dictionaryForJson]];
    }
    [dic setObject:array forKey:@"childNodes"];
    return dic;
}

- (NSMutableArray *)childNodes
{
    if (!_childNodes) {
        _childNodes = [NSMutableArray array];
    }
    return _childNodes;
}

- (NSMutableArray *)selectedChildNodes
{
    if (!_selectedChildNodes) {
        _selectedChildNodes = [NSMutableArray array];
    }
    return _selectedChildNodes;
}

- (NodeChangeStatus)nodeChangeStatus
{
    return self.selectedChildNodes.count == 0 ? NodeChangeStatusNone : NodeChangeStatusChanged;
}

- (void)selectChildNode:(WLKCaseNode *)node
{
    if (self.tableViewConfig.allowMultiSelected) {
        if (![self.selectedChildNodes containsObject:node]) {
            [self.selectedChildNodes addObject:node];
        }
    }
    else
    {
        [self.selectedChildNodes removeAllObjects];
        [self.selectedChildNodes addObject:node];
    }
    if (node.childNodes.count == 0 || node.selectedChildNodes.count != 0) {
        self.rootNode.nodeContent = [self.rootNode selectedChildNodeContents];
        self.nodeChangeStatus = NodeChangeStatusChanged;
    }
    [self.parentNode selectChildNode:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:nShouldReloadNodeTableView object:nil];
}

- (void)deselectChildNode:(WLKCaseNode *)node
{
    if ([self.selectedChildNodes containsObject:node]) {
        [self.selectedChildNodes removeObject:node];
    }
    self.rootNode.nodeContent = [self.rootNode selectedChildNodeContents];
    if ([self.parentNode.tableViewConfig allowMultiSelected]) {
        if (self.selectedChildNodes.count == 0) {
            [self.parentNode deselectChildNode:self];
        }
    }
    else
    {
        [self.parentNode deselectChildNode:self];
    }
    if (self.selectedChildNodes.count == 0) {
        self.nodeChangeStatus = NodeChangeStatusNone;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:nShouldReloadNodeTableView object:nil];
}

+ (instancetype)nodeWithSourceType:(NodeSourceType)type
{
    WLKCaseNode *rootNode = [[WLKCaseNode alloc] initWithSourceType:type];
    rootNode.tableViewConfig.allowMultiSelected = YES;
    return rootNode;
}

- (instancetype)initWithSourceType:(NodeSourceType)type
{
    if (self = [super init]) {
        _nodeSourceType = type;
    }
    return self;
}

+ (instancetype)nodeWithDictionary:(NSDictionary *)dic
{
    WLKCaseNode *rootNode = [[WLKCaseNode alloc] initWithDictionaryForXML:dic];
   // WLKCaseNode *rootNode = [[WLKCaseNode alloc] initWithDictionary:dic];
    rootNode.tableViewConfig.allowMultiSelected = YES;
    return rootNode;
}

- (instancetype)initWithDictionary:(NSDictionary *)dic
{
    if (self = [super initWithDictionary:dic]) {

        self.tableViewConfig.allowMultiSelected = YES;
        
        if ([dic.allKeys containsObject:@"childNodes"]) {
            for (NSObject *d in dic[@"childNodes"]) {
                if ([d isKindOfClass:[NSDictionary class]]) {
                    WLKCaseNode *node;
                    if(dic[@"status"]){
                        node = [[WLKCaseNode alloc] initWithDictionary:(NSDictionary*)d];
                    }else {
                        node = [WLKCaseNode nodeWithDictionary:(NSDictionary*)d];
                    }
                    node.tableViewConfig.allowMultiSelected = YES;
                    [self addChildNode:node];
                }
            }
        }
        if ([dic.allKeys containsObject:@"nodeName"]) {
            self.nodeName = StringValue(dic[@"nodeName"]);
        }
        if ([dic.allKeys containsObject:@"nodeContent"]) {
            self.nodeContent = StringValue(dic[@"nodeContent"]);
        }
        if ([dic.allKeys containsObject:@"sourceType"]) {
            _nodeSourceType = (NodeSourceType)IntValue(dic[@"sourceType"]);
        }
        else
        {
            _nodeSourceType = NodeSourceTypeSystem;
        }
        if ([dic.allKeys containsObject:@"nodeType"]) {
            _nodeType = (NodeType)IntValue(dic[@"nodeType"]);
        }
        else
        {
            _nodeType = NodeTypeSingleSelection;
        }
#warning 其他属性应和nodename做同样处理
    }
    return self;
}

- (instancetype)initWithDictionaryForXML:(NSDictionary *)dic
{
    if (self = [super initWithDictionary:dic]) {
        if ([dic.allKeys containsObject:@"_text"]) {
            self.nodeName = StringValue(dic[@"_text"]);
            if ([self.nodeName isEqualToString:@"前庭大腺"]) {
                
            }
        }
        if ([dic.allKeys containsObject:@"sourceType"]) {
            _nodeSourceType = (NodeSourceType)IntValue(dic[@"sourceType"]);
        }
        else
        {
            _nodeSourceType = NodeSourceTypeSystem;
        }
        if ([dic.allKeys containsObject:@"nodeType"]) {
            _nodeType = (NodeType)IntValue(dic[@"nodeType"]);
        }
        else
        {
            _nodeType = NodeTypeSingleSelection;
        }
        if ([dic.allKeys containsObject:@"outline"]) {
            NSObject *obj = dic[@"outline"];
            if ([obj isKindOfClass:[NSDictionary class]]) {
                WLKCaseNode *node = [WLKCaseNode nodeWithDictionary:(NSDictionary *)obj];
                [self addChildNode:node];
            }
            if ([obj isKindOfClass:[NSArray class]]) {
                for (NSObject *d in dic[@"outline"]) {
                    if ([d isKindOfClass:[NSDictionary class]]) {
                        WLKCaseNode *node = [WLKCaseNode nodeWithDictionary:(NSDictionary *)d];
                        [self addChildNode:node];
                    }
                }
            }
        }
#warning 其他属性应和nodename做同样处理
    }
    return self;
}

- (BOOL)changeNodeContent:(NSString *)nodeContent sender:(WLKCaseNode *)sender
{
    BOOL toReturn = NO;
    [self.parentNode changeNodeContent:nodeContent sender:self];
    return toReturn;
}
#warning 定显示规则
- (NSString *)nodeContent
{
    if (!_nodeContent) {
        return self.nodeName;
    }
    return _nodeContent;
}

- (NSString *)selectedChildNodeContents
{
    NSMutableString *tempContent = [NSMutableString stringWithFormat:@"%@", self.nodeName];
    self.nodeContent = nil;
    [self sortSelectedChildNodesByOrderNum];
    for (WLKCaseNode *node in self.selectedChildNodes) {
        NSString *str = [node selectedChildNodeContents];
        if (str.length == 0) {
            str = node.nodeContent;
        }
        
        [tempContent insertString:str atIndex:tempContent.length];
        
//        NSLog(@"%@, %@, %@", self.rootNode, self, tempContent);
        if (node.childNodes.count == 0) {
            [tempContent insertString:@"，" atIndex:tempContent.length];
        }
        if (node.childNodes.count != 0) {
            if ([tempContent hasSuffix:@"，"]) {
                [tempContent replaceCharactersInRange:NSMakeRange(tempContent.length - 1, 1) withString:@"；"];
            }
            else
            {
                if (![tempContent hasSuffix:@"；"] && ![tempContent hasSuffix:@"。"]) {
                    [tempContent insertString:@"；" atIndex:tempContent.length];
                }
            }
            
        }
        if (([self.rootNode isEqual:self] && [node isEqual:self.selectedChildNodes.lastObject]) && ([tempContent hasSuffix:@"；"] || [tempContent hasSuffix:@"，"])) {
            [tempContent replaceCharactersInRange:NSMakeRange(tempContent.length - 1, 1) withString:@"。"];
        }
    }
    
//    self.nodeContent = tempContent;
    return tempContent;
}

- (void)setRootNode:(WLKCaseNode *)rootNode
{
    if (!rootNode) {
        return;
    }
    _rootNode = rootNode;
    for (WLKCaseNode *node in self.childNodes) {
        node.rootNode = rootNode;
    }
}

- (NSMutableArray *)childNodeNames
{
    NSMutableArray *tempArray = [NSMutableArray array];
    for (WLKCaseNode *node in self.childNodes) {
        
        if(node.nodeName){
            [tempArray addObject:node.nodeName];
        }
       
    }
    return tempArray;
}

- (WLKCaseNodeTableViewConfig *)tableViewConfig
{
    if (!_tableViewConfig) {
        _tableViewConfig = [[WLKCaseNodeTableViewConfig alloc] init];
    }
    return _tableViewConfig;
}

- (BOOL)addChildNode:(WLKCaseNode *)node
{
    BOOL toReturn = NO;
    if (node && [node isKindOfClass:[WLKCaseNode class]]) {
        node.parentNode = self;
        node.rootNode = self.rootNode;
        node.orderNum = self.childNodes.count;
        [self.childNodes addObject:node];
        toReturn = YES;
    }
    else
    {
        WLKLog(@"添加失败，请检查node是否为空，并且为WLKNode或其子类");
    }
    return toReturn;
}

- (BOOL)removeChildNode:(WLKCaseNode *)node
{
    BOOL toReturn = NO;
    if (node && [node isKindOfClass:[WLKCaseNode class]] && [self.childNodes containsObject:node]) {
        node.parentNode = nil;
        [self.childNodes removeObject:node];
        toReturn = YES;
        if ([self.selectedChildNodes containsObject:node]) {
            [self.selectedChildNodes removeObject:node];
        }
    }
    else
    {
        WLKLog(@"删除失败，请检查node是否为空，并且为WLKNode或其子类");
    }
    return toReturn;
}

- (BOOL)removeChildNodeByName:(NSString *)nodeName
{
    BOOL toReturn = NO;
    for (WLKCaseNode *node in self.childNodes) {
        if ([node.nodeName isEqualToString:nodeName]) {
            [self removeChildNode:node];
            toReturn = YES;
            break;
        }
    }
    return toReturn;
}

- (void)removeFromParentNode
{
    if (self.parentNode) {
        [self.parentNode removeChildNode:self];
    }
}

- (NSInteger)countOfChildNodesHierarchy
{
    NSInteger toReturn = 0;
    if (self.childNodes.count == 0) {
        return toReturn;
    }
    for (WLKCaseNode *node in self.childNodes) {
        NSInteger count = [node countOfChildNodesHierarchy];
        if (count >= 0) {
            toReturn = MAX(toReturn, count + 1);
        }
    }
    return toReturn;
}

- (NSComparisonResult)compareByOrderNum:(WLKCaseNode *)otherNode;
{
    if (self.orderNum < otherNode.orderNum) {
        return -1;
    }
    else if (self.orderNum == otherNode.orderNum) {
        return 0;
    }
    else
    {
        return 1;
    }
}

- (void)sortChildNodesByOrderNum
{
    [self quickSortWithArray:self.childNodes left:0 right:self.childNodes.count - 1 userSelector:@selector(compareByOrderNum:)];
}

- (void)sortSelectedChildNodesByOrderNum
{
    [self quickSortWithArray:self.selectedChildNodes left:0 right:self.selectedChildNodes.count - 1 userSelector:@selector(compareByOrderNum:)];
}

-(void)quickSortWithArray:(NSMutableArray *)aData left:(NSInteger)left right:(NSInteger)right userSelector:(SEL)selector
{
    if (right > left) {
        NSInteger i = left;
        NSInteger j = right + 1;
        while (true) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            while (i+1 < [aData count] && (NSInteger)[[aData objectAtIndex:++i] performSelector:selector withObject:[aData objectAtIndex:left]] == -1) ;
            while (j-1 > -1 && (NSInteger)[[aData objectAtIndex:--j] performSelector:selector withObject:[aData objectAtIndex:left]] == 1) ;
#pragma clang diagnostic pop
            if (i >= j) {
                break;
            }
            [self swapWithData:aData index1:i index2:j];
        }
        [self swapWithData:aData index1:left index2:j];
        [self quickSortWithArray:aData left:left right:j-1 userSelector:selector];
        [self quickSortWithArray:aData left:j+1 right:right userSelector:selector];
    }
}

-(void)swapWithData:(NSMutableArray *)aData index1:(NSInteger)index1 index2:(NSInteger)index2{
    NSObject *tmp = [aData objectAtIndex:index1];
    [aData replaceObjectAtIndex:index1 withObject:[aData objectAtIndex:index2]];
    [aData replaceObjectAtIndex:index2 withObject:tmp];
}

-(WLKCaseNode*)getNodeFromNodeChildArrayWithNodeName:(NSString*)nodeName
{
    WLKCaseNode *caseNode;
    
    for(WLKCaseNode *tempNode in self.childNodes){
        if([tempNode.nodeName isEqualToString:nodeName]){
            caseNode = tempNode;
            break;
        }
    }
    return caseNode;
}

+(WLKCaseNode*)getSubNodeFromNode:(WLKCaseNode*)node withNodeName:(NSString*)nodeName resultNode:(WLKCaseNode*)resultNode
{
    if ([node.nodeName isEqualToString:nodeName]) {
         resultNode =  node;
    }
    for (WLKCaseNode *tt in node.childNodes) {
       resultNode =  [self getSubNodeFromNode:tt withNodeName:nodeName resultNode:resultNode];
    }
    
    return resultNode;
}
+(NSArray*)getAllSubNodesFromParentNode:(WLKCaseNode*)node
{
    NSMutableArray *tempNodeArray = [[NSMutableArray alloc] init];
    
    for(WLKCaseNode *tempNode in node.childNodes){
        if(tempNode.childNodes.count != 0){
            [tempNodeArray addObjectsFromArray:[self getAllSubNodesFromParentNode:tempNode]];
        }
        if(tempNode.childNodes.count == 0){
            [tempNodeArray addObject:tempNode];
        }
    }
    
    NSLog(@"nodename 为 %@的node有%d个子node",node.nodeName,tempNodeArray.count);
    return tempNodeArray;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Class : %@, nodeName = %@, %@", [self class], [self nodeName], [super description]];
}

- (void)clearSelected
{
    self.nodeContent = self.nodeName;
    [self.selectedChildNodes removeAllObjects];
    [[NSNotificationCenter defaultCenter] postNotificationName:nShouldReloadNodeTableView object:nil];
}

@end
