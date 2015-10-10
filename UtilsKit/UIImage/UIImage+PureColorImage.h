//
//  UIImage+PureColorImage.h
//  lib51PKUserCenter
//
//  Created by L.T.ZERO on 14-4-28.
//  Copyright (c) 2014年 51pk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>

@interface UIImage(PureColorImage)

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size radius:(float)radius;

+ (CGImageRef)imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer;

+ (UIImage *)imageWithCircle:(CGSize)size color:(UIColor *)color radius:(CGFloat)radius borderWidth:(CGFloat)borderWidth;
@end
