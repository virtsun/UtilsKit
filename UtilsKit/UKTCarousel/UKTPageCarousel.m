//
// Created by sunlantao on 15/8/12.
// Copyright (c) 2015 sunlantao. All rights reserved.
//

#import "UKTPageCarousel.h"

@interface UKTPageCarousel(){
}
@end

@implementation UKTPageCarousel {

}

- (id)initWithFrame:(CGRect)frame {

    if (self = [super initWithFrame:frame]){
        _pageControl = [[UKTPageControl alloc] init];
        [self addSubview:_pageControl];
    }

    return self;
}

#pragma --
#pragma -- override

- (void)setNumPagesOfCarousel:(NSUInteger)numPagesOfCarousel {
    [super setNumPagesOfCarousel:numPagesOfCarousel];
    _pageControl.numberOfPages = numPagesOfCarousel;

    [self setNeedsLayout];
}


- (void)setOffset:(CGPoint)offset {
    _offset = offset;

    [self setNeedsLayout];
}

- (void)setCurrentPageIndex:(NSInteger)currentPageIndex {
    [super setCurrentPageIndex:currentPageIndex];
    _pageControl.currentPage = (NSUInteger)currentPageIndex;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self bringSubviewToFront:_pageControl];

    _pageControl.center = CGPointMake(CGRectGetWidth(self.bounds)/2 + _offset.x,
            CGRectGetHeight(self.bounds) - _offset.y - CGRectGetHeight(_pageControl.bounds)/2);

}


@end