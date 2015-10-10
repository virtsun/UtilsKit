//
// Created by sunlantao on 15/7/31.
// Copyright (c) 2015 sunlantao. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum :int {
    kCollectionBorderTop = 0x0001,
    kCollectionBorderBottom = 0x0010,
    kCollectionBorderLeft = 0x0100,
    kCollectionBorderRight = 0x1000,
    kCollectionBorderAll = 0x1111
}CollectionBorderType;

@interface UIBorderCollectionCell : UICollectionViewCell

@property (nonatomic) CollectionBorderType borders;
@property (nonatomic) CGFloat borderWidth;
@property (nonatomic, copy) UIColor *borderColor;

@end


