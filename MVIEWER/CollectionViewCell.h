//
//  Cell.h
//  TestCollectionView
//
//  Created by Marco Meschini on 27/09/2012.
//  Copyright (c) 2012 Marco Meschini. All rights reserved.
//


@protocol DeleteCollectionViewDataSource <UICollectionViewDataSource>
@end

@interface CollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, assign) BOOL showDeleteButton;

@property (nonatomic, assign) NSObject *informOnDeletion;
@property (nonatomic, assign) SEL deleteMethod;

@end
