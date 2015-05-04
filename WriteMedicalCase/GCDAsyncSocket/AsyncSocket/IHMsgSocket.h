//
//  IHMsgSocket.h
//  iosocket
//
//  Created by macHs on 14-2-25.
//  Copyright (c) 2014年 ihefe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IHGCDSocket.h"
#import "NSData+Zip.h"
#import "MessageObject.h"
#import <SystemConfiguration/SystemConfiguration.h>

@protocol IHMsgSocketDelegate;
@class IHSockRequest;
@interface  IHMsgSocket: NSObject<IHGCDSocketDelegate>

@property(nonatomic,weak)id<IHMsgSocketDelegate> delegate;

@property(nonatomic,strong)IHGCDSocket *IHGCDSocket;

@property(readwrite,strong)NSString *hostName;

@property(readwrite,assign)UInt16 hostPort;

@property (strong ,nonatomic) NSMutableDictionary *queueLists;//请求队列

@property (assign ,nonatomic) NSTimeInterval receiveTime;//超时时间

@property(nonatomic,assign)BOOL isPrint;

@property (nonatomic, strong) NSString *userStr;         //用户名
@property (nonatomic, strong) NSString *passwordStr;     //密码


@property (strong,nonatomic) void (^fail)(NSError *error);

+(IHMsgSocket *)sharedRequest;

-(void)sendMsg:(MessageObject *)msgObj;

-(void)connectToHost:(NSString *)host onPort:(UInt16 )port;

- (void)sendMsg:(MessageObject *)msgObj selector:(SEL)selector;

- (void)sendMsg:(MessageObject *)msgObj completed:(void (^)(IHSockRequest *data))completed failConnection:(void (^)(NSError *error))fail;

- (void)sendheartbeatToServer:(NSString *)alive;

- (void)reconnectServer;        //重连服务器

@end


@protocol IHMsgSocketDelegate <NSObject>
@required

@optional
- (void)connectServerSucceed:(IHMsgSocket *)ihGcdSock;        //连接服务器成功
- (void)connectServerDefeat:(IHMsgSocket *)ihGcdSock;         //连接服务器失败
- (void)ihSocket:(IHMsgSocket *)ihGcdSock didReceive:(IHSockRequest *)data;     //接收数据
- (void)ihSocket:(IHMsgSocket *)ihGcdSock  tag:(long )tag;            //发送
@end


//请求对象
@interface IHSockRequest : NSObject
@property (assign ,nonatomic) NSInteger opt;
@property (nonatomic, assign) NSInteger resp;
@property (strong ,nonatomic) NSString *sn;
@property (assign ,nonatomic) id requestData;
@property (assign,nonatomic)SEL selector;
@property (copy,nonatomic) void (^block)(IHSockRequest *data);
@property (strong ,nonatomic) id responseData;     //接收到的sync_data
@property (assign ,nonatomic) NSInteger status;//状态
@end
 
