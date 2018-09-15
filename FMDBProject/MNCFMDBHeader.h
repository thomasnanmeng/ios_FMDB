//
//  MNCFMDBHeader.h
//  FMDBProject
//
//  Created by thomasmeng on 2018/9/15.
//  Copyright © 2018年 thomasmeng. All rights reserved.
//

#ifndef MNCFMDBHeader_h
#define MNCFMDBHeader_h

/**
 *
 *  返回数据库的数据宏
 *
 */
#define RETURN_MESSAGE @"sender = %@,receiver = %@,messageID = %@, sessionType = %ld, messageContentType = %ld,messageStatus = %ld,messageContent = %@,sendDate = %@, contentUuid = %@",data.sender.userId,data.receiver.userId,data.messageId,data.sessionType,data.messageContentType,data.messageStatus,data.messageContent,data.sendDate,data.contentUuid

static NSInteger const FTCDataBaseUserInfoTableFetchKeyError = -1;

/**
 *
 *  数据库文件名重新定义
 *
 */

static NSString * const FTCMessageDataBaseFileName = @"3.sqlite";
//static NSString * const FTCMessageDataBaseFileName = @"mDataBase.sqlite";


/**
 *
 *  数据库中用户列表Table定义
 *
 */

static NSString * const FTCDataBaseUserInfoTable = @"userInfoTable";

/**
 *
 *  数据库MessageTable定义
 *
 */

static NSString * const FTCDataBaseMeaasgeTable = @"messageTable";

/**
 *  数据库的所有字段
 *
 */

//userinfo表
static NSString * const kFTCDataBaseTableColumnsKeySession = @"session";
static NSString * const kFTCDataBaseTableColumnsKeyUserImage = @"userImage";
static NSString * const kFTCDataBaseTableColumnsKeyFetchKey = @"fetchKey";
static NSString * const kFTCDataBaseTableColumnsKeySessionDate = @"sessionDate";
//message表

static NSString * const kFTCDataBaseTableColumnsKeyMessageID = @"messageID";
static NSString * const kFTCDataBaseTableColumnsKeyMessage = @"message";


#endif /* MNCFMDBHeader_h */
