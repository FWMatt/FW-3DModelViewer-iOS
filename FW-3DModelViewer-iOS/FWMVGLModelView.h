//
//  FWMVGLView.h
//  FW-3DModelViewer-iOS
//
//  Created by Tim Chilvers on 22/11/2012.
//  Copyright (c) 2012 Future Workshops. All rights reserved.
//


@class GLModel;

#import "FWMVGLView.h"

@interface FWMVGLModelView : FWMVGLView <UIGestureRecognizerDelegate>

@property (nonatomic,retain) GLModel *model;

@end
