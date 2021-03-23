//
//  YRPopoverViewController.m
//  StatusFundLook
//
//  Created by yjs on 2020/12/30.
//

#import "YRPopoverViewController.h"
#import "YRSearchViewController.h"
#import "YRSettingViewController.h"
#import "AppDelegate.h"
#import "YRIndexStockView.h"
#import "YRHelpViewController.h"

@interface YRPopoverViewController ()<NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate>

@property (weak) IBOutlet NSButton *addOptionalBtn;
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet YRIndexStockView *oneIndexView;
@property (weak) IBOutlet YRIndexStockView *twoIndexView;
@property (weak) IBOutlet YRIndexStockView *threeIndexView;

@property (strong, nonatomic) NSMutableArray *fundArray;

@property (weak) IBOutlet NSTextField *todayProfitLab;
@property (weak) IBOutlet NSTextField *yesterdayProfitLab;
@property (weak) IBOutlet NSTextField *allProfitLab;

@property (strong, nonatomic) NSTimer *timer;

@property (strong, nonatomic) NSPopover *helpPopover;
@property (strong, nonatomic) YRHelpViewController *helpPopController;
@end

@implementation YRPopoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendRequestUpdata) name:Notification_OptionalFundChangeSuccess object:nil];
    
    [self sendRequestUpdateIndex];
    
    [self sendRequestUpdata];
    
    self.timer = [NSTimer timerWithTimeInterval:3 target:self selector:@selector(timerEvent) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    [self.timer fire];
}

#pragma mark - Private Functions
- (void)timerEvent{
    //判断交易时间
    if([YRTools isTransactionTime]){
        [self sendRequestUpdateIndex];
    }
}

