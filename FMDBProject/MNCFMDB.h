//
//  MNCFMDB.h
//  FMDBProject
//
//  Created by thomasmeng on 2018/9/15.
//  Copyright © 2018年 thomasmeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MNCFMDB : NSObject

/**
 *  数据库的单例模式，项目中只能存在一个
 *
 *  调用当前类所有公共接口
 *
 */

+ (MNCFMDB *)sharedInstance;

/**
 *  初始化数据库。用于创建数据库和创建userinfo表和message表
 *
 */

- (BOOL)initMessageDataBase;

/**
 *  添加用户ID   数据库中专门有一张表来维护用户的ID
 *
 *  参数说明：用户信息
 */

- (void)addSession:(NSString *)uesrID withFetchKey:(NSUInteger)fetchKey withSessionDate:(double)date;

/**
 *  删除用户信息  并且删除用户信息，不删除历史聊天记录
 *
 *  参数说明：用户信息
 */

- (void)deleteSession:(NSString *)userID;

/**
 *  得到所有用户的信息
 *
 *  @return  返回用户集合的数组
 */

//- (NSArray<FTCSessionModel *> *)getAllSession;

/**
 *  添加fetchKey,用于标记拉取到的第几条数据
 *
 */

- (void)updateFetchKey:(NSString *)userID withFetchKey:(NSUInteger)fetchKey;


/**
 添加session date
 
 @param userID 用户ID
 @param sessionDate 要更新的日期 double类型
 */
- (void)updateSessionDate:(NSString *)userID withSessionDate:(double)sessionDate;

/**
 *  得到当前拉取到的第多少条数据
 *
 *  @return  fetchKey
 */

- (NSUInteger)getFetchKey:(NSString *)userID;

/**
 *  向数据库中插入消息
 *
 *  参数一说明：确定插入的userID
 *
 *  参数二说明：生成的唯一ID，对应每一条message
 *
 *  参数三说明：消息
 *
 *  返回值：返回YES  为插入成功
 */

- (void)insertMessage:(NSString *)userID withMessageID:(NSString *)messageID withMessage:(NSString *)message;

/**
 *  删除数据库中的一条消息
 *
 *  参数一说明：确定删除的哪一条userID的消息
 *
 *  参数二说明：生成的唯一ID，对应每一条message
 *
 */

- (BOOL)deleteMessageWithOnlyOne:(NSString *)userID withMessageID:(NSString *)messageID;

/**
 *  删除私聊或者群聊中所有的聊天的消息，
 *
 *  参数说明：要删除的每个userID
 *
 *  返回值：返回YES  为删除成功
 */

- (void)deleteAllMessage:(NSString *)userID;

/**
 *  得到一条会话或者群聊的所有聊天数据
 *
 *  @return NSMutableDictionary  key：messageID  value：message
 */

- (NSArray *)getAllMessage:(NSString *)userID;

/**
 *  获取一定数量的message，从当前条往上,如果messageID = nil ,直接拉取最后20条数据;如果messageCount= 0;直接拉取最后的一条数据
 *
 *  参数一：user
 *
 *  参数二：当前消息ID
 *
 *  参数三：当前消息往上的若干条消息
 */

- (NSArray *)getPartMessage:(NSString *)userID withMessageID:(NSString *)messageID withMessageCount:(NSUInteger)messageCount;

/**
 *  删除多条数据
 *
 *  参数一：user
 *
 *  参数二：删除的messageID
 *
 */

- (void)deletePartMessage:(NSArray *)userID withPartMessageID:(NSArray *)messageID;

/**
 *  得到每个好友的最新的一条消息
 *
 *  @return NSMutableDictionary  key：messageID  value：message
 */

- (NSString *)getLatestMessage:(NSString *)userID;

/**
 *  测试用例支持代码
 *  得到所有的表
 *
 *  @return NSArray 一个表名集合
 */

- (NSArray *)getAllTable;

/**
 *  测试用例支持代码
 *
 *  删除某个表
 */

- (void)dropTable:(NSString *)table;
@end
