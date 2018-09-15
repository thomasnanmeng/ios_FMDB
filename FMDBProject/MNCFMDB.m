//
//  MNCFMDB.m
//  FMDBProject
//
//  Created by thomasmeng on 2018/9/15.
//  Copyright © 2018年 thomasmeng. All rights reserved.
//

#import "MNCFMDB.h"
#import "FMDB.h"
#import "MNCFMDBHeader.h"
@interface MNCFMDB ()
@property (strong, nonatomic) FMDatabaseQueue *queue;
@end

@implementation MNCFMDB

#pragma mark - Life cycle

+ (MNCFMDB *)sharedInstance {
    static MNCFMDB *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MNCFMDB alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

#pragma mark - Public methods

- (BOOL)initMessageDataBase {
    //创建数据库
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:FTCMessageDataBaseFileName];
    self.queue = [FMDatabaseQueue databaseQueueWithPath:filePath];
    NSLog(@"数据路路径：%@",filePath);
    __block BOOL isSuccess = NO;
    [self.queue inDatabase:^(FMDatabase *db) {
        NSString *userTable = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' (session varchar(256) primary key, profileURL varchar(256), fetchKey integer, sessionDate double)",FTCDataBaseUserInfoTable];
        BOOL isUserInfoSuccess = [db executeUpdate:userTable];
        //创建message表
        NSString *messageTable = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' (id INTEGER PRIMARY KEY AUTOINCREMENT,session varchar(256), messageID varchar(256), message varchar(256))",FTCDataBaseMeaasgeTable];
        BOOL isMessageSuccess = [db executeUpdate:messageTable];
        if (isUserInfoSuccess && isMessageSuccess) {
            NSLog(@"创建数据库成功!");
            isSuccess = YES;
        } else {
            NSLog(@"创建数据库失败！");
            isSuccess = NO;
        }
    }];
    return isSuccess;
}

//- (NSArray<FTCSessionModel *> *)getAllSession {
//    NSMutableArray *userArray = [[NSMutableArray alloc] init];
//    [self.queue inDatabase:^(FMDatabase *db) {
//        NSString *selectSQL = [NSString stringWithFormat:@"SELECT * FROM '%@'",FTCDataBaseUserInfoTable];
//        FMResultSet *res = [db executeQuery:selectSQL];
//        while ([res next]) {
//            if (![res stringForColumn:kFTCDataBaseTableColumnsKeySession]) {
//                continue;
//            }
//            NSString *userId = [res stringForColumn:kFTCDataBaseTableColumnsKeySession];
//            double sessionDate = [res doubleForColumn:kFTCDataBaseTableColumnsKeySessionDate];
//            FTCUserModel *user = [[FTCUserModel alloc] init];
//            user.userId = userId;
//            FTCSessionModel *session = [[FTCSessionModel alloc] init];
//            session.sessionDate = [NSDate dateWithTimeIntervalSince1970:sessionDate];
//            [session addUser:user];
//            
//            [userArray addObject:session];
//        }
//    }];
//    return userArray;
//}

- (void)addSession:(NSString *)userID withFetchKey:(NSUInteger)fetchKey withSessionDate:(double)date {
    if (!userID) {
        return;
    }
    [self.queue inDatabase:^(FMDatabase *db) {
        [db beginTransaction];
        NSString *insertUserInfoSQL = [NSString stringWithFormat:@"INSERT INTO '%@'(session,fetchKey,sessionDate) values(?,?,?)",FTCDataBaseUserInfoTable];
        BOOL isSuccess = [db executeUpdate:insertUserInfoSQL,userID, @(fetchKey), @(date)];
        if (isSuccess) {
            NSLog(@"好友信息存储完成！");
        } else {
            NSLog(@"好友信息存储失败！");
            [db rollback];
        }
        [db commit];
    }];
}

- (void)deleteSession:(NSString *)userID {
    if (!userID) {
        return;
    }
    [self.queue inDatabase:^(FMDatabase *db) {
        NSString *deleteUserInfoSQL = [NSString stringWithFormat:@"DELETE FROM '%@' WHERE session = ?",FTCDataBaseUserInfoTable];
        BOOL isSuccess = [db executeUpdate:deleteUserInfoSQL,userID];
        if (!isSuccess) {
            NSLog(@"删除好友信息失败");
        }
    }];
}

