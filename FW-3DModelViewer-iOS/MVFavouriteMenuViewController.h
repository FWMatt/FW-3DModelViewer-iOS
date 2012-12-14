//
//  MVFavouriteMenuViewController.h
//  3D Model Viewer
//
//  Created by Tim Chilvers on 28/11/2012.
//  Copyright (c) 2012 Future Workshops. All rights reserved.
//

#import "MutableOrderedCollectionViewController.h"

@class MVModel;

@protocol MVFavouriteModelSelection <NSObject>

@required
- (void)favouriteModelSelected:(MVModel *)model;

@end

@interface MVFavouriteMenuViewController : MutableOrderedCollectionViewController

@property (nonatomic,assign) id <MVFavouriteModelSelection> selectionDelegate;

@end
