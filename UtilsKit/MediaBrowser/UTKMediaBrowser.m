//
// Created by sunlantao on 15/8/27.
// Copyright (c) 2015 ___FULLUSERNAME___. All rights reserved.
//

#import "UTKMediaBrowser.h"


/*
 * UTKMediaItemObject
 * */
@implementation UTKMediaItemObject

+ (instancetype)objectWithTitle:(NSString *)title type:(UTKMediaType)type url:(NSString *)url{

    UTKMediaItemObject *object = [[UTKMediaItemObject alloc] init];

    object.title = title;
    object.type = type;
    object.url = url;

    return object;
}

- (id)copyWithZone:(NSZone *)zone {
    UTKMediaItemObject *object = [UTKMediaItemObject allocWithZone:zone];
    object.title = self.title;
    object.type = self.type;
    object.url = self.url;

    return object;
}
@end

/*
* UTKMediaItemView
* */

@implementation UTKMediaItemView

- (id)initWithItem:(UTKMediaItemObject *)object{

    if (self = [super init]){
        _itemObject  = object;

        self.clipsToBounds = YES;
    }

    return self;
}

- (BOOL)tapGesture:(NSUInteger)tapCount __attribute__((noreturn)){
    return YES;
}
- (BOOL)pinchGesture:(CGFloat)scale  state:(UIGestureRecognizerState)state{
    return YES;
}
- (CGPoint)panGesture:(CGPoint)offset state:(UIGestureRecognizerState)sta{
    return CGPointZero;
}

@end


@interface UTKMediaPicItemView(){
    UIImageView *imageView;

    BOOL maxStretched;
    CGFloat maxScale;
}
@end
@implementation UTKMediaPicItemView

- (id)initWithItem:(UTKMediaItemObject *)object{

    if (self = [super initWithItem:object]){

        UIImage *image = [UIImage imageWithContentsOfFile:object.url];

        imageView = [[UIImageView alloc] initWithImage:image];

        [self addSubview:imageView];


    }

    return self;
}

- (void)setFrame:(CGRect)frame {
    super.frame = frame;

    UIImage *image = imageView.image;

    CGFloat scale = MAX(image.size.width/CGRectGetWidth(self.bounds), image.size.height/CGRectGetHeight(self.bounds));
    maxScale = scale = MAX(scale, 1);

    CGFloat w = image.size.width/scale, h = image.size.height/scale;

    imageView.frame = CGRectMake((CGRectGetWidth(self.bounds) - w)/2,
            (CGRectGetHeight(self.bounds) - h)/2,
            w,
            h);
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];


    if (!highlighted){
        [UIView animateWithDuration:.3f
                         animations:^{
                             imageView.transform = CGAffineTransformMakeScale(1, 1);
                         } completion:^(BOOL finished) {
                    maxStretched = NO;
                }];
    }else{
        [UIView animateWithDuration:.3f
                         animations:^{
                             if(maxStretched)
                                 imageView.transform = CGAffineTransformMakeScale(maxScale, maxScale);
                             else
                                 imageView.transform = CGAffineTransformMakeScale(1, 1);

                         } completion:^(BOOL finished) {
                }];

    }

}

#pragma mark --
#pragma mark -- override

