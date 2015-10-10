//
//  GCDTimer.m
//  VideoMake
//
//  Created by sunlantao on 15/5/12.
//  Copyright (c) 2015年 sunlantao. All rights reserved.
//

#import "GCDTimer.h"

@interface GCDTimer(){
    dispatch_source_t _timer;
}

@property(nonatomic) NSTimeInterval interval;
@property(nonatomic, copy) void (^block)();
@property(nonatomic) dispatch_queue_t queue;

@end

@implementation GCDTimer

- (void)dealloc{
    [self destroy];
}

+ (instancetype)timerWithInterval:(NSTimeInterval)interval block:(void (^)())block queue:(dispatch_queue_t)queue{
    GCDTimer *timer = [[GCDTimer alloc] init];
    timer.interval = interval;
    timer.block = block;
    timer.queue = queue;
    [timer setup];
    
    return timer;
}

- (void)setup{
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _queue);
    dispatch_source_set_timer(_timer, dispatch_walltime(DISPATCH_TIME_NOW, 0), (uint64_t)_interval * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_timer, _block);
 //   dispatch_resume(_timer);
    _suspend = YES;
}

- (void)start{
    @try {
        if(_suspend)
            dispatch_resume(_timer);
        _suspend = NO;
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.reason);
    }
    @finally {
        _suspend = NO;
    }
  
}
- (void)stop{
    
    @try {
        if(!_suspend)
            dispatch_suspend(_timer);
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.reason);
    }
    @finally {
        _suspend = YES;
    }
}
- (void)destroy{
    dispatch_source_cancel(_timer);
}
@end
