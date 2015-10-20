//
// Created by yucheng on 15/10/20.
// Copyright (c) 2015 ___FULLUSERNAME___. All rights reserved.
//

#import "PageLayout.h"

@implementation PageLayout

-(void)prepareLayout {
    [super prepareLayout];
}
- (NSInteger)cellCount {
    NSInteger count = 0;
    for (int i = 0; i < self.collectionView.numberOfSections; i++){
        for (int j = 0; j < [self.collectionView numberOfItemsInSection:i]; j++){
            count++;
        }
    }
    return count;
}
-(CGSize)collectionViewContentSize
{
    return CGSizeMake(CGRectGetWidth(self.collectionView.bounds) * self.cellCount,
            CGRectGetHeight(self.collectionView.bounds));
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)path {

    int index = 0;
    for (int i = 0; i < self.collectionView.numberOfSections; i++){

        BOOL found = NO;
        for (int j = 0; j < [self.collectionView numberOfItemsInSection:i]; j++){
            if (path.section == i && path.item == j){
                found = YES;
                break;
            }
            index++;
        }

        if (found) break;
    }

    UICollectionViewLayoutAttributes* attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:path];
    attributes.size = self.collectionView.bounds.size;
    attributes.center = CGPointMake(CGRectGetWidth(self.collectionView.bounds)*(1.f/2 + index),
            CGRectGetHeight(self.collectionView.bounds)/2);
    return attributes;
}

-(NSArray*)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray* attributes = [NSMutableArray array];
    for (NSInteger i=0 ; i < [self.collectionView numberOfSections]; i++) {
        for (int j = 0; j < [self.collectionView numberOfItemsInSection:i]; ++j) {
            NSIndexPath* indexPath = [NSIndexPath indexPathForItem:j inSection:i];
            [attributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
        }

    }

    for (int i=0; i < self.collectionView.numberOfSections; i++){
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:i];
        UICollectionViewLayoutAttributes *attribute = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                           atIndexPath:indexPath];
        [attributes addObject:attribute];
    }


    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {

    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:elementKind withIndexPath:indexPath];

    UICollectionViewLayoutAttributes *first = [self layoutAttributesForItemAtIndexPath:indexPath];

    attributes.size = (CGSize){CGRectGetWidth(self.collectionView.bounds), 40};

    attributes.center = CGPointMake(first.center.x, 40);

    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    CGSize cvSize = self.collectionView.bounds.size;

    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:elementKind withIndexPath:indexPath];

    attributes.size = CGSizeMake(140, 40);
    attributes.center = CGPointMake(cvSize.width/2, cvSize.height/2);

    return attributes;
}

//当边界更改时是否更新布局
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    CGRect oldBounds = self.collectionView.bounds;

    return CGRectGetWidth(newBounds) != CGRectGetWidth(oldBounds);

}

@end