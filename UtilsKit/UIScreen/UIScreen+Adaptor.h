//
// Created by sunlantao on 15/7/31.
// Copyright (c) 2015 sunlantao. All rights reserved.
//

#import <Foundation/Foundation.h>

#define  kScaleSizeComparedWith720P(x)      ([[UIScreen mainScreen] scaleComparedWith720p] * x)
#define  kScaleSizeComparedWithIphone5s(x)  ([[UIScreen mainScreen] scaleComparedWithIphone5s] * x)

/*
* 此3个函数主要用于根据设计尺寸 跟 设备分辨率的 缩放比例进行换算
* */
@interface UIScreen(AdaptorScreen)

- (CGFloat)scaleComparedWithCGSize:(CGSize)size;  //当前分辨率 相对于 size 的缩放比例

- (CGFloat)scaleComparedWithIphone5s;
- (CGFloat)scaleComparedWith720p;

@end