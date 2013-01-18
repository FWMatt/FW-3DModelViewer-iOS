//
//  MyLayout.m
//  TestCollectionView
//
//  Created by Marco Meschini on 27/09/2012.
//  Copyright (c) 2012 Marco Meschini. All rights reserved.
//

#import "MutableOrderedCollectionViewFlowLayout.h"

@implementation MutableOrderedCollectionViewFlowLayout

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray* allAttributesInRect = [super layoutAttributesForElementsInRect:rect];
    [allAttributesInRect enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self _applyCustomAttributesToLayoutAttributes:obj];
    }];
    
    return allAttributesInRect;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes* attributes = [super layoutAttributesForItemAtIndexPath:indexPath];
    [self _applyCustomAttributesToLayoutAttributes:attributes];
    return attributes;
}

- (void)setGhostIndexPath:(NSIndexPath *)ghostIndexPath
{
    self->_ghostIndexPath = ghostIndexPath;
    [self invalidateLayout];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

#pragma mark - Private
- (void)_applyCustomAttributesToLayoutAttributes:(UICollectionViewLayoutAttributes*)layoutAttributes
{
    if ([layoutAttributes.indexPath isEqual:self.ghostIndexPath])
    {
        layoutAttributes.alpha = .35f;
    }
}

@end
