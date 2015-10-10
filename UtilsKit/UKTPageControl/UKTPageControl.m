//
// Created by sunlantao on 15/8/12.
// Copyright (c) 2015 ___FULLUSERNAME___. All rights reserved.
//

#import "UKTPageControl.h"

#define kUKTPageControlMinHeight 20
#define kUKTPageControlMargin 10

@implementation UKTPageControlItem {

}

- (void)setSelected:(BOOL)selected {

    if ( (_selected = selected) ){
        self.fillColor = _selectedFillColor;
        self.strokeColor = _selectedStrokeColor;
    }else{
        self.fillColor = _unselectedFilColor;
        self.strokeColor = _unselectedStrokeColor;
    }
    [self setNeedsDisplay];

}

#pragma mark --
#pragma mark -- override

@end


@implementation UKTPageControl {

    NSMutableArray *points;

}

- (id)initWithFrame:(CGRect)frame {

    if (self = [super initWithFrame:frame]){

        points = [NSMutableArray new];
        _margin = kUKTPageControlMargin;

        _fillColor = [[UIColor brownColor] colorWithAlphaComponent:0.5f];
        _selectedFillColor = [UIColor brownColor];

        CGMutablePathRef tmp = CGPathCreateMutable();
        CGPathAddEllipseInRect(tmp, NULL, CGRectMake(0, 0, 10, 10));

        _path = CGPathCreateCopyByTransformingPath(tmp, NULL);

        CFRelease(tmp);

    }

    return self;
}

#pragma --
#pragma -- setter & getter
- (void)setNumberOfPages:(NSUInteger)numberOfPages {
    _numberOfPages = numberOfPages;

    [self makeup];

    [self setNeedsLayout];
}

- (void)setCurrentPage:(NSUInteger)currentPage {
    _currentPage = currentPage;

    [points enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UKTPageControlItem *point = obj;
        point.selected = (idx == _currentPage);
    }];
    [self setNeedsLayout];
}

- (void)setFillColor:(UIColor *)fillColor {
    _fillColor = [fillColor copy];
    [self display];
}

- (void)setStrokeColor:(UIColor *)strokeColor {
    _strokeColor = [strokeColor copy];
    [self display];

}
- (void)setSelectedFillColor:(UIColor *)selectedFillColor {
    _selectedFillColor = [selectedFillColor copy];
    [self display];
}

- (void)setSelectedStrokeColor:(UIColor *)selectedStrokeColor {
    _selectedStrokeColor = [selectedStrokeColor copy];

    [self display];
}

- (void)setLineWidth:(CGFloat)lineWidth {
    _lineWidth = lineWidth;

    [self display];
}
#pragma --
#pragma -- layout
- (void)makeup{
    [points makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [points removeAllObjects];

    for (size_t i = 0; i < _numberOfPages; i++){

        UKTPageControlItem *point = [UKTPageControlItem layer];
        point.unselectedFilColor = _fillColor.CGColor;
        point.unselectedStrokeColor = _strokeColor.CGColor;
        point.selectedFillColor = _selectedFillColor.CGColor;
        point.selectedStrokeColor = _selectedStrokeColor.CGColor;
        point.lineWidth = _lineWidth;

        point.selected = (i == _currentPage);

        point.anchorPoint = CGPointMake(0.5f, .5f);
        point.path = _path;

        [points addObject:point];

        [self.layer insertSublayer:point atIndex:0];

    }

}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect bounds = CGPathGetBoundingBox(_path);

    CGRect frame = self.frame;
    frame.size.width = CGRectGetWidth(bounds) * _numberOfPages + _margin * (_numberOfPages - 1);
    frame.size.height = MAX(kUKTPageControlMinHeight, CGRectGetHeight(bounds));
    self.frame = frame;

    [points enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CAShapeLayer *layer = (CAShapeLayer *)obj;
        layer.position = CGPointMake(idx * (CGRectGetWidth(bounds) + _margin),
                CGRectGetHeight(frame)/2 - CGRectGetHeight(bounds)/2);

    }];
}

- (void)display{
    [points enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UKTPageControlItem *point = obj;
        point.unselectedFilColor = _fillColor.CGColor;
        point.unselectedStrokeColor = _strokeColor.CGColor;
        point.selectedFillColor = _selectedFillColor.CGColor;
        point.selectedStrokeColor = _selectedStrokeColor.CGColor;
        point.lineWidth = _lineWidth;

        point.selected = (idx == _currentPage);

        [point setNeedsDisplay];

    }];
}
@end