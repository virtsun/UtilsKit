//
// Created by sunlantao on 15/8/12.
// Copyright (c) 2015 sunlantao. All rights reserved.
//

#import "UKTBlurCarousel.h"
#import "UIImage+Effects.h"
#import "UIImage+ThumbnailImage.h"


@implementation UKTBlurCarousel {
}

- (void)setBlurRadius:(CGFloat)blurRadius {
    _blurRadius = blurRadius;

    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if (self.numPagesOfCarousel == 0) {
        return;
    }

    UIImageView *imageView = self.imageViews[(NSUInteger)self.currentPageIndex];
    UKTCarouselObject *item = self.objects[(NSUInteger)self.currentPageIndex];

    if (_blurColor && _blurRadius > 0){
        if (!item.blurImage) item.blurImage = item.image;
        imageView.image = [item.blurImage imageByApplyingTintEffectWithColor:_blurColor
                                                                      radius:_blurRadius];
    } else {
        imageView.image = item.image;
    }

}

- (void)reloadData {
    [super reloadData];

    [self.objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UKTCarouselObject *item = obj;
        item.blurImage = [item.image thumbnailWithImageWithoutScale:CGSizeMake(CGRectGetWidth(self.bounds), CGRectGetWidth(self.bounds))];
    }];
}
@end