- (BOOL)tapGesture:(NSUInteger)tapCount {

    if (tapCount < 2){
        [super tapGesture:tapCount];
        return YES;
    }

    self.editable = !maxStretched;

    BOOL isIdentity;
    if ((isIdentity = CGAffineTransformIsIdentity(imageView.transform))){
        [UIView animateWithDuration:.3f
                         animations:^{
                             imageView.transform = CGAffineTransformMakeScale(maxScale, maxScale);

                         } completion:^(BOOL finished) {
                    maxStretched = YES;
                }];
    } else {
        [UIView animateWithDuration:.3f
                         animations:^{
                             imageView.transform = CGAffineTransformIdentity;

                         } completion:^(BOOL finished) {
                    maxStretched = NO;
                }];
    }



    return isIdentity;

}
- (BOOL)pinchGesture:(CGFloat)s state:(UIGestureRecognizerState)state{
    [super pinchGesture:s state:state];

    BOOL ret = YES;
    static  CGAffineTransform lastTransform;
    switch (state){
        case UIGestureRecognizerStateBegan:
            lastTransform = imageView.transform;
            break;
        case UIGestureRecognizerStateChanged:
            if (imageView.transform.a < maxScale && s<1){
                lastTransform = imageView.transform;
            }
            imageView.transform = CGAffineTransformConcat(imageView.transform, CGAffineTransformMakeScale(1/s, 1/s));


            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:{

            if (imageView.transform.a < 1){
                ret = NO;
                [UIView animateWithDuration:.2f
                                 animations:^{
                                     imageView.transform = CGAffineTransformIdentity;
                                 } completion:^(BOOL finished) {

                        }];
            } else if(imageView.transform.a > maxScale){

                [UIView animateWithDuration:.2f
                                 animations:^{
                                     imageView.transform = lastTransform;
                                 } completion:^(BOOL finished) {

                        }];

            }
        }
            break;
        default:
            break;
    }

    return ret;
}
- (CGPoint)panGesture:(CGPoint)offset state:(UIGestureRecognizerState)state{
    [super panGesture:offset state:state];

    static CGPoint overflow = {0,0};

    switch (state){
        case UIGestureRecognizerStateChanged: {
            imageView.transform = CGAffineTransformTranslate(imageView.transform, offset.x/imageView.transform.a, offset.y/imageView.transform.d);
        }

            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:{
            CGFloat maxX = (CGFloat)fabs((imageView.transform.a * CGRectGetWidth(imageView.bounds) - CGRectGetWidth(imageView.bounds))/2);
            CGFloat maxY = (CGFloat)fabs((-imageView.transform.d * CGRectGetHeight(imageView.bounds) + CGRectGetHeight(self.bounds))/2);

            CGAffineTransform transform = imageView.transform;

            if (transform.tx > maxX){
                transform.tx = maxX;
            } else if(transform.tx < -maxX){
                transform.tx = -maxX;
            }

            if (transform.ty > maxY){
                transform.ty = maxY;
            } else if (transform.ty < -maxY){
                transform.ty = -maxY;
            }


            //TODO: 回缩动画 有问题
            [UIView animateWithDuration:.3f
                             animations:^{
                                 imageView.transform = transform;
                             }];

//            [UIView transitionWithView:imageView
//                              duration:.3f
//                               options:UIViewAnimationOptionCurveEaseIn
//                            animations:^{
//                        imageView.transform = transform;
//
//                    } completion:^(BOOL finished) {
//
//                    }];

        }
            break;
        default:
            break;
    }

    return overflow;
}

@end



/*
 * UTKMediaBrowser
 * */
@interface UTKMediaBrowser()<UIScrollViewDelegate, UIGestureRecognizerDelegate>{
@private
    UIScrollView *browser;
    NSUInteger _numberItemOfBrowser;
    __weak id<UTKMediaBrowserDataSource> _dataSource;

    NSMutableArray *items;
}
@end

@implementation UTKMediaBrowser {

}

@synthesize numberItemOfBrowser = _numberItemOfBrowser;
@synthesize dataSource = _dataSource;

- (id)initWithFrame:(CGRect)frame {

    if(self = [super initWithFrame:frame]){

        self.backgroundColor = [UIColor blackColor];
        browser = [[UIScrollView alloc] initWithFrame:frame];
        browser.pagingEnabled = YES;
        browser.delegate = self;
        browser.autoresizingMask = ~UIViewAutoresizingNone;
        [self addSubview:browser];

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [self addGestureRecognizer:tap];

        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTap];

        [tap requireGestureRecognizerToFail:doubleTap];

        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        panGestureRecognizer.delegate = self;
        [self addGestureRecognizer:panGestureRecognizer];

        UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
        [self addGestureRecognizer:pinchGestureRecognizer];
    }
    return self;
}

