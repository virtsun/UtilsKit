//
//  UncaughtExceptionHandler.h
//  CarUILite
//
//  Created by sunlantao on 15/5/5.
//  Copyright (c) 2015年 sunlantao. All rights reserved.
//

#import <Foundation/Foundation.h>

//捕获异常会发送通知
extern NSString * const UncaughtExceptionPostNotificationNameHandlerSignalException;

/**key示例
 [[NSNotificationCenter defaultCenter] addObserverForName:UncaughtExceptionPostNotificationNameHandlerSignalException
            object:nil
             queue:[NSOperationQueue mainQueue]
        usingBlock:^(NSNotification * _Nonnull note) {
             NSException *exception = note.object;
             uint8_t signal = [exception.userInfo[UncaughtExceptionHandlerSignalKey] integerValue];
         }];
 */
extern NSString * const UncaughtExceptionHandlerSignalExceptionName;
extern NSString * const UncaughtExceptionHandlerSignalKey ;
extern NSString * const UncaughtExceptionHandlerAddressesKey;

void InstallUncaughtExceptionHandler();


