//
// Created by sunlantao on 15/8/12.
// Copyright (c) 2015 ___FULLUSERNAME___. All rights reserved.
//

#import "UKTCarousel.h"
#import "URLImageFetcher.h"

#define kSenseOffX 0.1f


@implementation UKTCarouselObject

+ (instancetype)objectWithURL:(NSString *)url object:(id)obj {
    UKTCarouselObject *item = [UKTCarouselObject new];
    item.title = @"pic";
    item.object = obj;
    item.url = url;

    return item;
}
+ (instancetype)objectWithImage:(UIImage *)image object:(id)obj{
    UKTCarouselObject *item = [UKTCarouselObject new];
    item.title = @"pic";
    item.object = obj;
    item.image = image;

    return item;
}

- (id)copyWithZone:(NSZone *)zone {
    UKTCarouselObject *item = [UKTCarouselObject allocWithZone:zone];
    item.url = self.url;
    item.object = self.object;
    item.title = self.title;
    item.image = self.image;
    item.blurImage = self.blurImage;

    return item;
}

@end

@interface UKTCarousel()<UIGestureRecognizerDelegate>{
    NSMutableArray *_imageViews;
}

@end


@implementation UKTCarousel {

    NSInteger _currentPageIndex;
    NSUInteger _numPagesOfCarousel;

    NSMutableArray *_objects;
    __weak id<UKTCarouselDataSource> _dataSource;
    __weak id<UKTCarouselDelegate> _delegate;

}

@synthesize dataSource = _dataSource;
@synthesize delegate = _delegate;
@synthesize numPagesOfCarousel = _numPagesOfCarousel;
@synthesize currentPageIndex = _currentPageIndex;
@synthesize imageViews = _imageViews;
@synthesize objects = _objects;

- (id)initWithFrame:(CGRect)frame {

    if (self = [super initWithFrame:frame]){
        self.clipsToBounds = YES;
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        pan.delegate = self;
        pan.minimumNumberOfTouches = 1;
        [self addGestureRecognizer:pan];

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [self addGestureRecognizer:tap];
    }

    return self;
}

#pragma --
#pragma -- 刷新数据展示
- (void)reloadData{
    _numPagesOfCarousel = 0;
    if ([_dataSource respondsToSelector:@selector(numberPagesOfCarousel)]){
        self.numPagesOfCarousel = [_dataSource numberPagesOfCarousel];
    }

    //清理旧数据
    [_imageViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_objects removeAllObjects];
    _imageViews = [@[] mutableCopy];
    _objects = [@[] mutableCopy];

    _currentPageIndex = 0;
    if ([_dataSource respondsToSelector:@selector(fromIndexOfCarousel)]){
        _currentPageIndex = MIN(_numPagesOfCarousel, [_dataSource fromIndexOfCarousel]);
    }

    if ([_dataSource respondsToSelector:@selector(carousel:atIndex:)]){

        for (size_t i = 0; i < _numPagesOfCarousel; i++){
            UKTCarouselObject *item =  [_dataSource carousel:self atIndex:i];

            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.backgroundColor = UIColorFromRGB(0xffffff);
            imageView.frame = self.bounds;

            imageView.image = self.defaultImage;

            if(!item.image && item.url){
                URLImageFetcher *fetcher = [[URLImageFetcher alloc] initWithURL:item.url];
                fetcher.imageView = imageView;
                __weak URLImageFetcher *tmp = fetcher;
                fetcher.block = ^{
                    item.image = tmp.image;
                    item.blurImage = [tmp.image thumbnailWithImageWithoutScale:CGSizeMake(CGRectGetWidth(self.bounds), CGRectGetWidth(self.bounds))];

                };
            }

            imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            [_imageViews addObject:imageView];
            [_objects addObject:item];

            [self addSubview:imageView];

            [self reLayoutSubviews];
        }
    }


    [self setNeedsLayout];
}


#pragma mark --
#pragma mark -- setter & getter
- (void)setCurrentPageIndex:(NSInteger)currentPageIndex {
    _currentPageIndex = currentPageIndex;

    UIView *imageView = _imageViews[(NSUInteger)_currentPageIndex];
    [self bringSubviewToFront:imageView];

    [self setNeedsDisplay];
}

#pragma mark --
#pragma mark --设置数据源 并刷新数据展示
- (void)setDataSource:(id <UKTCarouselDataSource>)dataSource {
    _dataSource = dataSource;
    [self reloadData];
}



#pragma --
#pragma -- 手势事件
- (void)tap:(UIGestureRecognizer *)gestureRecognizers {
    if ([_delegate respondsToSelector:@selector(carousel:didSelect:object:)]){
        UKTCarouselObject *obj = _objects[(NSUInteger)_currentPageIndex];
        [_delegate carousel:self
                  didSelect:(NSUInteger)_currentPageIndex
                     object:obj.object];
    }
}

UIView *prev, *next, *current;
CGPoint point;
CGFloat totalOffX;
- (CGPoint)touchLocation:(NSSet *)touches{
    UITouch *touch = [touches anyObject];
    return [touch locationInView:self];
}
- (void)prepareForSequencing{
    totalOffX = 0;
    [self reLayoutSubviews];

    prev = _imageViews[(_currentPageIndex + _numPagesOfCarousel - 1)% _numPagesOfCarousel];
    next = _imageViews[(_currentPageIndex + _numPagesOfCarousel + 1)% _numPagesOfCarousel];

    current = _imageViews[(NSUInteger) _currentPageIndex];
    current.frame = CGRectOffset(self.bounds, 0, 0);
    prev.frame = CGRectOffset(current.frame, -CGRectGetWidth(current.frame), 0);
    next.frame = CGRectOffset(current.frame, CGRectGetWidth(current.frame), 0);

    [self bringSubviewToFront:prev];
    [self bringSubviewToFront:next];
    [self bringSubviewToFront:current];

}


