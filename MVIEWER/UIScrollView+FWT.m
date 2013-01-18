//
//  UIScrollView+FWT.m
//  TestCollectionView
//
//  Created by Marco Meschini on 04/10/2012.
//  Copyright (c) 2012 Marco Meschini. All rights reserved.
//

#import "UIScrollView+FWT.h"

@implementation UIScrollView (FWT)

- (CGFloat)minimumScrollDistance
{
    CGFloat toReturn = .0f;
    if (self.contentSize.width > CGRectGetWidth(self.bounds))
        toReturn = self.contentOffset.x;
    else if (self.contentSize.height > CGRectGetHeight(self.bounds))
        toReturn = self.contentOffset.y;
    
    return toReturn * -1;
}

- (CGFloat)maximumScrollDistance
{
    CGFloat toReturn = .0f;
    if (self.contentSize.width > CGRectGetWidth(self.bounds))
        toReturn = self.contentSize.width - (CGRectGetWidth(self.bounds) + self.contentOffset.x);
    else if (self.contentSize.height > CGRectGetHeight(self.bounds))
        toReturn = self.contentSize.height - (CGRectGetHeight(self.bounds) + self.contentOffset.y);
    
    return toReturn;
}

@end
