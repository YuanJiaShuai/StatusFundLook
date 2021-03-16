//
//  YROptionalFundManagerViewController.h
//  StatusFundLook
//
//  Created by yjs on 2020/12/31.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, FundManagerType) {
    FundManagerType_Delegate = 0,
    FundManagerType_Add = 1
};

@interface YROptionalFundManagerViewController : NSViewController

- (instancetype)initWithNibName:(NSNibName)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil managerType:(FundManagerType)type;

@property (strong, nonatomic) NSDictionary *fundModel;

@end

NS_ASSUME_NONNULL_END
