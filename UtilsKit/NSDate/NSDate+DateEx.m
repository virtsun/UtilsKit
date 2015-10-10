//
//  NSDate+DateEx.m
//  CarUILite
//
//  Created by sunlantao on 15/1/15.
//  Copyright (c) 2015年 sunlantao. All rights reserved.
//

#import "NSDate+DateEx.h"
#import <sys/time.h>

@implementation NSDate(DateEx)

- (NSString *)dateWithFormatter:(NSString *)formatter{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:formatter];
    return [dateFormatter stringFromDate:self];
}

- (NSString *)shortDateString{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy.MM.dd"];
    //用[NSDate date]可以获取系统当前时间
    return [dateFormatter stringFromDate:self];
}
+(NSString*)shortDateString{
    return [[NSDate date] shortDateString];
}

+(NSString*)shortDateStringEx{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
    //用[NSDate date]可以获取系统当前时间
    return [dateFormatter stringFromDate:[NSDate date]];
}
+ (NSString *)currentWeek{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"e"];
    //用[NSDate date]可以获取系统当前时间
    NSString *w = [dateFormatter stringFromDate:[NSDate date]];
    NSString *week = nil;
    switch ([w intValue]) {
        case 1:
            week = @"星期日";
            break;
        case 2:
            week = @"星期一";
            break;
        case 3:
            week = @"星期二";
            break;
        case 4:
            week = @"星期三";
            break;
        case 5:
            week = @"星期四";
            break;
        case 6:
            week = @"星期五";
            break;
        case 7:
            week = @"星期六";
            break;
            
        default:
            break;
    }
    
    return week;
}
+ (NSString *)shortDateStringWithWeek{
    
    return [NSString stringWithFormat:@"%@  %@", [NSDate shortDateString], [NSDate currentWeek]];
}

static  inline unsigned long miliSecsOfDay(){
    struct timeval tv ;
    gettimeofday(&tv, NULL);

    return (unsigned long) (tv.tv_sec * 1000 + tv.tv_usec / 1000);
};

+ (unsigned long)milliSecsOfDay {
    return miliSecsOfDay();
}

- (NSString *)rfc822String{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    //设定时间格式,这里可以设置成自己需要的格式
    //精确到毫秒
    [dateFormatter setDateFormat:@"EEE, dd MMM YYYY HH:mm:ss zzz"];

    return [dateFormatter stringFromDate:self];;
}

+ (NSDate *)dateWithString:(NSString *)dateString formatter:(NSString *)formatter{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [dateFormatter setDateFormat:formatter];

    NSDate *date = [dateFormatter dateFromString:dateString];
//    NSTimeZone *zone = [NSTimeZone systemTimeZone];
//    NSInteger interval = [zone secondsFromGMTForDate: date];
//    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];

    return date;
}
@end
