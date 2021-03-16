//
//  YRStatusPopcoverManager.m
//  StatusFundLook
//
//  Created by yjs on 2020/12/30.
//

#import "YRStatusPopcoverManager.h"

@interface YRStatusPopcoverManager()

//@property (strong, nonatomic) NSPopover *popover;
//@property (strong, nonatomic) YRPopoverViewController *popController;

@end

@implementation YRStatusPopcoverManager

+ (instancetype)sharedSingleton{
    static YRStatusPopcoverManager *_sharedSingleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //不能再使用alloc方法
        //因为已经重写了allocWithZone方法，所以这里要调用父类的分配空间的方法
        _sharedSingleton = [[super allocWithZone:NULL] init];
    });
    return _sharedSingleton;
}

// 防止外部调用alloc 或者 new
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [YRStatusPopcoverManager sharedSingleton];
}

- (NSPopover *)popover{
    if(!_popover){
        _popover = [[NSPopover alloc]init];
        _popover.animates = YES;
        _popover.contentViewController = self.popController;
        _popover.behavior = NSPopoverBehaviorTransient;
    }
    return _popover;
}

- (YRPopoverViewController *)popController{
    if(!_popController){
        _popController = [[YRPopoverViewController alloc]initWithNibName:@"YRPopoverViewController" bundle:nil];
    }
    return _popController;
}

- (void)loadData{
    [self.popController sendRequestUpdata];
}

@end
