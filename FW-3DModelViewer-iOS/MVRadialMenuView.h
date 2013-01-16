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

@property (nonatomic, weak) id<MVRadialMenuViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame segments:(NSArray *)segments;

- (void)toggleAnimated:(BOOL)animated;
- (void)showAnimated:(BOOL)animated;
- (void)hideAnimated:(BOOL)animated;

@end

@protocol MVRadialMenuViewDelegate <NSObject>

@required

- (void)radialMenuView:(MVRadialMenuView *)radialMenuView didSelectIndex:(NSInteger)index;
- (void)radialMenuViewWillHide:(MVRadialMenuView *)radialMenuView;

@end
