//
//  YRIndexStockView.m
//  StatusFundLook
//
//  Created by yjs on 2020/12/30.
//

#import "YRIndexStockView.h"

@interface YRIndexStockView()

/// 股票名称
@property (weak) IBOutlet NSTextField *nameText;

/// 最新价
@property (weak) IBOutlet NSTextField *priceText;

/// 涨跌额
@property (weak) IBOutlet NSTextField *leftText;

/// 涨跌幅
@property (weak) IBOutlet NSTextField *rightText;

@end

@implementation YRIndexStockView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)setRealtime:(NSDictionary *)realtime{
    if(realtime && [realtime isKindOfClass:[NSDictionary class]]){
        self.nameText.stringValue = realtime[@"f14"];
        
        NSColor *valueColor = [YRTools colorOfValue:realtime[@"f4"]];
        self.priceText.stringValue = [NSString stringWithFormat:@"%0.2f", [realtime[@"f2"] doubleValue]];
        self.priceText.textColor = valueColor;
        
        self.leftText.stringValue = [NSString stringWithFormat:@"%0.2f", [realtime[@"f4"] doubleValue]];
        self.leftText.textColor = valueColor;
        
        self.rightText.stringValue = [NSString stringWithFormat:@"%0.2f%%", [realtime[@"f3"] doubleValue]];
        self.rightText.textColor = valueColor;
    }
}
@end
