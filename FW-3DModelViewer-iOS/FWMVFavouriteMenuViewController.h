//
//  FWMVFavouriteMenuViewController.h
//  FW-3DModelViewer-iOS
//
//  Created by Tim Chilvers on 28/11/2012.
//  Copyright (c) 2012 Future Workshops. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MutableOrderedCollectionViewController.h"

@protocol FWMVFavouriteModelSelection <NSObject>

@required
- (void)favouriteModelSelectedWithName:(NSString *)modelPath;

@end

@interface FWMVFavouriteMenuViewController : MutableOrderedCollectionViewController

@property (nonatomic,assign) id <FWMVFavouriteModelSelection> selectionDelegate;

@end