#pragma mark --
#pragma mark -- Gesture

static BOOL isAnimating = NO;

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    return !isAnimating ;
}

- (void)pan:(UIGestureRecognizer *)gestureRecognizers {

    if (isAnimating) return;
    if (_numPagesOfCarousel == 0) {
        return;
    }

    switch (gestureRecognizers.state) {
        case UIGestureRecognizerStateBegan: {
            [self prepareForSequencing];
            point = [gestureRecognizers locationInView:self];
        }
            break;
        case UIGestureRecognizerStateChanged: {
            CGPoint tmp = [gestureRecognizers locationInView:self];

            CGFloat offX = tmp.x - point.x;

            prev.transform = CGAffineTransformTranslate(prev.transform, offX, 0);
            next.transform = CGAffineTransformTranslate(next.transform, offX, 0);
            current.transform = CGAffineTransformTranslate(current.transform, offX, 0);

            totalOffX += offX;

            point = tmp;
        }
            break;
        case UIGestureRecognizerStateEnded: {
            CGRect framePre, frameNext, frameCurrent;
            NSInteger currentIndex = 0;

            if (fabs(totalOffX) < CGRectGetWidth(self.bounds) * kSenseOffX) {

                //回到当前
                currentIndex = _currentPageIndex % _numPagesOfCarousel;
                framePre = CGRectOffset(self.bounds, -CGRectGetWidth(self.bounds), 0);
                frameCurrent = CGRectOffset(self.bounds, 0, 0);
                frameNext = CGRectOffset(self.bounds, CGRectGetWidth(self.bounds), 0);

            } else {

                if (totalOffX > 0) {
                    //前一个
                    currentIndex = (--_currentPageIndex + _numPagesOfCarousel) % _numPagesOfCarousel;

                    framePre = self.bounds;
                    frameCurrent = CGRectOffset(self.bounds, CGRectGetWidth(self.bounds), 0);
                    frameNext = CGRectOffset(frameCurrent, CGRectGetWidth(self.bounds), 0);
                } else {
                    //后一个
                    currentIndex = (++_currentPageIndex) % _numPagesOfCarousel;

                    frameNext = self.bounds;
                    frameCurrent = CGRectOffset(self.bounds, -CGRectGetWidth(self.bounds), 0);
                    framePre = CGRectOffset(frameCurrent, -CGRectGetWidth(self.bounds), 0);

                }
            }
            isAnimating = YES;
            //添加动画
            [UIView animateWithDuration:.15f
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 prev.frame = framePre;
                                 current.frame = frameCurrent;
                                 next.frame = frameNext;
                             } completion:^(BOOL finished) {

                        [self reLayoutSubviews];

                        self.currentPageIndex = currentIndex;

                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(NSEC_PER_SEC * .1f)), dispatch_get_main_queue(), ^{
                            isAnimating = NO;
                        });
                        if ([_delegate respondsToSelector:@selector(carousel:currentPageChanged:)]) {
                            [_delegate carousel:self currentPageChanged:(NSUInteger) self.currentPageIndex];
                        }
                    }];
        }
            break;
        case UIGestureRecognizerStateCancelled:
        {
            //回到当前
            isAnimating = YES;
          //  NSLog(@"%s", __PRETTY_FUNCTION__);

            CGRect framePre, frameNext, frameCurrent;
            NSInteger currentIndex = _currentPageIndex % _numPagesOfCarousel;
            framePre = CGRectOffset(self.bounds, -CGRectGetWidth(self.bounds), 0);
            frameCurrent = CGRectOffset(self.bounds, 0, 0);
            frameNext = CGRectOffset(self.bounds, CGRectGetWidth(self.bounds), 0);
            //添加动画
            [UIView animateWithDuration:.15f
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 prev.frame = framePre;
                                 current.frame = frameCurrent;
                                 next.frame = frameNext;
                             } completion:^(BOOL finished) {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(NSEC_PER_SEC * .1f)), dispatch_get_main_queue(), ^{
                            isAnimating = NO;
                        });
                        self.currentPageIndex = currentIndex;

                        [self reLayoutSubviews];
                        if ([_delegate respondsToSelector:@selector(carousel:currentPageChanged:)]){
                            [_delegate carousel:self currentPageChanged:(NSUInteger)self.currentPageIndex];
                        }
                    }];
        }
            break;
        default:
            break;
    }
}


#pragma mark--
#pragma mark--layout

- (void)reLayoutSubviews {
    [_imageViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *imageView = obj;
        imageView.frame = CGRectOffset(self.bounds, CGRectGetWidth(self.bounds) * (idx - idx), 0);
        if (idx == _currentPageIndex) [self bringSubviewToFront:imageView];
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    //把当前提到最前
//
//    [_imageViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        UIView *imageView = obj;
//        if(idx != self.currentPageIndex){
//            [self sendSubviewToBack:imageView];
//        }else{
//            [self bringSubviewToFront:imageView];
//        }
//    }];

}
@end