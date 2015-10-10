//
// Created by sunlantao on 15/8/10.
// Copyright (c) 2015 ___FULLUSERNAME___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NPointStar : CAShapeLayer

@property (nonatomic) uint16_t numOfPoints;
@property (nonatomic) uint16_t numOfStars;
@property (nonatomic) CGFloat radiusOfOuterCircle;
@property (nonatomic) CGFloat radiusOfInnerCircle;

@property (nonatomic, copy) UIColor *lineColor;

@end

@interface NPointStarRatingPanel : UIView

@property (nonatomic) CGFloat depth;

@property (nonatomic) CGFloat score;  //0-100
@property (nonatomic, copy) UIColor *scoreColor;

@property (nonatomic) BOOL supportScore; //支持打分

@end