- (void)calculateTodayProfitWithFundArray:(NSArray *)fundArray{
    __block CGFloat todayProfit = 0.0;
    __block CGFloat yestodyProfit = 0.0;
    __block CGFloat allProfit = 0.0;
    
    NSMutableArray *fCodeArr = [[NSMutableArray alloc]init];
    for(NSDictionary *fundModel in fundArray){
        [fCodeArr addObject:fundModel[@"FCODE"]];
    }
    
    [[YRFMDBManager sharedManager] queryFundWithCodes:fCodeArr result:^(NSMutableArray * _Nonnull result) {
        for(FundModel *model in result){
            for(NSDictionary *fundModel in fundArray){
                if([model.fundCode isEqualToString:fundModel[@"FCODE"]]){
                    CGFloat netProfit = [fundModel[@"GSZ"] doubleValue] - [fundModel[@"NAV"] doubleValue];
                    todayProfit = todayProfit + [model.fFe doubleValue] * netProfit;
                    
                    CGFloat yesterdayNetProfit = [fundModel[@"NAV"] doubleValue] - [fundModel[@"NAV"] doubleValue]/(1 + ([fundModel[@"NAVCHGRT"] doubleValue]/100));
                    yestodyProfit = yestodyProfit + [model.fFe doubleValue] * yesterdayNetProfit;
                    
                    CGFloat gsz = ([fundModel[@"GSZ"] doubleValue] - [model.uCost doubleValue]);
                    allProfit = allProfit + [model.fFe doubleValue] * gsz;
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *value = [YRTools unSignDoubleOfValue:todayProfit];
            NSString *yesterdayValue = [YRTools unSignDoubleOfValue:yestodyProfit];
            NSString *allValue = [YRTools unSignDoubleOfValue:allProfit];
            
            self.todayProfitLab.stringValue = value;
            self.todayProfitLab.textColor = [YRTools colorOfValue:value];

            self.yesterdayProfitLab.stringValue = yesterdayValue;
            self.yesterdayProfitLab.textColor = [YRTools colorOfValue:yesterdayValue];
            
            self.allProfitLab.stringValue = allValue;
            self.allProfitLab.textColor = [YRTools colorOfValue:allValue];
        });
    }];
}

#pragma mark - Request Functions
- (void)sendRequestUpdata{
    [[YRFMDBManager sharedManager] loadAllFundData:^(NSMutableArray * _Nonnull result) {
        NSMutableString *fCodes = [[NSMutableString alloc]init];
        for(FundModel *model in result){
            if(fCodes.length == 0){
                [fCodes appendString:model.fundCode];
            }else{
                [fCodes appendFormat:@",%@", model.fundCode];
            }
        }
        
        [self requestFundDataWihtCodes:fCodes];
    }];
}

- (void)requestFundDataWihtCodes:(NSString *)fCodes{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/javascript",@"text/html",@"text/plain",@"application/atom+xml",@"application/xml",@"text/xml,application/x-javascript",nil];
    
    NSString *url = [NSString stringWithFormat:@"https://fundmobapi.eastmoney.com/FundMNewApi/FundMNFInfo?pageIndex=1&pageSize=50&plat=Android&appType=ttjj&product=EFund&Version=1&deviceid=3f998f06-d80c-4eb7-988d-44da0f3a0841&Fcodes=%@", fCodes];
    [manager GET:url parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSInteger TotalCount = [responseObject[@"TotalCount"] integerValue];
        if(TotalCount != 0){
            NSArray *diff = responseObject[@"Datas"];
            self.fundArray = [[NSMutableArray alloc]initWithArray:diff];
            [self.tableView reloadData];
            
            [self calculateTodayProfitWithFundArray:self.fundArray];
        }else{
            self.fundArray = [[NSMutableArray alloc]init];
            [self.tableView reloadData];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

- (void)sendRequestUpdateIndex{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/javascript",@"text/html",@"text/plain",@"application/atom+xml",@"application/xml",@"text/xml,application/x-javascript",nil];
    
    [manager GET:@"https://push2.eastmoney.com/api/qt/ulist.np/get?fltt=2&fields=f2,f3,f4,f12,f14&secids=1.000001,0.399001,0.399006" parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *diff = responseObject[@"data"][@"diff"];
        [diff enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if(idx == 0){
                self.oneIndexView.realtime = obj;
            }else if(idx == 1){
                self.twoIndexView.realtime = obj;
            }else if(idx == 2){
                self.threeIndexView.realtime = obj;
            }
        }];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

#pragma mark - NSTableViewDelegate
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return self.fundArray.count;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row{
    return YES;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    NSDictionary *fundModel = self.fundArray[row];
    
    if (tableColumn == tableView.tableColumns[0]) {
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"yrCell1" owner:nil];
        cell.textField.stringValue = [NSString stringWithFormat:@"%@ [%@]", fundModel[@"SHORTNAME"], fundModel[@"FCODE"]];
        return cell;
    }else if(tableColumn == tableView.tableColumns[1]){
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"yrCell2" owner:nil];
        cell.textField.stringValue = [NSString stringWithFormat:@"%@%%", fundModel[@"GSZZL"]];
        cell.textField.textColor = [YRTools colorOfValue:fundModel[@"GSZZL"]];
        return cell;
    }else if(tableColumn == tableView.tableColumns[2]){
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"yrCell3" owner:nil];
        [[YRFMDBManager sharedManager] queryFundWithCodes:@[fundModel[@"FCODE"]] result:^(NSMutableArray * _Nonnull result) {
            if(result.count > 0){
                FundModel *fModel = [result firstObject];
                
                CGFloat fe = [fModel.fFe doubleValue];
                CGFloat rate = [fundModel[@"GSZ"] doubleValue] * [fundModel[@"GSZZL"] doubleValue]/100 * fe;
                cell.textField.stringValue = [NSString stringWithFormat:@"%0.2f", rate];
                cell.textField.textColor = [YRTools colorOfValue:cell.textField.stringValue];
            }
        }];
        return cell;
    }else{
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"yrCell4" owner:nil];
        [[YRFMDBManager sharedManager] queryFundWithCodes:@[fundModel[@"FCODE"]] result:^(NSMutableArray * _Nonnull result) {
            if(result.count > 0){
                FundModel *fModel = [result firstObject];
                cell.textField.stringValue = [NSString stringWithFormat:@"%0.2f", [fModel.fFe doubleValue]];
            }
        }];
        cell.textField.delegate = self;
        return cell;
    }
}

- (void)controlTextDidEndEditing:(NSNotification *)obj{
    NSTextField *tf = obj.object;
    NSTableCellView *cellView = (NSTableCellView *)[tf superview];
    NSTableRowView *rowView = (NSTableRowView *)[cellView superview];
    NSInteger row = [self.tableView rowForView: rowView];
    
    NSDictionary *fundModel = self.fundArray[row];
    
    [[YRFMDBManager sharedManager] queryFundWithCodes:@[fundModel[@"FCODE"]] result:^(NSMutableArray * _Nonnull result) {
        if(result.count > 0){
            FundModel *fModel = [result firstObject];
            fModel.fFe = tf.stringValue;
            [[YRFMDBManager sharedManager] updateFundModel:fModel];
            [self sendRequestUpdata];
        }
    }];
}

#pragma mark - Action Functions
- (IBAction)addOptionalButtonEvent:(NSButton *)sender {
    if([[YRStatusPopcoverManager sharedSingleton].popover isShown]){
        [[YRStatusPopcoverManager sharedSingleton].popover close];
        
        YRSearchViewController *searchVc = [[YRSearchViewController alloc]initWithNibName:@"YRSearchViewController" bundle:nil];
        [self presentViewControllerAsModalWindow:searchVc];
        
//        YRSettingViewController *searchVc = [[YRSettingViewController alloc]initWithNibName:@"YRSettingViewController" bundle:nil];
//        [self presentViewControllerAsModalWindow:searchVc];
    }
}

- (IBAction)updateButtonEvent:(NSButton *)sender {
    [self sendRequestUpdata];
    [self sendRequestUpdateIndex];
}

- (IBAction)exitButtonEvent:(NSButton *)sender {
    [NSApp terminate:nil];
}

- (IBAction)deleteOptionalFundEvent:(NSMenuItem *)sender {
    NSInteger row = [sender.menu.identifier integerValue];
    
    NSDictionary *fundModel = self.fundArray[row];
    
    FundModel *model = [[FundModel alloc]init];
    model.fundCode = fundModel[@"FCODE"];
    [[YRFMDBManager sharedManager] delFundModel:model];
    [self sendRequestUpdata];
}

- (IBAction)helpButtonClickEvent:(NSButton *)sender {
    if(self.helpPopover.isShown){
        [self.helpPopover performClose:sender];
    }else{
        [NSApp activateIgnoringOtherApps:YES];
        [self.helpPopover showRelativeToRect:sender.bounds ofView:sender preferredEdge:NSRectEdgeMinX];
    }
}

#pragma mark - lazyLoad
- (NSPopover *)helpPopover{
    if(!_helpPopover){
        _helpPopover = [[NSPopover alloc]init];
        _helpPopover.animates = YES;
        _helpPopover.contentViewController = self.helpPopController;
        _helpPopover.behavior = NSPopoverBehaviorTransient;
    }
    return _helpPopover;
}

- (YRHelpViewController *)helpPopController{
    if(!_helpPopController){
        _helpPopController = [[YRHelpViewController alloc]initWithNibName:@"YRHelpViewController" bundle:nil];
    }
    return _helpPopController;
}
@end
