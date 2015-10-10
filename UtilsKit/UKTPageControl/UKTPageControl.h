//
// Created by sunlantao on 15/8/12.
// Copyright (c) 2015 ___FULLUSERNAME___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UKTPageControlItem: CAShapeLayer

@property CGColorRef selectedFillColor;
@property CGColorRef selectedStrokeColor;
@property CGColorRef unselectedFilColor;
@property CGColorRef unselectedStrokeColor;

@property (nonatomic) BOOL selected;

@end

@interface UKTPageControl : UIView

@property (nonatomic) NSUInteger numberOfPages;
@property (nonatomic) NSUInteger currentPage;

@property (nonatomic) CGPathRef path;//指示点 的形状
@property (nonatomic) CGFloat margin;

@property (nonatomic, copy) UIColor *fillColor;
@property (nonatomic, copy) UIColor *selectedFillColor;

@property (nonatomic, copy) UIColor *strokeColor;
@property (nonatomic, copy) UIColor *selectedStrokeColor;
@property (nonatomic) CGFloat lineWidth;

@end