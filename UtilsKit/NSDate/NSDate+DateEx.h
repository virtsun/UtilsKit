//
//  NSDate+DateEx.h
//  CarUILite
//
//  Created by sunlantao on 15/1/15.
//  Copyright (c) 2015年 sunlantao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate(DateEx)

+ (NSString *)shortDateString;
- (NSString *)shortDateString;
- (NSString *)dateWithFormatter:(NSString *)formatter;

+ (NSString *)shortDateStringEx;

+ (NSString *)currentWeek;
+ (NSString *)shortDateStringWithWeek;

+ (unsigned long)milliSecsOfDay;

- (NSString *)rfc822String;

+ (NSDate *)dateWithString:(NSString *)dateString formatter:(NSString *)formatter;

@end
