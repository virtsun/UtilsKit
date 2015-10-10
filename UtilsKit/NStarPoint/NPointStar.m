//
// Created by sunlantao on 15/8/10.
// Copyright (c) 2015 ___FULLUSERNAME___. All rights reserved.
//

#import "NPointStar.h"


@implementation NPointStar {

}

- (id)init {

    if (self = [super init]){
        _numOfPoints = 5;
        _radiusOfOuterCircle = 32;
        _radiusOfInnerCircle = 20;
        _numOfStars = 2;

//        self.backgroundColor = [UIColor clearColor].CGColor;
 //       self.fillColor = [UIColor clearColor].CGColor;
  //      self.strokeColor = [UIColor redColor].CGColor;
        self.fillMode = kCAFillRuleNonZero;

        [self setNeedsDisplay];
    }
    return self;
}

- (void)setLineColor:(UIColor *)lineColor {
    self.strokeColor = lineColor.CGColor;
    [self setNeedsDisplay];
}

- (void)setRadiusOfOuterCircle:(CGFloat)radiusOfOuterCircle {
    _radiusOfOuterCircle = radiusOfOuterCircle;

    [self setNeedsDisplay];
}

- (void)setRadiusOfInnerCircle:(CGFloat)radiusOfInnerCircle {
    _radiusOfInnerCircle = radiusOfInnerCircle;

    [self setNeedsDisplay];
}

- (void)setNumOfStars:(uint16_t)numOfStars {
    _numOfStars = numOfStars;
    [self setNeedsDisplay];
}

- (void)setNumOfPoints:(uint16_t)numOfPoints {
    _numOfPoints = numOfPoints;

    [self setNeedsDisplay];
}

- (void)display {
    self.frame = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame), _radiusOfOuterCircle * _numOfStars * 2, _radiusOfOuterCircle *2);

    //画第一个圆
    CGFloat perAngle = (CGFloat) M_PI * 2 / _numOfPoints;

    CGMutablePathRef path = CGPathCreateMutable();

    for(size_t n = 0; n < _numOfStars; n++){
        CGPoint center = (CGPoint){_radiusOfOuterCircle * (2*n+1), _radiusOfOuterCircle};
        CGPathMoveToPoint(path, NULL, center.x, 0);

        for (size_t i = 0; i < _numOfPoints; i++){

            //先取内圆 点
            CGFloat x = center.x + cosf((CGFloat)(perAngle * i + M_PI_2 + perAngle/2)) * _radiusOfInnerCircle;
            CGFloat y = center.y - sinf((CGFloat)(perAngle * i + M_PI_2 + perAngle/2)) * _radiusOfInnerCircle;

            CGPathAddLineToPoint(path, NULL, x, y);

            x = center.x + cosf((CGFloat)(perAngle * i + M_PI_2 + perAngle)) * _radiusOfOuterCircle;
            y = center.y - sinf((CGFloat)(perAngle * i + M_PI_2 + perAngle)) * _radiusOfOuterCircle;
            CGPathAddLineToPoint(path, NULL, x, y);

        }
    }


    self.path = path;

    CFRelease(path);

}

@end


@implementation NPointStarRatingPanel {
    NPointStar *mask;
    CALayer *scoreLayer;
    NPointStar *borderLayer;
}

- (id)init {

    if (self = [super init]){

        mask = [[NPointStar alloc] init];
        mask.numOfStars = 5;
        mask.numOfPoints = 5;
        _depth = 0.6f;

        [self.layer setMask:mask];

        self.userInteractionEnabled = YES;

        scoreLayer = [CALayer layer];
        scoreLayer.backgroundColor = [UIColor redColor].CGColor;

        [self.layer addSublayer:scoreLayer];

        borderLayer = [NPointStar layer];

        borderLayer.numOfStars = 5;
        borderLayer.numOfPoints = 5;

        borderLayer.fillColor = [UIColor clearColor].CGColor;
        borderLayer.frame = self.bounds;

        [self.layer addSublayer:borderLayer];

    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];

    [self setNeedsDisplay];

}

- (void)setDepth:(CGFloat)depth {
    _depth = depth;

    [self setNeedsDisplay];
}

- (void)setScore:(CGFloat)score {
    _score = MIN(100, score);
    [self setNeedsDisplay];
}

- (void)setScoreColor:(UIColor *)scoreColor {
    _scoreColor = [scoreColor copy];
    scoreLayer.backgroundColor = scoreColor.CGColor;
    borderLayer.strokeColor = scoreColor.CGColor;
}

- (void)drawRect:(CGRect)rect {

    mask.frame = self.bounds;

    mask.radiusOfOuterCircle = CGRectGetHeight(self.bounds)/2;
    mask.radiusOfInnerCircle = mask.radiusOfOuterCircle * _depth;

    borderLayer.radiusOfOuterCircle = CGRectGetHeight(self.bounds)/2;
    borderLayer.radiusOfInnerCircle = mask.radiusOfOuterCircle * _depth;

    scoreLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds)*_score/100, CGRectGetHeight(self.bounds));
}


#pragma mark --
#pragma mark -- 滑动打分

- (void)setSupportScore:(BOOL)supportScore {
    _supportScore = supportScore;
    self.userInteractionEnabled = supportScore;
}

- (CGPoint)location:(NSSet *)touches{
    UITouch *touch = [touches anyObject];
    return [touch locationInView:self];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    CGPoint tmp = [self location:touches];
    CGFloat w = CGRectGetWidth(self.bounds);
    self.score = tmp.x * 100/ w ;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];

    CGPoint tmp = [self location:touches];
    CGFloat w = CGRectGetWidth(self.bounds);
    self.score = tmp.x * 100/ w;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];

    CGPoint tmp = [self location:touches];
    CGFloat w = CGRectGetWidth(self.bounds);
    self.score = tmp.x * 100/ w;
}

@end