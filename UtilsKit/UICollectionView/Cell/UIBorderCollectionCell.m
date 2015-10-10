//
// Created by sunlantao on 15/7/31.
// Copyright (c) 2015 sunlantao. All rights reserved.
//

#import "UIBorderCollectionCell.h"


@implementation UIBorderCollectionCell


- (void)setBorders:(CollectionBorderType)borders {
    _borders = borders;
    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];

    CGContextRef context = UIGraphicsGetCurrentContext();

    CGFloat r,g,b,a;

    [self.backgroundColor getRed:&r
                   green:&g
                    blue:&b
                   alpha:&a];

    CGContextClearRect(context, rect);
    CGContextSetRGBFillColor(context, r, g, b, a);
    CGContextAddRect(context, rect);

    CGContextDrawPath(context, kCGPathFill);

    [_borderColor getRed:&r
                   green:&g
                    blue:&b
                   alpha:&a];

    CGContextSetRGBStrokeColor(context, r, g, b, a);
    CGContextSetLineWidth(context, _borderWidth);

    if (kCollectionBorderTop & _borders){
        CGContextMoveToPoint(context, 0, 0);
        CGContextAddLineToPoint(context, CGRectGetWidth(rect), 0);
    }
    if(kCollectionBorderBottom & _borders){
        CGContextMoveToPoint(context, 0, CGRectGetHeight(rect) - _borderWidth );
        CGContextAddLineToPoint(context, CGRectGetWidth(rect), CGRectGetHeight(rect) - _borderWidth);
    }
    if(kCollectionBorderLeft & _borders){
        CGContextMoveToPoint(context, 0, 0);
        CGContextAddLineToPoint(context, 0, CGRectGetHeight(self.bounds));
    }

    if(kCollectionBorderRight & _borders){
        CGContextMoveToPoint(context, CGRectGetWidth(rect) - _borderWidth, 0);
        CGContextAddLineToPoint(context, CGRectGetWidth(rect)- _borderWidth, CGRectGetHeight(rect));
    }
   // CGContextScaleCTM(context, [UIScreen mainScreen].scale, [UIScreen mainScreen].scale);

    CGContextDrawPath(context, kCGPathStroke);


}

@end