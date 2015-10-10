//
//  GCDTimer.h
//  VideoMake
//
//  Created by sunlantao on 15/5/12.
//  Copyright (c) 2015年 sunlantao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCDTimer : NSObject

@property(nonatomic) BOOL suspend;

+ (instancetype)timerWithInterval:(NSTimeInterval)interval block:(void (^)())block queue:(dispatch_queue_t)queue;

- (void)start;
- (void)stop;

- (void)destroy;

@end
