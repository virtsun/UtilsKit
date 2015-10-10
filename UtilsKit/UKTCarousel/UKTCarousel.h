//
// Created by sunlantao on 15/8/12.
// Copyright (c) 2015 ___FULLUSERNAME___. All rights reserved.
//

/*
* 2005-8-12：当前仅支持大于3张图片
* */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*
* 用来显示图片的item，其中保存了图片的URL，
* 以及用户需要用来进行数据处理的object
* */
@interface UKTCarouselObject : NSObject<NSCopying>

@property (nonatomic, copy) NSString *title; ///用来显示页面的标签
@property (nonatomic, copy) NSString *url;  ///图片的路径地址，分为本地，网络图片
@property (nonatomic, weak) id object;    ///保存数据值
@property (nonatomic, strong) UIImage *image; //保存图片
@property (nonatomic, strong) UIImage *blurImage;

+ (instancetype)objectWithURL:(NSString *)url object:(id)obj;
+ (instancetype)objectWithImage:(UIImage *)image object:(id)obj;

@end

/*
* 用户通过delegate来为Carousel提供展示用的数据
* */
@class UKTCarousel;
@protocol UKTCarouselDataSource<NSObject>

- (NSUInteger)numberPagesOfCarousel;
- (UKTCarouselObject *)carousel:(UKTCarousel *)carousel atIndex:(NSUInteger)index;

@optional
- (NSUInteger)fromIndexOfCarousel;

@end

@protocol UKTCarouselDelegate<NSObject>;

@optional
- (void)carousel:(UKTCarousel *)carousel didSelect:(NSUInteger)index object:(id)object;
- (void)carousel:(UKTCarousel *)carousel currentPageChanged:(NSUInteger)index;

@end

@interface UKTCarousel : UIView

@property (nonatomic, weak) id<UKTCarouselDataSource> dataSource;
@property (nonatomic, weak) id<UKTCarouselDelegate> delegate;

@property (nonatomic) NSUInteger numPagesOfCarousel;
@property (nonatomic) NSInteger currentPageIndex;
@property (readonly) NSArray *imageViews;
@property (readonly) NSArray *objects;

@property (nonatomic, strong) UIImage *defaultImage;

- (void)reloadData;

@end