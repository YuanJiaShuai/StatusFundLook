//
//  AppDelegate.m
//  StatusFundLook
//
//  Created by yjs on 2020/12/30.
//

#import "AppDelegate.h"
#import "YRPopoverViewController.h"
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate ()

@property (strong, nonatomic) NSStatusItem *statusItem;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem.button setImage:[NSImage imageNamed:@"ic_icon"]];
    [self.statusItem.button setAction:@selector(statusItemButtonClickEvent:)];
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:UNAuthorizationOptionAlert | UNAuthorizationOptionSound completionHandler:^(BOOL granted, NSError * _Nullable error) {
        
    }];
    
    [self addLocalNotice];
}

- (void)statusItemButtonClickEvent:(id)sender{
    if([YRStatusPopcoverManager sharedSingleton].popover.isShown){
        [[YRStatusPopcoverManager sharedSingleton].popover performClose:sender];
    }else{
        [NSApp activateIgnoringOtherApps:YES];
        [[YRStatusPopcoverManager sharedSingleton].popover showRelativeToRect:self.statusItem.button.bounds ofView:self.statusItem.button preferredEdge:NSRectEdgeMinY];
        [[YRStatusPopcoverManager sharedSingleton] loadData];
    }
}

- (void)addLocalNotice{
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    // 标题
    content.title = @"推送加仓提醒";
    content.subtitle = @"亲～马上收盘了，你可以考虑是否加仓哦～";
    // 内容
//    content.body = @"现在大盘收跌/收涨 3320， 跌/涨幅 10%";
    // 声音
    // 默认声音
    //    content.sound = [UNNotificationSound defaultSound];
    // 添加自定义声音
    content.sound = [UNNotificationSound soundNamed:@"Alert_ActivityGoalAttained_Salient_Haptic.caf"];
    // 角标 （我这里测试的角标无效，暂时没找到原因）
    content.badge = @1;
    // 多少秒后发送,可以将固定的日期转化为时间
    //    NSTimeInterval time = [[NSDate dateWithTimeIntervalSinceNow:1] timeIntervalSinceNow];
    //        NSTimeInterval time = 10;
    // repeats，是否重复，如果重复的话时间必须大于60s，要不会报错
    //    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:time repeats:NO];
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.hour = 14;
    components.minute = 55;
    UNCalendarNotificationTrigger *calendarTrigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:YES];
    
    // 添加通知的标识符，可以用于移除，更新等操作
    NSString *identifier = @"noticeId";
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:calendarTrigger];
    
    [center addNotificationRequest:request withCompletionHandler:^(NSError *_Nullable error) {
        NSLog(@"成功添加推送");
    }];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