- (void)updateFetchKey:(NSString *)userID withFetchKey:(NSUInteger)fetchKey {
    if (!userID) {
        return;
    }
    [self.queue inDatabase:^(FMDatabase *db) {
        [db beginTransaction];
        NSString *updateSQL = [NSString stringWithFormat:@"UPDATE '%@' SET fetchKey = ? WHERE session = ?",FTCDataBaseUserInfoTable];
        BOOL isSuccess = [db executeUpdate:updateSQL,@(fetchKey),userID];
        if (!isSuccess) {
            [db rollback];
        }
        [db commit];
    }];
}

- (void)updateSessionDate:(NSString *)userID withSessionDate:(double)sessionDate {
    if (!userID) {
        return;
    }
    [self.queue inDatabase:^(FMDatabase *db) {
        [db beginTransaction];
        NSString *updateSQL = [NSString stringWithFormat:@"UPDATE '%@' SET sessionDate = ? WHERE session = ?",FTCDataBaseUserInfoTable];
        BOOL isSuccess = [db executeUpdate:updateSQL,@(sessionDate),userID];
        if (!isSuccess) {
            [db rollback];
        }
        [db commit];
    }];
}

- (NSUInteger)getFetchKey:(NSString *)userID {
    __block NSInteger fetchKey = 0;
    [self.queue inDatabase:^(FMDatabase *db) {
        NSString *selectSQL = [NSString stringWithFormat:@"SELECT fetchKey FROM '%@' WHERE session = ?",FTCDataBaseUserInfoTable];
        FMResultSet *res = [db executeQuery:selectSQL,userID];
        while ([res next]) {
            if ([res intForColumn:kFTCDataBaseTableColumnsKeyFetchKey]) {
                fetchKey = [res intForColumn:kFTCDataBaseTableColumnsKeyFetchKey];
            }
        }
    }];
    return fetchKey;
}

- (void)insertMessage:(NSString *)userID withMessageID:(NSString *)messageID withMessage:(NSString *)message {
    [self.queue inDatabase:^(FMDatabase *db) {
        [db beginTransaction];
        NSString *insertChatSQL = [NSString stringWithFormat:@"INSERT INTO '%@' (session,messageID,message) values(?,?,?)",FTCDataBaseMeaasgeTable];
        BOOL isSuccess = [db executeUpdate:insertChatSQL,userID,messageID,message];
        if (isSuccess) {
        } else {
            NSLog(@"插入数据库失败");
            [db rollback];
        }
        [db commit];
    }];
}

- (BOOL)deleteMessageWithOnlyOne:(NSString *)userID withMessageID:(NSString *)messageID {
    if (!userID || !messageID) {
        return NO;
    }
    __block BOOL isSuccess = NO;
    [self.queue inDatabase:^(FMDatabase *db) {
        NSString *deleteMessageSQL = [NSString stringWithFormat:@"DELETE FROM '%@' WHERE session = ? AND messageID = ?",FTCDataBaseMeaasgeTable];
        BOOL isSuccess = [db executeUpdate:deleteMessageSQL,userID,messageID];
        if (isSuccess) {
            isSuccess = YES;
        }
    }];
    return isSuccess;
}

- (void)deleteAllMessage:(NSString *)userID {
    if (!userID) {
        return;
    }
    [self.queue inDatabase:^(FMDatabase *db) {
        NSString *deleteMessageSQL = [NSString stringWithFormat:@"DELETE FROM '%@' WHERE session = ?",FTCDataBaseMeaasgeTable];
        BOOL isSuccess = [db executeUpdate:deleteMessageSQL,userID];
        if (isSuccess) {
            NSLog(@"删除数据成功！");
        } else {
            NSLog(@"删除数据失败");
        }
    }];
}

