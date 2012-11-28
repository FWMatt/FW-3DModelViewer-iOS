//
//  FWMVRadialMenuView.h
//  FW-3DModelViewer-iOS
//
//  Created by Tim Chilvers on 27/11/2012.
//  Copyright (c) 2012 Future Workshops. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FWRadialMenuViewDelegate;

@interface FWMVRadialMenuView : UIView

@property (nonatomic,assign) NSInteger numberOfSegments;

@property (nonatomic,weak) id<FWRadialMenuViewDelegate> delegate;

@end

@protocol FWRadialMenuViewDelegate <NSObject>

@required
- (void)radialMenuView:(FWMVRadialMenuView *)radialMenuView didSelectIndex:(NSInteger)index;

@end
