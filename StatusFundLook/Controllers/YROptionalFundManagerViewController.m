//
//  YROptionalFundManagerViewController.m
//  StatusFundLook
//
//  Created by yjs on 2020/12/31.
//

#import "YROptionalFundManagerViewController.h"

@interface YROptionalFundManagerViewController ()

@property (assign, nonatomic) FundManagerType managerType;
@property (weak) IBOutlet NSTextField *titleLab;
@property (weak) IBOutlet NSTextField *feTextField;

@end

@implementation YROptionalFundManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    if(self.managerType == FundManagerType_Delegate){
        self.titleLab.stringValue = @"当前基金已经存在您的自选列表中，您确定要执行删除操作吗？";
        self.feTextField.hidden = YES;
    }else{
        self.titleLab.stringValue = @"添加当前基金，请输入您的持有份额，方便盘中估算您的收益，如果不添加，默认份额为0";
        self.feTextField.hidden = NO;
    }
}

- (instancetype)initWithNibName:(NSNibName)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil managerType:(FundManagerType)type{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        self.managerType = type;
    }
    return self;
}

- (IBAction)cancelButtonClickEvent:(NSButton *)sender {
    [self dismissViewController:self];
}

- (IBAction)saveButtonClickEvent:(NSButton *)sender {
    FundModel *model = [[FundModel alloc]init];
    model.fundCode = self.fundModel[@"CODE"];
    model.fFe = self.feTextField.stringValue;
    
    if(self.managerType == FundManagerType_Delegate){
        [[YRFMDBManager sharedManager] delFundModel:model];
    }else{
        [[YRFMDBManager sharedManager] addFundModel:model];
    }
    
    [self dismissViewController:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_OptionalFundChangeSuccess object:nil];
}

@end