- (NSArray *)getAllMessage:(NSString *)userID {
    if (!userID) {
        return nil;
    }
    NSMutableArray *messageArray = [[NSMutableArray alloc] init];
    [self.queue inDatabase:^(FMDatabase *db) {
        NSString *selectSQL = [NSString stringWithFormat:@"SELECT * FROM '%@' WHERE session = ? order by id",FTCDataBaseMeaasgeTable];
        FMResultSet *res = [db executeQuery:selectSQL,userID];
        while ([res next]) {
            if (![res stringForColumn:kFTCDataBaseTableColumnsKeyMessage]) {
                continue;
            }
            NSString *message = [res stringForColumn:kFTCDataBaseTableColumnsKeyMessage];
            if (!message) {
                continue;
            } else {
                [messageArray addObject:message];
            }
        }
    }];
    return messageArray;
}

- (NSString *)getLatestMessage:(NSString *)userID {
    __block NSString *message = [[NSString alloc] init];
    [self.queue inDatabase:^(FMDatabase *db) {
        NSString *selectSQL = [NSString stringWithFormat:@"SELECT * FROM '%@' WHERE session = ? order by id DESC limit 1",FTCDataBaseMeaasgeTable];
        FMResultSet *res = [db executeQuery:selectSQL,userID];
        while ([res next]) {
            message = [res stringForColumn:kFTCDataBaseTableColumnsKeyMessage];
        }
    }];
    return message;
}

- (NSArray *)getPartMessage:(NSString *)userID withMessageID:(NSString *)messageID withMessageCount:(NSUInteger)messageCount {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [self.queue inDatabase:^(FMDatabase *db) {
        if (0 == messageCount) {
            [self getLatestMessage:userID];
            [array addObject:userID];
        } else if (!messageID) {
            NSString *selectSQL = [NSString stringWithFormat:@"SELECT * FROM (SELECT * FROM '%@' WHERE session = ? order by id DESC limit %ld) order by id ASC",FTCDataBaseMeaasgeTable, messageCount];
            FMResultSet *res = [db executeQuery:selectSQL,userID];
            while ([res next]) {
                NSString *message = [res stringForColumn:kFTCDataBaseTableColumnsKeyMessage];
                [array addObject:message];
            }
        } else {
            NSString *selectSQL = [NSString stringWithFormat:@"SELECT * FROM (SELECT * FROM '%@' WHERE session = ?  AND id < (SELECT id from '%@' WHERE messageID = ?) order by id DESC limit ?) order by id ASC",FTCDataBaseMeaasgeTable,FTCDataBaseMeaasgeTable];
            FMResultSet *res = [db executeQuery:selectSQL,userID,messageID,@(messageCount)];
            while ([res next]) {
                NSString *selectMessage = [res stringForColumn:kFTCDataBaseTableColumnsKeyMessage];
                [array addObject:selectMessage];
            }
        }
    }];
    return array;
}

- (void)deletePartMessage:(NSArray *)userID withPartMessageID:(NSArray *)messageID {
    [self.queue inDatabase:^(FMDatabase *db) {
        [db beginTransaction];
        for (NSUInteger i = 0; i < userID.count; i ++) {
            for (NSUInteger j = 0; j < messageID.count; j ++) {
                BOOL isSuccess = [self deleteMessageWithOnlyOne:userID[i] withMessageID:messageID[j]];
                if (!isSuccess) {
                    [db rollback];
                }
            }
        }
        [db commit];
    }];
}

#pragma mark - dataBaseTese

- (NSArray *)getAllTable {
    NSMutableArray *tableArray = nil;
    [self.queue inDatabase:^(FMDatabase *db) {
        NSString * sql = [[NSString alloc]initWithFormat:@"SELECT name FROM sqlite_master"];
        FMResultSet * res = [db executeQuery:sql];
        NSMutableArray *tableArray = nil;
        while ([res next]) {
            [tableArray addObject:[res stringForColumn:@"name"]];
            NSLog(@"table is __%@",[res stringForColumn:@"name"]);
        }
    }];
    return tableArray;
}

- (void)dropTable:(NSString *)table {
    [self.queue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"DROP TABLE '%@'",table];
        BOOL isSuccess = [db executeUpdate:sql];
        if (isSuccess) {
            NSLog(@"Drop table  seccuss !");
        } else {
            NSLog(@"Drop table  failed !");
        }
    }];
}

@end
