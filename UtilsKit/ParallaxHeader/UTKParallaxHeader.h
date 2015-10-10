//
//  UTKParallaxHeader.h
//
//  Created by l.t.zero  on 24/8/15.
//  Copyright (c) 2015 sunlantao. All rights reserved.

//

#import <UIKit/UIKit.h>

@protocol ParallaxHeaderDelegate<NSObject>

- (void)parallaxZoomin:(CGFloat)depth;
@end


@interface UTKParallaxHeader : UIView

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, weak) id<ParallaxHeaderDelegate> delegate;

@property (nonatomic, setter=setOffset:) CGPoint offset;
@property (nonatomic, weak) UIScrollView *attachment;

+ (id)headerWithSize:(CGSize)headerSize;

@end


@interface UIScrollView(ParallaxScroll)

@property (nonatomic, strong) UTKParallaxHeader *parallaxHeader;

- (void)destroy;

@end

// 版权属于原作者