- (void)layoutSubviews {
    browser.frame = self.bounds;

    [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *v = obj;
        v.frame = CGRectMake(idx * CGRectGetWidth(self.bounds),
                0,
                CGRectGetWidth(self.bounds),
                CGRectGetHeight(self.bounds));

        if (idx == _currentItem)
            _currentItemView = obj;

    }];

    browser.contentSize = CGSizeMake(items.count * CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));

    self.currentItem = _currentItem;
}

#pragma mark --
#pragma mark -- setter & getter

- (void)setDataSource:(id <UTKMediaBrowserDataSource>)dataSource {
    _dataSource = dataSource;
    [self reload];
}

- (void)reload{

    _numberItemOfBrowser = [_dataSource respondsToSelector:@selector(numberItemOfMediaBrowser)]? [_dataSource numberItemOfMediaBrowser]:0;

    [items makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [items removeAllObjects];

    items = [@[] mutableCopy];
    if ([_dataSource respondsToSelector:@selector(browser:itemViewAtIndex:)]){
        for (size_t i = 0; i < _numberItemOfBrowser; ++i) {

            UTKMediaItemView *v = (UTKMediaItemView *)[_dataSource browser:self itemViewAtIndex:i];
            [browser addSubview:v];

            [items addObject:v];
        }
    }else{
        for (size_t i = 0; i < _numberItemOfBrowser; ++i) {

            UIView *v = [UIView new];
            [browser addSubview:v];

            [items addObject:v];
        }
    }

    [self setNeedsLayout];
}


#pragma mark --
#pragma mark -- UIGestureRecognizer

- (void)tap:(UIGestureRecognizer *)gesture{

    [UIView animateWithDuration:.3f
                     animations:^{
                         self.alpha = 0;

                     } completion:^(BOOL finished) {

            }];

}

-(void)doubleTap:(UITapGestureRecognizer *)gesture{

    browser.scrollEnabled = ![self.currentItemView tapGesture:2];
}

- (void)pan:(UIPanGestureRecognizer *)gesture{

    static CGPoint tapLocation;
    CGPoint moveLocation = [gesture locationInView:self];

    switch (gesture.state){
        case UIGestureRecognizerStateBegan:
            tapLocation = [gesture locationInView:self];

            break;
        case UIGestureRecognizerStateChanged:
        {

            [self.currentItemView panGesture:CGPointMake(moveLocation.x - tapLocation.x, moveLocation.y - tapLocation.y) state:gesture.state];

            tapLocation = moveLocation;
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            [self.currentItemView panGesture:CGPointMake(moveLocation.x - tapLocation.x, moveLocation.y - tapLocation.y) state:gesture.state];
        }
            break;

        default:
            break;
    }
}

- (void)pinch:(UIPinchGestureRecognizer *)gesture{

    static CGFloat scale = 1;
    switch (gesture.state){
        case UIGestureRecognizerStateBegan:
            scale = 1.f;
//            [_currentItemView pinchGesture:(1 - gesture.scale + scale) state:gesture.state];
//            break;
        case UIGestureRecognizerStateChanged:
        {

            [_currentItemView pinchGesture:(1 - gesture.scale + scale) state:gesture.state];
            scale = gesture.scale;
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            browser.scrollEnabled = ![_currentItemView pinchGesture:(1 - gesture.scale + scale) state:gesture.state];
        }
            break;

        default:
            break;
    }
}
#pragma mark --
#pragma mark -- Scroll delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

    _currentItem = (NSUInteger)(scrollView.contentOffset.x/CGRectGetWidth(self.bounds));
    _currentItemView = items[_currentItem];

    [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UTKMediaItemView *itemView = obj;
        itemView.highlighted = idx == _currentItem;
    }];
}

- (void)setCurrentItem:(NSUInteger)currentItem {
    _currentItem = currentItem;
    browser.contentOffset = CGPointMake(CGRectGetWidth(self.bounds) * currentItem, 0);
}
@end