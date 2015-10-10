//
// Created by sunlantao on 15/4/15.
// Copyright (c) 2015 sunlantao. All rights reserved.
//

#import "CAGaussLayer.h"
#import "UIImage+Effects.h"

@implementation CAGaussLayer

@dynamic blur;
@dynamic blurAlpha;

+ (BOOL)needsDisplayForKey:(NSString *)key {
    if ([@"blur" isEqualToString:key]
        || [@"blurAlpha" isEqualToString:key]){
        return YES;
    }
    return [super needsDisplayForKey:key];
}

- (id<CAAction>)actionForKey:(NSString *)key {
    if ([key isEqualToString:@"blur"]){
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:key];
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        animation.fromValue = @([[self presentationLayer] blur]);
        return animation;
    }else if ([key isEqualToString:@"blurAlpha"]){
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:key];
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        animation.fromValue =@([self.presentationLayer blurAlpha]);

        return animation;
    }
    return [super actionForKey:key];
}
- (void)display{
    CGFloat radius = [self.presentationLayer blur];
    CGFloat alpha = [self.presentationLayer blurAlpha];

    UIImage *image = [_image imageByApplyingTintEffectWithColor:[_blurColor colorWithAlphaComponent:alpha]
                                                         radius:radius];
    [self setContents:(id)image.CGImage];
}

- (void)setImage:(UIImage *)img{
    _image = img;
    [self setContents:(id)self.image.CGImage];
}

@end