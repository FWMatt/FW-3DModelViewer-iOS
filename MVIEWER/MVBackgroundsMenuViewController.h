//
//  MVBackgroundsMenuViewController.h
//  MVIEWER
//
//  Created by Kamil Kocemba on 1/22/13.
//  Copyright (c) 2013 Future Workshops. All rights reserved.
//

#import "MVSlidingMenuViewController.h"

@protocol MVBackgroundSelection <NSObject>

@required

- (void)backgroundSelected:(UIImage *)image;

@end

@interface MVBackgroundsMenuViewController : MVSlidingMenuViewController

@property (nonatomic, weak) id<MVBackgroundSelection> selectionDelegate;

@end
