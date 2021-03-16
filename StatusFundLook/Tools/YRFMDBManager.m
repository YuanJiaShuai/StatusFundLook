//
//  YRFMDBManager.m
//  StatusFundLook
//
//  Created by yjs on 2020/12/30.
//

#import "YRFMDBManager.h"
#import <FMDB.h>
#import <objc/runtime.h>
#import <objc/objc.h>

#define FUND_TABLE_NAME @"FundInfo"

@implementation FundModel

@end

@interface YRFMDBManager()

@property (strong, nonatomic) FMDatabaseQueue *queueDb;

@end

@implementation YRFMDBManager

+ (instancetype)sharedManager{
    static dispatch_once_t onceToken;
    static YRFMDBManager *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
        [instance initDataBase];
    });
    return instance;
}

- (void)initDataBase{
    //老地址
    NSString *docuPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *dbPath = [docuPath stringByAppendingPathComponent:@"Fund.db"];
    NSLog(@"!!!dbPath = %@",dbPath);

    //新地址
//    NSError *error = nil;
//    NSURL *groupURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.fundlook"];
//    NSURL *fileURL = [groupURL URLByAppendingPathComponent:@"Fund.db"];
//    NSLog(@"!!!fileURL.path = %@",fileURL.path);
//
//    //复制文件
//    BOOL copyResult = [[NSFileManager defaultManager] copyItemAtPath:dbPath toPath:fileURL.path error:&error];
//    NSLog(@"copyResult = %d", copyResult);
    
    self.queueDb = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    
    [self.queueDb inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *existsSql = [NSString stringWithFormat:@"select count(name) as countNum from sqlite_master where type = 'table' and name = '%@'", FUND_TABLE_NAME];
        FMResultSet *rs = [db executeQuery:existsSql];
        if ([rs next]) {
            NSInteger count = [rs intForColumn:@"countNum"];
            NSLog(@"The table count: %li", count);
            if (count == 1) {
                NSLog(@"存在");
                return;
            }else{
                NSString *sql = [NSString stringWithFormat:@"create table %@(fundCode varchar(255), fFe varchar(255))", FUND_TABLE_NAME];
                BOOL result = [db executeUpdate:sql];
                if(result){
                    
                }else{
                    
                }
            }
        }
        
        [db close];
    }];
    [self.queueDb close];
}

- (void)loadAllFundData:(void (^)(NSMutableArray * _Nonnull))data{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    [self.queueDb inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *res = [db executeQuery:[NSString stringWithFormat:@"select * from %@", FUND_TABLE_NAME]];
        NSArray *keys = [self allPropertyNames];
        while ([res next]) {
            FundModel *model = [[FundModel alloc]init];
            for(NSString *key in keys){
                [model setValue:[res stringForColumn:key] forKey:key];
            }
            [dataArray addObject:model];
        }
        
        data(dataArray);
        [db close];
    }];
    [self.queueDb close];
}

- (void)updateFundModel:(FundModel *)fundModel{
    [self.queueDb inDatabase:^(FMDatabase * _Nonnull db) {
        NSArray *keys = [self allPropertyNames];
        NSMutableString *sql = [[NSMutableString alloc]init];
        for(NSString *key in keys){
            id obj = [fundModel valueForKey:key];
            if(![obj isKindOfClass:[NSNull class]] && obj){
                if(sql.length == 0){
                    [sql appendFormat:@"%@ = '%@'", key, [fundModel valueForKey:key]];
                }else{
                    [sql appendFormat:@",%@ = '%@'", key, [fundModel valueForKey:key]];
                }
            }
        }
        
        NSString *updateSql = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE fundCode = '%@'", FUND_TABLE_NAME, sql, fundModel.fundCode];
        [db executeUpdate:updateSql];
        
        [db close];
    }];
    [self.queueDb close];
}

- (void)addFundModel:(FundModel *)fundModel{
    [self.queueDb inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *inserSql = [NSString stringWithFormat:@"INSERT INTO %@ VALUES('%@', '%@')", FUND_TABLE_NAME, fundModel.fundCode, fundModel.fFe];
        [db executeUpdate:inserSql];
        [db close];
    }];
    [self.queueDb close];
}

- (void)delFundModel:(FundModel *)fundModel{
    [self.queueDb inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *execSql = [NSString stringWithFormat:@"delete from %@ where fundCode = '%@'", FUND_TABLE_NAME, fundModel.fundCode];
        [db executeUpdate:execSql];
        [db close];
    }];
    [self.queueDb close];
}

- (void)queryFundWithCodes:(NSArray *)fCodes result:(void(^)(NSMutableArray *))result;{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    
    NSMutableString *sqlSub = [[NSMutableString alloc]init];
    for(NSString *fCode in fCodes){
        if(sqlSub.length == 0){
            [sqlSub appendFormat:@"'%@'", fCode];
        }else{
            [sqlSub appendFormat:@",'%@'", fCode];
        }
    }
    [self.queueDb inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *res = [db executeQuery:[NSString stringWithFormat:@"select * from %@ where fundCode in(%@)", FUND_TABLE_NAME, sqlSub]];
        NSArray *keys = [self allPropertyNames];
        while ([res next]) {
            FundModel *model = [[FundModel alloc]init];
            for(NSString *key in keys){
                [model setValue:[res stringForColumn:key] forKey:key];
            }
            [dataArray addObject:model];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            result(dataArray);
        });
        
        [db close];
    }];
    [self.queueDb close];
}

- (void)existWithfCode:(NSString *)fCode result:(void (^)(BOOL))result{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    [self.queueDb inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *res = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE fundCode = '%@'", FUND_TABLE_NAME, fCode]];
        NSArray *keys = [self allPropertyNames];
        while ([res next]) {
            FundModel *model = [[FundModel alloc]init];
            for(NSString *key in keys){
                [model setValue:[res stringForColumn:key] forKey:key];
            }
            [dataArray addObject:model];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            result(dataArray.count);
        });
        
        [db close];
    }];
    [self.queueDb close];
}

- (NSArray *)allPropertyNames{
    //存储所有的属性名称
    NSMutableArray *allNames = [[NSMutableArray alloc] init];
    //存储属性的个数
    unsigned int propertyCount = 0;
    ///通过运行时获取当前类的属性
    objc_property_t *propertys = class_copyPropertyList([FundModel class], &propertyCount);
    //把属性放到数组中
    for (int i = 0; i < propertyCount; i ++) {
        ///取出第一个属性
        objc_property_t property = propertys[i];
        const char * propertyName = property_getName(property);
        [allNames addObject:[NSString stringWithUTF8String:propertyName]];
    }
    //释放
    free(propertys);
    return allNames;
}

@end
