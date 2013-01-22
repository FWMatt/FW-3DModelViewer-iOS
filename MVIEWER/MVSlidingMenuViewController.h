//
//  MVSlidingMenuViewController.h
//  MVIEWER
//
//  Created by Kamil Kocemba on 1/22/13.
//  Copyright (c) 2013 Future Workshops. All rights reserved.
//

#import "MutableOrderedCollectionViewController.h"

@interface MVSlidingMenuViewController : MutableOrderedCollectionViewController<MutableOrderedCollectionViewDataSource>

@property (nonatomic, strong) UILabel *titleLabel;

@end
