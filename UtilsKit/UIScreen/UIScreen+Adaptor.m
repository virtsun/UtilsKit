//
// Created by sunlantao on 15/7/31.
// Copyright (c) 2015 sunlantao. All rights reserved.
//

#import "UIScreen+Adaptor.h"


@implementation UIScreen(AdaptorScreen)


- (CGFloat)scaleComparedWithCGSize:(CGSize)size{
    static CGFloat scale = 0.f;

    //进行一次运算即可，避免浪费资源
    static dispatch_once_t once;

    dispatch_once(&once, ^{
        CGFloat width = MIN(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
        CGFloat comparedWidth = MIN(size.width, size.height);
        scale = width * self.scale / comparedWidth;
    });

    return scale;
}

- (CGFloat)scaleComparedWithIphone5s{
    return [self scaleComparedWithCGSize:(CGSize) {640, 1136}];
}
- (CGFloat)scaleComparedWith720p{
    return [self scaleComparedWithCGSize:(CGSize) {720, 1024}];
}
@end