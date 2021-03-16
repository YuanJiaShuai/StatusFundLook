//
//  YRFMDBManager.h
//  StatusFundLook
//
//  Created by yjs on 2020/12/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FundModel : NSObject

/// 代码
@property (strong, nonatomic) NSString *fundCode;

/// 份额
@property (strong, nonatomic) NSString *fFe;

@end

@interface YRFMDBManager : NSObject

/// 初始化数据库表
+ (instancetype)sharedManager;

/// 获取所有数据
- (void)loadAllFundData:(void(^)(NSMutableArray *result))data;

/// 判断是否存在
/// @param fCode <#fCode description#>
- (void)existWithfCode:(NSString *)fCode result:(void(^)(BOOL exist))result;

/// 查询
/// @param fCodes 代码集合
/// @param result <#result description#>
- (void)queryFundWithCodes:(NSArray *)fCodes result:(void(^)(NSMutableArray *))result;

/// 更新
/// @param fundModel fundModel
- (void)updateFundModel:(FundModel *)fundModel;

/// 新增
/// @param fundModel <#fundModel description#>
- (void)addFundModel:(FundModel *)fundModel;

/// 删除
/// @param fundModel <#fundModel description#>
- (void)delFundModel:(FundModel *)fundModel;

@end

NS_ASSUME_NONNULL_END
