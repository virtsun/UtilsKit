//
//  SimilarTopBar.m
//  Emitter
//
//  Created by sunlantao on 15/7/16.
//  Copyright (c) 2015年 sunlantao. All rights reserved.
//

#import "SimilarTopBar.h"

#define kSimilarDefaultInsets (UIEdgeInsets){22, 16, 0, 16}
#define kSimilarItemDefaultMargin 10

@interface SimilarTopBar()

@property(nonatomic, strong) UILabel *titleLabel;

@end

@implementation SimilarTopBar

+ (instancetype) topBar{
    CGRect frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 64);
    return [[SimilarTopBar alloc] initWithFrame:frame];
}

- (id)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]){
        _insets = kSimilarDefaultInsets;
        _itemMargin = kSimilarItemDefaultMargin;
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
      //  _titleLabel.backgroundColor = UIColorFromRGB(0xff0000);

        [self insertSubview:_titleLabel atIndex:0];
    }
    
    return self;
}
-(void)checkHiddenState {
    self.hidden = !_title && self.leftItems.count == 0 && self.rightItems.count == 0;
}
#pragma mark --
#pragma mark -- setter & getter

- (void)setTitle:(NSString *)title{
    _title = _titleLabel.text = title;
    [self checkHiddenState];

    [self setNeedsLayout];
}

- (void)setAttributes:(NSDictionary *)attributes{
    
    [attributes.allKeys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isEqualToString:kSimilarTittleColor]) {
            _titleLabel.textColor = attributes[obj];
        }else if ([obj isEqualToString:kSimilarTittleFont]) {
            _titleLabel.font = attributes[obj];
        }else if ([obj isEqualToString:kSimilarBackgroundColor]) {
            self.backgroundColor = attributes[obj];
        }
    }];
}

- (void)setLeftItems:(NSArray *)leftItems{
    _leftItems = leftItems;
    [leftItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UIView class]]){
            [self addSubview:obj];
        }
    }];
    
    [self setNeedsLayout];
    [self checkHiddenState];
}

- (void)setRightItems:(NSArray *)rightItems{
    _rightItems = rightItems;
    [rightItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UIView class]]){
            [self addSubview:obj];
        }
    }];
    
    [self setNeedsLayout];
    [self checkHiddenState];
}

#pragma mark --
#pragma mark -- layout
- (void)layoutSubviews{
    [super layoutSubviews];


    self.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), 64);
    CGFloat h = CGRectGetHeight(self.bounds) - _insets.top - _insets.bottom;

    __block CGFloat leftOffset = 0.f;
    __block CGFloat rightOffset = 0.f;

    [_leftItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *item = (UIView*)obj;
        item.frame = CGRectMake(_insets.left + leftOffset ,
                                _insets.top + (h - CGRectGetHeight(item.frame))/2,
                                CGRectGetWidth(item.bounds),
                                CGRectGetHeight(item.bounds));

        leftOffset += CGRectGetWidth(item.bounds) + _itemMargin;
    }];

    [_rightItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *item = (UIView*)obj;
        item.frame = CGRectMake(CGRectGetWidth(self.bounds) - (_insets.right+ CGRectGetWidth(item.bounds) + rightOffset) ,
                                _insets.top + (h - CGRectGetHeight(item.frame))/2,
                                CGRectGetWidth(item.bounds),
                                CGRectGetHeight(item.bounds));

        rightOffset += CGRectGetWidth(item.bounds) + _itemMargin;
    }];

    CGFloat titleCanUserWidth = CGRectGetWidth(self.bounds) - 60 - MAX(_insets.left, _insets.right)*2;

    titleCanUserWidth -= (MAX(leftOffset, rightOffset)) * 2;

    CGSize size = [_titleLabel.text sizeWithAttributes:@{NSFontAttributeName: _titleLabel.font}];
    CGFloat w = MIN(size.width, titleCanUserWidth);
    _titleLabel.frame = CGRectMake((CGRectGetWidth(self.bounds) - w)/2,
            _insets.top,
            w, h);


}

@end
