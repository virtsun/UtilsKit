//
// Created by sunlantao on 15/4/1.
// Copyright (c) 2015 sunlantao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface NSString(Ext)

- (CGSize)constrained:(CGSize)constrainedSize font:(UIFont *)font;

///遍历字符串内所有单个字符
- (void)enumerateCharactorUseInBlock:(void (^)(NSRange rang, NSString *subString, BOOL isLast))block;

///将汉字转化成拼音，不包含音调
- (NSString*)transfromToChineseSpell;

- (BOOL)isHttpURL;

@end