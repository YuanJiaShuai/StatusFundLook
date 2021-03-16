//
//  YRStatusPopcoverManager.h
//  StatusFundLook
//
//  Created by yjs on 2020/12/30.
//

#import <Foundation/Foundation.h>
#import "YRPopoverViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface YRStatusPopcoverManager : NSObject

+ (instancetype)sharedSingleton;

@property (strong, nonatomic) NSPopover *popover;

@property (strong, nonatomic) YRPopoverViewController *popController;

/// 获取数据
- (void)loadData;

@end

NS_ASSUME_NONNULL_END
