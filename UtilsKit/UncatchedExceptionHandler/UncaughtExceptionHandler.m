//
//  UncaughtExceptionHandler.m
//  CarUILite
//
//  Created by sunlantao on 15/5/5.
//  Copyright (c) 2015年 sunlantao. All rights reserved.
//

#import "UncaughtExceptionHandler.h"

#include <libkern/OSAtomic.h>
#include <execinfo.h>

@import UIKit;

NSString * const UncaughtExceptionPostNotificationNameHandlerSignalException = @"UncaughtExceptionPostNotificationNameHandlerSignalException";

NSString * const UncaughtExceptionHandlerSignalExceptionName = @"UncaughtExceptionHandlerSignalExceptionName";
NSString * const UncaughtExceptionHandlerSignalKey = @"UncaughtExceptionHandlerSignalKey";
NSString * const UncaughtExceptionHandlerAddressesKey = @"UncaughtExceptionHandlerAddressesKey";

volatile int32_t UncaughtExceptionCount = 0;
const int32_t UncaughtExceptionMaximum = HUGE_VAL;

const NSInteger UncaughtExceptionHandlerSkipAddressCount = 4;
const NSInteger UncaughtExceptionHandlerReportAddressCount = 5;

//为获取调用堆栈
@interface UncaughtExceptionHandler : NSObject
@end

@implementation UncaughtExceptionHandler

+ (NSArray *)backtrace{
    
    void* callstack[128];
    
    int frames = backtrace(callstack, 128);
    
    char **strs = backtrace_symbols(callstack, frames);
    int i;
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    
    for (i = UncaughtExceptionHandlerSkipAddressCount;
         i < UncaughtExceptionHandlerSkipAddressCount +UncaughtExceptionHandlerReportAddressCount;
         i++){
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    
    free(strs);
    
    return backtrace;
    
}

@end

void handleException(NSException *exception){
    
#if defined(COPYRUNLOOP)
    /*此方法貌似失效了*/
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    
    CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);
    
    while (!dismissed){
        for (NSString *mode in (__bridge NSArray *)allModes){
            CFRunLoopRunInMode((__bridge CFStringRef)mode, 0.001, false);
        }
    }
    
    CFRelease(allModes);
#else
    [[NSNotificationCenter defaultCenter] postNotificationName:UncaughtExceptionPostNotificationNameHandlerSignalException object:exception];

    
    /*添加此段代码会导致此runloop无限报异常
     if (![NSThread isMainThread]){
     CFRunLoopStop(CFRunLoopGetCurrent());
     return;
     }*/
    
    if ([NSThread isMainThread]){
        u_int16_t sig = [exception.userInfo[UncaughtExceptionHandlerSignalKey] integerValue];
        
        switch (sig) {
            case SIGILL:
            case SIGBUS:
            case SIGSEGV:
            case SIGFPE:
            {
                NSSetUncaughtExceptionHandler(NULL);

                signal(SIGABRT, SIG_DFL);
                signal(SIGILL, SIG_DFL);
                signal(SIGSEGV, SIG_DFL);
                signal(SIGFPE, SIG_DFL);
                signal(SIGBUS, SIG_DFL);
                signal(SIGPIPE, SIG_DFL);

                if ([[exception name] isEqual:UncaughtExceptionHandlerSignalExceptionName]){
                    kill(getpid(), [[exception userInfo][UncaughtExceptionHandlerSignalKey] intValue]);
                }else{
                    [exception raise];
                }
            }
                break;
                
            default:
                break;
        }
     }
    
    [[NSRunLoop currentRunLoop] addPort:[NSPort port] forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] run];
#endif
    
   
    
}

void signalHandler(int signal){
    
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    
    if (exceptionCount > UncaughtExceptionMaximum){
        return;
    }
 
    NSMutableDictionary *userInfo = [@{UncaughtExceptionHandlerSignalKey : @(signal)} mutableCopy];
    
    NSArray *callStack = [UncaughtExceptionHandler backtrace];
    userInfo[UncaughtExceptionHandlerAddressesKey] = callStack;
    
    handleException([NSException exceptionWithName:UncaughtExceptionHandlerSignalExceptionName
                                            reason:[NSString stringWithFormat:NSLocalizedString(@"Signal %d was raised.\n", nil), signal]
                                          userInfo:userInfo]);
      
    
}

void handle_pipe(int sig){
    //不做任何处理即可
    signalHandler(sig);
}
void InstallUncaughtExceptionHandler(){
    
//    /*屏蔽SIGPIPE异常*/
    sigset_t signal_mask;
    sigemptyset (&signal_mask);
    
#ifndef SIGACTIONEXCEPTION
    signal(SIGABRT, signalHandler);
    signal(SIGILL, signalHandler);
    signal(SIGFPE, signalHandler);
    sigaddset (&signal_mask, SIGABRT);
    sigaddset (&signal_mask, SIGILL);
    sigaddset (&signal_mask, SIGFPE);
    
    signal(SIGBUS, signalHandler);
    signal(SIGPIPE, signalHandler);
    signal(SIGSEGV, signalHandler);
    sigaddset (&signal_mask, SIGBUS);
    sigaddset (&signal_mask, SIGPIPE);
    sigaddset (&signal_mask, SIGSEGV);
#else
    struct sigaction action;
    action.sa_handler = handle_pipe;
    sigemptyset(&action.sa_mask);
    action.sa_flags = 0;
    sigaction(SIGPIPE, &action, NULL);
    
    struct sigaction bus;
    bus.sa_handler = handle_pipe;
    sigemptyset(&bus.sa_mask);
    bus.sa_flags = 0;
    sigaction(SIGBUS, &bus, NULL);
    
    struct sigaction segv;
    segv.sa_handler = handle_pipe;
    sigemptyset(&segv.sa_mask);
    segv.sa_flags = 0;
    sigaction(SIGSEGV, &segv, NULL);
    
    if (pthread_sigmask (SIG_BLOCK, &signal_mask, NULL) != 0) {
        printf("block sigpipe error\n");
    }
#endif
}

