//
//  YRTools.m
//  StatusFundLook
//
//  Created by yjs on 2020/12/30.
//

#import "YRTools.h"

@implementation YRTools
TXSingletonM(YRTools)

+ (NSColor *)colorOfValue:(NSString *)value{
    value = [YRTools stringOfObjc:value];
    if([value isEqualToString:@"--"]){
        return [NSColor colorWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:1];
    }else{
        if([value doubleValue] > 0){
            //236,51,59
//            return [NSColor colorWithRed:244.0/255 green:67.0/255 blue:54.0/255 alpha:1];
            return [NSColor colorWithRed:236.0/255 green:51.0/255 blue:59.0/255 alpha:1];
        }else if([value doubleValue] < 0){
//            return [NSColor colorWithRed:32.0/255 green:171.0/255 blue:63.0/255 alpha:1];
            return [NSColor colorWithRed:26.0/255 green:170.0/255 blue:82.0/255 alpha:1];
        }else{
            return [NSColor colorWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:1];
        }
    }
}

+ (NSColor*)colorOfSubValue:(double)subValue superValue:(double)superValue{
    if(subValue > superValue){
        return [NSColor colorWithRed:244.0/255 green:67.0/255 blue:54.0/255 alpha:1];
    }else if(subValue < superValue){
        return [NSColor colorWithRed:32.0/255 green:171.0/255 blue:63.0/255 alpha:1];
    }else{
        return [NSColor colorWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:1];
    }
}

+ (NSString *)stringOfObjc:(id)value{
    //处理null的情况
    if (value == nil || ([value class] == [NSNull class])) return @"--";
    //处理nsnumber的情况
    if ([value isKindOfClass:[NSNumber class]]) return [value description];
    //处理字符串为空的情况
    return [(NSString *)value length] >0 ? (NSString *)value : @"--";
}

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingFragmentsAllowed
                                                          error:&err];
    if(err){
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

+ (BOOL)isTransactionTime{
    //判断时间是否是9:00-15:30
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    NSDate *currentDateBeiJing = [NSDate dateWithTimeIntervalSinceNow:8*60*60];
    NSString *yearMonthDay = [self getCurrentYearMonthAndDay:currentDateBeiJing];
    
    NSDate *fromDateGMTMorning = [formatter dateFromString:[NSString stringWithFormat:@"%@ 09:00:00", yearMonthDay]];
    NSDate *fromDateBeiJingMorning = [NSDate dateWithTimeInterval:8*60*60 sinceDate:fromDateGMTMorning];
    
    NSDate *toDateGMTAfternoon = [formatter dateFromString:[NSString stringWithFormat:@"%@ 15:31:00", yearMonthDay]];
    NSDate *toDateBeiJingAfternoon = [NSDate dateWithTimeInterval:8*60*60 sinceDate:toDateGMTAfternoon];
    
    //判断日期是否是周六或者周日
    NSInteger weekDay = [self weekDayOfNow];
    
    if ([fromDateBeiJingMorning compare:currentDateBeiJing] == NSOrderedAscending && [currentDateBeiJing compare:toDateBeiJingAfternoon] == NSOrderedAscending && (weekDay != 0 && weekDay != 6)) {
        return YES;
    }else{
        return NO;
    }
}

+ (NSInteger)weekDayOfNow {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [calendar components:NSCalendarUnitWeekday fromDate:[NSDate date]];
    return comp.weekday-1;
}

+ (NSString *)getCurrentYearMonthAndDay:(NSDate *)currentDate{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy-MM-dd";
    NSString *str = [formatter stringFromDate:currentDate];
    return str;
}

+ (NSString *)unSignDoubleOfValue:(double)value{
    NSDecimalNumber * valueNum = [NSDecimalNumber decimalNumberWithString:[@(value) description]];
    NSDecimalNumberHandler * handler = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown scale:2 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:YES];
    NSNumberFormatter * formatter = [[NSNumberFormatter alloc]init];
    formatter.alwaysShowsDecimalSeparator = YES;
    formatter.maximumFractionDigits = 2;
    formatter.minimumFractionDigits = 2;
    formatter.minimumIntegerDigits = 1;
    formatter.zeroSymbol = @"0.00";
    return [formatter stringFromNumber:[valueNum decimalNumberByRoundingAccordingToBehavior:handler]];
}
@end
