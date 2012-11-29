//
//  Cell.h
//  TestCollectionView
//
//  Created by Marco Meschini on 27/09/2012.
//  Copyright (c) 2012 Marco Meschini. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DeleteCollectionViewDataSource <UICollectionViewDataSource>



@end

@interface CollectionViewCell : UICollectionViewCell
{
    UIImageView *_imageView;
}

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, readonly, strong) UIView *decoratorView;
@property (nonatomic, assign) BOOL showDeleteButton;

@property (nonatomic, assign) NSObject *informOnDeletion;
@property (nonatomic, assign) SEL deleteMethod;

@end
