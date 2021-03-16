//
//  YRSettingViewController.m
//  StatusFundLook
//
//  Created by yjs on 2021/1/4.
//

#import "YRSettingViewController.h"

static NSToolbarItemIdentifier leftIdentifier = @"left";
static NSToolbarItemIdentifier rightIdentifier = @"right";

@interface YRSettingViewController ()<NSToolbarDelegate>

@end

@implementation YRSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:@"toolbar"];
    [toolbar setSizeMode:NSToolbarSizeModeDefault];
    toolbar.allowsUserCustomization = NO;
    toolbar.autosavesConfiguration = YES;
    toolbar.displayMode = NSToolbarDisplayModeIconAndLabel;
    toolbar.delegate = self;
    //        [self.view setToolbar:toolbar];
    [self.view.window setToolbar:toolbar];
}

#pragma mark - NSToolbarDelegate
- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSToolbarItemIdentifier)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
    NSToolbarItem *toolbarItem = [[NSToolbarItem alloc] init];
    if ([itemIdentifier isEqualToString:leftIdentifier]) {
        toolbarItem = [self setToolbarItem:@"left"
                                     label:@"left"
                              paletteLable:@"left"
                                   toolTip:@"left tip"
                                     image:@"left"];
    } else if ([itemIdentifier isEqualToString:rightIdentifier]) {
        toolbarItem = [self setToolbarItem:@"right"
                                     label:@"right"
                              paletteLable:@"right"
                                   toolTip:@"right tip"
                                     image:@"right"];
    } else {
        return nil;
    }
    return toolbarItem;
}

- (NSToolbarItem *)setToolbarItem:(NSString *)identifier
                            label:(NSString *)label
                     paletteLable:(NSString *)paletteLable
                          toolTip:(NSString *)toolTip
                            image:(NSString *)image {
    NSToolbarItem *toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:identifier];
    toolbarItem.label = label;
    toolbarItem.paletteLabel = paletteLable;
    toolbarItem.toolTip = toolTip;
    toolbarItem.target = self;
    [toolbarItem setAction:@selector(itemClick:)];
    toolbarItem.image = [NSImage imageNamed:image];
    return toolbarItem;
}

- (NSArray<NSToolbarItemIdentifier> *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar {
    return @[NSToolbarSpaceItemIdentifier,
             leftIdentifier,
             rightIdentifier,
             NSToolbarSpaceItemIdentifier,
             NSToolbarShowColorsItemIdentifier];
}

- (NSArray<NSToolbarItemIdentifier> *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar {
    return @[leftIdentifier,
             rightIdentifier,
             NSToolbarShowColorsItemIdentifier,
             NSToolbarSpaceItemIdentifier];
}

#pragma mark - Action
- (void)itemClick:(NSToolbarItem *)item {
    
}
@end
