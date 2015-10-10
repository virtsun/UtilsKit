//
// Created by sunlantao on 15/4/15.
// Copyright (c) 2015 sunlantao. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
* provide a layer with Gaussian blur image
* you can special the blur or blurColor
* blur & blurAlpha are both animatable
* */
@interface CAGaussLayer : CALayer

@property(nonatomic, copy) UIImage *image;
@property(nonatomic, copy) UIColor *blurColor;

@property(nonatomic) float blur;///Animatable
@property(nonatomic) float blurAlpha;///Animatable

@end