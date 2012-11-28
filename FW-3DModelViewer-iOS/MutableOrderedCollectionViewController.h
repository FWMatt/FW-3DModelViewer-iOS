//
//  MutableOrderedCollectionViewController.h
//  TestCollectionView
//
//  Created by Marco Meschini on 03/10/2012.
//  Copyright (c) 2012 Marco Meschini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MutableOrderedCollectionViewFlowLayout.h"

@protocol MutableOrderedCollectionViewDataSource <UICollectionViewDataSource>
- (void)collectionView:(UICollectionView *)collectionView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath;
@end

@interface MutableOrderedCollectionView : UICollectionView
@property (nonatomic, weak) id <MutableOrderedCollectionViewDataSource> dataSource;
@end

@interface MutableOrderedCollectionViewController : UIViewController

@property (nonatomic, readonly, strong) MutableOrderedCollectionView *collectionView;

+ (MutableOrderedCollectionViewFlowLayout *)defaultCollectionViewFlowLayout;

@end
