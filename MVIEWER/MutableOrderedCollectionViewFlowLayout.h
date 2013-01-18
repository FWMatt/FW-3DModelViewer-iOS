//
//  MyLayout.h
//  TestCollectionView
//
//  Created by Marco Meschini on 27/09/2012.
//  Copyright (c) 2012 Marco Meschini. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MutableOrderedCollectionViewFlowLayout : UICollectionViewFlowLayout
@property (nonatomic, strong) NSIndexPath *ghostIndexPath;

@end
