//
//  UICollectionView+FWT.m
//  TestCollectionView
//
//  Created by Marco Meschini on 03/10/2012.
//  Copyright (c) 2012 Marco Meschini. All rights reserved.
//

#import "UICollectionView+FWT.h"

@implementation UICollectionView (FWT)

- (NSIndexPath *)indexPathForItemInRect:(CGRect)rect
{
    __block CGFloat maxArea = .0f;
    __block NSInteger index = NSNotFound;
    NSArray *tmp = [self.collectionViewLayout layoutAttributesForElementsInRect:rect];
    [tmp enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *attribute, NSUInteger idx, BOOL *stop) {
        
        CGRect intersection = CGRectIntersection(attribute.frame, rect);
        CGFloat currentArea = intersection.size.width*intersection.size.height;
        if (currentArea > maxArea)
        {
            maxArea = currentArea;
            index = idx;
        }
    }];
    
    if (index != NSNotFound)
        return [[tmp objectAtIndex:index] indexPath];
    
    return nil;
}

@end
