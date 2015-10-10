
#import "CircleActivityIndicatorView.h"


NSString *kCircleActivityAnimationActive = @"kCircleActivityAnimationActive";


@interface CircleActivityIndicatorView (){
    BOOL locked;
    NSMutableArray *dots;
}

@end

@implementation CircleActivityIndicatorView

@synthesize locked;

- (void)dealloc{

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)commonInit{
    dots = [@[] mutableCopy];
    locked = NO;
    _radiusOfDots = 10.f;
    _numOfDots = 6;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive:) name:kCircleActivityAnimationActive object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];

}

- (void)becomeActive:(NSNotification *)notification{

    if (_progress >= 1.0){
        [self startRotate];
    }
}


- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    if (locked){
        //[
    }
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if (locked)
    {
        [self stopAnimating];
        [self startAnimating];
    }
}


- (void)setProgress:(CGFloat)progress {
    _progress = progress;

    if (locked)
        return;

    //有效性检验
    if (progress <= 0){
        [dots removeAllObjects];
        [self.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    }

    //进度转化成数字
    CGFloat per = 1.0f/_numOfDots;

    NSInteger num = (NSInteger)floorf(_progress/per);

    //防止超出最大值
    if ( (num = MIN(num, _numOfDots)) == dots.count)
        return;



    //根据当前数量，判断增或减
    if (num > dots.count){
        //++
        for (int i = (int)dots.count; i < num; i ++){
            [self addDots:i];
        }

    }else{
        //--
        for (int i = (int)dots.count; i > num; i--){
            [self removeDots:MAX(0, i-1)];
        }
    }

    if (_progress >= 1.f)
        [self startRotate];
    else{
        [self stopRotate];
    }
}

- (void)addDots:(NSInteger)index{

    //计算点心位置
    CGFloat radius = MIN(CGRectGetHeight(self.bounds), CGRectGetWidth(self.bounds))/2 - _radiusOfDots;
    CGPoint center = (CGPoint){CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2};
    CGFloat perAngle = (CGFloat) M_PI * 2/_numOfDots;

    CGFloat angle = -perAngle * index;

    CGFloat x = cosf(angle) * radius + center.x;
    CGFloat y = - sinf(angle) * radius + center.y;

    //添加点
    CALayer *dot = [[CALayer alloc] init];
    dot.frame = CGRectMake(0, 0, 2 * _radiusOfDots, 2 * _radiusOfDots);
    dot.backgroundColor = _colors.count > 0 ? ((UIColor *)_colors[index % _numOfDots]).CGColor : UIColorFromRGB(arc4random()).CGColor;
    dot.cornerRadius = _radiusOfDots;
    dot.anchorPoint = CGPointMake(.5f, .5f);
    dot.position = CGPointMake(x, y);

    [self.layer insertSublayer:dot atIndex:0];

    [dots addObject:dot];

    //添加点出现动画
    CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scale.fromValue = @(0);
    scale.toValue = @(1);
    scale.duration = .2f;
    //scale.timingFunction = [CAMediaTimingFunction functionWithControlPoints:.82f :.12f :.49f :1.75f];
    [dot addAnimation:scale forKey:scale.keyPath];

}

- (void)removeDots:(NSInteger)index{
    if (dots.count > index){
        CALayer *dot = dots[(NSUInteger)index];

        //排除多余动画
        if ([dot valueForUndefinedKey:@"animating"])
            return;
        [dot setValue:@YES forUndefinedKey:@"animating"];

        CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scale.fromValue = @(1);
        scale.toValue = @(0);
        scale.duration = .2f;
        scale.delegate = self;
        scale.timingFunction = [CAMediaTimingFunction functionWithControlPoints:.37f :-1.0f :.29f :.87f ];
        scale.removedOnCompletion = NO;
        scale.fillMode = kCAFillModeForwards;
        [scale setValue:dot forUndefinedKey:@"obj"];
        [scale setValue:@(YES) forUndefinedKey:@"removed"];


        [dot addAnimation:scale forKey:scale.keyPath];

        [dots removeObject:dot];

    }

}


#pragma mark --
#pragma mark -- animation

- (void)stopRotate{
    locked = NO;
    [dots enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CALayer *dot = (CALayer *)obj;
        [dot removeAnimationForKey:@"rotation"];
    }];
}
- (void)startRotate{
    //must all ready
    CGFloat radius = MIN(CGRectGetHeight(self.bounds), CGRectGetWidth(self.bounds))/2 - _radiusOfDots;
    CGPoint center = (CGPoint){CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2};
    CGFloat perAngle = (CGFloat) M_PI * 2/_numOfDots;


    [dots enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {

        CALayer *dot = (CALayer *)obj;
        CGFloat angle = -perAngle * idx;

        CGMutablePathRef path = CGPathCreateMutable();
        if (_supportRunAfter){
            CALayer *first = dots[0];
            CGPathMoveToPoint(path, NULL, first.position.x, first.position.y);
            angle = 0;
        }

        CGPathAddArc(path, NULL, center.x, center.y, radius, angle, (CGFloat)(angle + 2 * M_PI), NO);


        CAKeyframeAnimation *circleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        circleAnimation.duration = _duration;
        if (_supportRunAfter)
            circleAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.15f :0.60f :0.85f :0.4f];
        [circleAnimation setCalculationMode:kCAAnimationPaced];

        if (_supportRunAfter)
            circleAnimation.beginTime = CACurrentMediaTime() + idx * (_duration / _numOfDots);;
        circleAnimation.path = path;
        circleAnimation.repeatCount = HUGE_VALF;
        [dot addAnimation:circleAnimation forKey:@"rotation"];
        CGPathRelease(path);


    }];

}



#pragma mark --
#pragma mark -- animationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (flag){
        CALayer *dot = [anim valueForUndefinedKey:@"obj"];
        BOOL removed = [[anim valueForUndefinedKey:@"removed"] boolValue];
        if (removed){
            [dot removeFromSuperlayer];
        }
    }
}

#pragma mark --
#pragma mark -- out interface

-(void)startAnimating{
    self.progress = 1.f;
    locked = YES;
}

-(void)stopAnimating{
    locked = NO;
    self.progress = 0.f;
}




@end
