//
//  FWMVRadialMenuView.h
//  3D Model Viewer
//
//  Created by Tim Chilvers on 27/11/2012.
//  Copyright (c) 2012 Future Workshops. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MVRadialMenuViewDelegate;

@interface MVRadialMenuView : UIView

@property (nonatomic,assign) NSInteger numberOfSegments;

@property (nonatomic,weak) id<MVRadialMenuViewDelegate> delegate;

@end

@protocol MVRadialMenuViewDelegate <NSObject>

@required
- (void)radialMenuView:(MVRadialMenuView *)radialMenuView didSelectIndex:(NSInteger)index;

@end
