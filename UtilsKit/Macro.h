//
//  Macro.h
//  UtilsKit
//
//  Created by sunlantao on 15/6/17.
//  Copyright (c) 2015年 sunlantao. All rights reserved.
//

#ifndef UtilsKit_Macro_h
#define UtilsKit_Macro_h

/**
 *  强弱引用转换，用于解决代码块（block）与强引用self之间的循环引用问题
 *  调用方式: `@weakify_self`实现弱引用转换，`@strongify_self`实现强引用转换
 *
 *  示例：
 *  @weakify_self
 *  [obj block:^{
 *  @strongify_self
 *      self.property = something;
 *  }];
 */
#ifndef	weakify_self
#if __has_feature(objc_arc)
#define weakify_self autoreleasepool{} __weak __typeof__(self) weakSelf = self;
#else
#define weakify_self autoreleasepool{} __block __typeof__(self) blockSelf = self;
#endif
#endif
#ifndef	strongify_self
#if __has_feature(objc_arc)
#define strongify_self try{} @finally{} __typeof__(weakSelf) self = weakSelf;
#else
#define strongify_self try{} @finally{} __typeof__(blockSelf) self = blockSelf;
#endif
#endif

/**
 *  强弱引用转换，用于解决代码块（block）与强引用对象之间的循环引用问题
 *  调用方式: `@weakify(object)`实现弱引用转换，`@strongify(object)`实现强引用转换
 *
 *  示例：
 *  @weakify(object)
 *  [obj block:^{
 *      @strongify(object)
 *      strong_object = something;
 *  }];
 */
#ifndef	weakify
#if __has_feature(objc_arc)
#define weakify(object)	autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object)	autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#endif
#ifndef	strongify
#if __has_feature(objc_arc)
#define strongify(object) try{} @finally{} __typeof__(object) strong##_##object = weak##_##object;
#else
#define strongify(object) try{} @finally{} __typeof__(object) strong##_##object = block##_##object;
#endif
#endif


#define IS_IPAD [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad

#define IOS7_OR_LATER ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending)
#define IOS8_OR_LATER ([[[UIDevice currentDevice] systemVersion] compare:@"8.0"] != NSOrderedAscending)

//-------------------打印日志-------------------------
//DEBUG  模式下打印日志,当前行
#ifdef DEBUG
#define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define DLog(...)
#endif

//DEBUG  模式下打印日志,当前行
#ifdef DEBUG
#define NSLog(fmt, ...) NSLog((fmt), ##__VA_ARGS__);
#else
#define NSLog(...)
#endif

//定义UIImage对象
#define IMAGE(A) [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:A ofType:nil]]

//定义UIImage对象
#define ImageNamed(_pointer) [UIImage imageNamed:[UIUtil imageName:_pointer]]

#define UIColorFromRGBA(rgbValue, a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]
#define UIColorFromRGB(rgbValue) UIColorFromRGBA(rgbValue, 1.f)

#define NSStringFromValue(value) [NSString stringWithFormat:@"%@", value]


#define VariablesCheckWithReturnValue(object, class, returnValue) \
    if (![object isKindOfClass:class]){       \
        return returnValue;                  \
    }                                         \

#define VariablesCheck(object, class)   \
    if (![object isKindOfClass:class]){   \
        return;                          \
    }\

#endif
