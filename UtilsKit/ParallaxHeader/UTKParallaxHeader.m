//
//  UTKParallaxHeader.m
//  UTKParallaxHeader
//
//  Created by l.t.zero  on 24/8/15.
//  Copyright (c) 2015 sunlantao. All rights reserved.

//

#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

#import "UTKParallaxHeader.h"

@interface UTKParallaxHeader ()
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@end

#define kDefaultHeaderFrame CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)

static CGFloat kParallaxDeltaFactor = 0.5f;///视差深度

@implementation UTKParallaxHeader


- (void)dealloc{
    [self.attachment destroy];
}

+ (id)headerWithSize:(CGSize)headerSize; {
    UTKParallaxHeader *headerView = [[UTKParallaxHeader alloc] initWithFrame:CGRectMake(0, 0, headerSize.width, headerSize.height)];
    return headerView;
}


- (id)initWithFrame:(CGRect)frame {

    if (self = [super initWithFrame:frame]){
        [self setup];
    }

    return self;
}

- (void)awakeFromNib {
    [self setup];
}


- (void)setOffset:(CGPoint)offset {
    CGRect frame = self.scrollView.frame;
    _offset = CGPointMake(offset.x, offset.y + CGRectGetHeight(self.bounds));

    if (_offset.y > 0)
    {
        frame.origin.y = MAX(_offset.y *kParallaxDeltaFactor, 0);
        self.scrollView.frame = frame;
        self.clipsToBounds = YES;
    }
    else
    {
        CGRect rect = kDefaultHeaderFrame;
        CGFloat delta = (CGFloat)fabs((CGFloat)MIN(0.0f, _offset.y));
        rect.origin.y -= delta;
        rect.size.height += delta;
        self.scrollView.frame = rect;
        self.clipsToBounds = NO;
    }

    if ([_delegate respondsToSelector:@selector(parallaxZoomin:)]){
        [_delegate parallaxZoomin:_offset.y/CGRectGetHeight(self.bounds)];
    }
}

#pragma mark -
#pragma mark Private

- (void)setup {
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    [self addSubview: _scrollView];
}

- (void)setContentView:(UIView *)contentView {
    [_contentView removeFromSuperview];

    _contentView = contentView;
    _contentView.autoresizingMask = ~UIViewAutoresizingNone | UIViewAutoresizingFlexibleWidth;
    _contentView.contentMode = UIViewContentModeScaleAspectFill;
    [self.scrollView addSubview:_contentView];
}



@end


///UIScrollView(ParallaxScroll)

@implementation UIScrollView(ParallaxScroll)

@dynamic parallaxHeader;


- (void)destroy{
    [self removeObserver:self forKeyPath:@"contentOffset"];
}

- (void)setParallaxHeader:(UTKParallaxHeader *)header {
    if (self.parallaxHeader){
        [self.parallaxHeader removeFromSuperview];
    }

    header.attachment = self;

    [self addSubview:header];

    ///处理偏移
    self.contentInset = UIEdgeInsetsMake(CGRectGetHeight(header.frame), 0, 0, 0);
    header.frame = CGRectMake(0, - CGRectGetHeight(header.frame), CGRectGetWidth(header.frame), CGRectGetHeight(header.frame));
    self.contentOffset = CGPointMake(0, -CGRectGetHeight(header.frame));
    objc_setAssociatedObject(self, "parallaxHeader", header, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    [self addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
}

- (UTKParallaxHeader *)parallaxHeader {
    return objc_getAssociatedObject(self, "parallaxHeader");
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {

    if ([keyPath isEqualToString:@"contentOffset"]){
        CGPoint offset = [change[@"new"] CGPointValue];
        self.parallaxHeader.offset = offset;
    }
}

@end


// 版权属于原作者
