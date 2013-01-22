//
//  MVSlidingMenuViewController.m
//  MVIEWER
//
//  Created by Kamil Kocemba on 1/22/13.
//  Copyright (c) 2013 Future Workshops. All rights reserved.
//

#import "MVSlidingMenuViewController.h"

@implementation MVSlidingMenuViewController

- (void) loadView {
    [super loadView];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"menu-bg"]];
    
    self.collectionView.frame = CGRectOffset(self.view.bounds, 0.0f, 26.0f);
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.contentInset = UIEdgeInsetsMake(0.0, 30.0f, 0.0f, 30.0f);
    self.collectionView.dataSource = self;
    
    
    UIFont *buttonFont = [UIFont fontWithName:@"Avenir-Light" size:20.0f];
    UIColor *lightGrayColor = [UIColor colorWithRed:222.0f / 255.0f green:222.0f / 255.0f blue:222.0f / 255.0f alpha:1.0f];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(36.0f, -10.0f, 120.0f, 40)];
    titleLabel.backgroundColor = lightGrayColor;
    titleLabel.textColor = [UIColor colorWithRed:44.0f / 255.0f green:41.0f / 255.0f blue:41.0f / 255.0f alpha:1.0f];
    titleLabel.font = buttonFont;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
    
    self.titleLabel = titleLabel;
}

- (void)viewDidLoad {
    self.collectionView.allowsReordering = NO;
}

+ (MutableOrderedCollectionViewFlowLayout *)defaultCollectionViewFlowLayout {
    return [[[self class] layoutsArray] objectAtIndex:0];
}

+ (NSArray *)layoutsArray {
    static NSArray *_array = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        MutableOrderedCollectionViewFlowLayout *l0 = [[MutableOrderedCollectionViewFlowLayout alloc] init];
        l0.itemSize = CGSizeMake(208, 161);
        l0.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        l0.minimumInteritemSpacing = .0f;
        _array = @[l0];
    });
    
    return _array;
}

#pragma mark - UICollectionViewDataSource

- (void)collectionView:(UICollectionView *)collectionView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {

}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

}

@end
