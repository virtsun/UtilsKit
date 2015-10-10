//
//  UncaughtExceptionHandler.h
//  CarUILite
//
//  Created by sunlantao on 15/5/5.
//  Copyright (c) 2015年 sunlantao. All rights reserved.
//

#import <Foundation/Foundation.h>

void InstallUncaughtExceptionHandler();

@interface UncaughtExceptionHandler : NSObject{
    BOOL dismissed;
}

@end
