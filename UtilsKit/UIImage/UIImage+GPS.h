//
// Created by sunlantao on 15/4/16.
// Copyright (c) 2015 sunlantao. All rights reserved.
//

#import <Foundation/Foundation.h>


@class CLLocation;

@interface UIImage(GPSImage)

+(UIImage *)makeGPSImage:(UIImage *)image location:(CLLocation *)location;

+(BOOL)getGPSByImageFilePath:(NSString*)path latitude:(double*)lati longitude:(double*)longi date:(NSString **)dateString;
@end