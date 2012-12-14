//
//  MVGLModelView.h
//  3D Model Viewer
//
//  Created by Tim Chilvers on 22/11/2012.
//  Copyright (c) 2012 Future Workshops. All rights reserved.
//

#import "GLView.h"

@class MVModel;
@class GLLight;

@interface MVGLModelView : GLView <UIGestureRecognizerDelegate>

@property (nonatomic, strong) MVModel *model;
@property (nonatomic, strong) GLLight *light;

@end
