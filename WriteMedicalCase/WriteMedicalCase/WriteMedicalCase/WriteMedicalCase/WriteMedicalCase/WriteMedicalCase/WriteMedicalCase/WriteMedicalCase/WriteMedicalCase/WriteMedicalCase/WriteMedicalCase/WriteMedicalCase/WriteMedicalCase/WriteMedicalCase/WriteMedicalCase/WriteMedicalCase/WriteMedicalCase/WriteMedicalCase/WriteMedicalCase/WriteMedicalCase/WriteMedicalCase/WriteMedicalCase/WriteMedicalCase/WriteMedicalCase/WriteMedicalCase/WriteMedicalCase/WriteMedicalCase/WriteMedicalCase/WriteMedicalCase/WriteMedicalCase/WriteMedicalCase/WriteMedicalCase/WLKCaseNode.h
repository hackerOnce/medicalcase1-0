//
//  WLKCaseNode.h
//  MedCase
//
//  Created by ihefe36 on 15/1/4.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import "WLKObject.h"
#import "WLKCaseNodeTableViewConfig.h"

typedef enum NodeChangeStatus
{
    NodeChangeStatusNone,
    NodeChangeStatusChanged
}NodeChangeStatus;

typedef enum NodeType
{
    NodeTypeNone = -1,
    NodeTypeMultiSelection,
    NodeTypeSingleSelection,
    NodeTypeDate,
    NodeTypeDateRange
}NodeType;

typedef enum NodeSourceType
{
    NodeSourceTypeUnknown,
    NodeSourceTypeSystem,
    NodeSourceTypeCustom
}NodeSourceType;


@interface WLKCaseNode : WLKObject
/**
 * id
 */
@property (strong, nonatomic) NSString *nodeID;
/**
 * 节点名
 */
@property (strong, nonatomic) NSString *nodeName;
/**
 * 要显示的内容，如果没设置过显示nodeName
 */
@property (strong, nonatomic) NSString *nodeContent;

/**
 * 是否允许子节点修改父节点content
 */
@property (assign, nonatomic) BOOL allowChangeContentByChild;

/**
 * 子节点数组
 */
@property (strong, nonatomic) NSMutableArray *childNodes;

/*!
 * @brief cell被选中的子节点数组
 */
@property (strong, nonatomic) NSMutableArray *selectedChildNodes;

/**
 * 父节点
 */
@property (weak, nonatomic) WLKCaseNode *parentNode;

/**
 * 序号
 */
@property (assign, nonatomic) NSUInteger orderNum;

/**
 * 内容view类型，－1代表无，0代表多选，1代表单选，2代表时间点，3代表时间范围
 */
@property (assign, nonatomic) NodeType nodeType;

/**
 * 内容view类型，0代表无，1代表系统整理，2代表自定义，只读，只能在初始化时赋值
 */
@property (assign, nonatomic, readonly) NodeSourceType nodeSourceType;

/**
 * 是否有选中子节点，0代表没有，1代表有，
 */
@property (assign, nonatomic) NodeChangeStatus nodeChangeStatus;

/**
 * 有些节点在cell里有图标，节点的图标名字的string
 */
@property (strong, nonatomic) NSString *nodeImageName;

@property (strong, nonatomic) WLKCaseNodeTableViewConfig *tableViewConfig;

@property (weak, nonatomic) WLKCaseNode *rootNode;


+ (instancetype)nodeWithDictionary:(NSDictionary *)dic;

+ (instancetype)nodeWithSourceType:(NodeSourceType)type;
/**
 * 返回用于拼装Json的字典
 */
- (NSDictionary *)dictionaryForJson;

/**
 * cell node
 */
@property (nonatomic) NSInteger status;
/**
 * Json
 */
- (NSString *)jsonString;
/**
 * 添加一个子节点，应尽量使用这个方法添加，内部做了类型检查
 */
- (BOOL)addChildNode:(WLKCaseNode *)node;

/**
 * 删除一个子节点
 */
- (BOOL)removeChildNode:(WLKCaseNode *)node;

/**
 * 根据节点名删除一个子节点
 */
- (BOOL)removeChildNodeByName:(NSString *)nodeName;

/**
 * 从父节点删除自己
 */
- (void)removeFromParentNode;

/**
 * 返回子节点层级数
 */
- (NSInteger)countOfChildNodesHierarchy;

/**
 * 根据orderNum排序
 */
- (void)sortChildNodesByOrderNum;

/**
 * 选中节点
 */
- (void)selectChildNode:(WLKCaseNode *)node;

/**
 * 取消选中
 */
- (void)deselectChildNode:(WLKCaseNode *)node;

/**
 * 更改nodeContent，此方法会递归到根节点
 */
- (BOOL)changeNodeContent:(NSString *)nodeContent sender:(WLKCaseNode *)sender NS_DEPRECATED_IOS(3_0, 6_0);

/**
 * 选中的节点的nodeContent
 */
- (NSString *)selectedChildNodeContents;

/**
 * 清空选中的子节点和nodecontent
 */
- (void)clearSelected;

/**
 * 返回子节点名字数组
 */
- (NSMutableArray *)childNodeNames;
/**
 * 返回根据子节点的nodeName得到该子节点
 */
-(WLKCaseNode*)getNodeFromNodeChildArrayWithNodeName:(NSString*)nodeName;

/**
 * 返回所传节点的所有子节点的最后一级的所有节点
 */
+(NSArray*)getAllSubNodesFromParentNode:(WLKCaseNode*)node;

//-(instancetype)initWithCaseNode:(WLKCaseNode*)caseNode;
///返回某一个节点的nodeName为nodeName的子节点
+(WLKCaseNode*)getSubNodeFromNode:(WLKCaseNode*)node withNodeName:(NSString*)nodeName resultNode:(WLKCaseNode*)resultNode;

@end
