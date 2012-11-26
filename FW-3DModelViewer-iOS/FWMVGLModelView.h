//
//  FWMVGLView.h
//  FW-3DModelViewer-iOS
//
//  Created by Tim Chilvers on 22/11/2012.
//  Copyright (c) 2012 Future Workshops. All rights reserved.
//

#import "GLModelView.h"

@class GLModel;
@class GLImage;

@interface FWMVGLModelView : GLModelView <UIGestureRecognizerDelegate>

@property (nonatomic,retain) GLModel *model;
@property (nonatomic, strong) GLImage *texture;
@property (nonatomic, strong) UIColor *blendColor;
@property (nonatomic, copy) NSArray *lights;
@property (nonatomic, assign) CATransform3D transform;

@end
