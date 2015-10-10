//
//  UIImage+PureColorImage.m
//  lib51PKUserCenter
//
//  Created by L.T.ZERO on 14-4-28.
//  Copyright (c) 2014年 51pk. All rights reserved.
//

#import "UIImage+PureColorImage.h"
#import <ImageIO/ImageIO.h>

@implementation UIImage(PureColorImage)

static void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth,
                                 float ovalHeight)
{
    float fw, fh;

    if (ovalWidth == 0 || ovalHeight == 0)
    {
        CGContextAddRect(context, rect);
        return;
    }

    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM(context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth(rect) / ovalWidth;
    fh = CGRectGetHeight(rect) / ovalHeight;

    CGContextMoveToPoint(context, fw, fh/2);  // Start at lower right corner
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);  // Top right corner
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1); // Top left corner
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1); // Lower left corner
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1); // Back to lower right

    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size radius:(float)radius{

    size_t w = (size_t) (size.width * 2);
    size_t h = (size_t) (size.height * 2);
    radius *= 2;

    UIImage *img = [UIImage imageWithColor:color size:size];

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, (CGBitmapInfo) (kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big));
    CGRect rect = CGRectMake(0, 0, w, h);

    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetShouldAntialias(context, true);

    CGContextBeginPath(context);
    addRoundedRectToPath(context, rect, radius, radius);
    CGContextClosePath(context);
    CGContextClip(context);

    CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);

    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    img = [UIImage imageWithCGImage:imageMasked scale:2 orientation:UIImageOrientationUp];

    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageMasked);

    return img;
}

+ (CGImageRef)imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer // Create a CGImageRef from sample buffer data
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer,0);        // Lock the image buffer

    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);   // Get information of the image
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);

    CGImageRef newImage = CGBitmapContextCreateImage(newContext);
    CGContextRelease(newContext);

    CGColorSpaceRelease(colorSpace);
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    /* CVBufferRelease(imageBuffer); */  // do not call this!

    return newImage;
}
+ (UIImage *)imageWithCircle:(CGSize)size color:(UIColor *)color radius:(CGFloat)radius  borderWidth:(CGFloat)borderWidth{
    CGRect rect = CGRectMake(0, 0, size.width * [UIScreen mainScreen].scale, size.height * [UIScreen mainScreen].scale);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat r, g, b, a;
    
    [color getRed:&r green:&g blue:&b alpha:&a];
    
    CGContextSetRGBStrokeColor(context,r,g,b,a);//画笔线的颜色
    CGContextSetLineWidth(context, borderWidth);//线的宽度
    
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetShouldAntialias(context, true);
 
    CGContextAddArc(context, size.width/2, size.height/2, radius - borderWidth, 0, 2*M_PI, 0); //添加一个圆
    CGContextDrawPath(context, kCGPathStroke); //绘制路径
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
