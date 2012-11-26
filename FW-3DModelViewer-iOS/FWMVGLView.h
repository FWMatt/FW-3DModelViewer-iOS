//
//  FWMVGLView.h
//  FW-3DModelViewer-iOS
//
//  Created by Tim Chilvers on 22/11/2012.
//  Copyright (c) 2012 Future Workshops. All rights reserved.
//

#import <GLKit/GLKit.h>

@class GLModel;

@interface FWMVGLView : GLKView <UIGestureRecognizerDelegate>

@property (nonatomic,retain) GLModel *model;

@end
