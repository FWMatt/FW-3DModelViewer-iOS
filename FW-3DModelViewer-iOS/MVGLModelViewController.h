//
//  MVGLModelViewController.h
//  3D Model Viewer
//
//  Created by Tim Chilvers on 26/11/2012.
//  Copyright (c) 2012 Future Workshops. All rights reserved.
//

@class MVModel;

@interface MVGLModelViewController : GLKViewController

- (void)loadModel:(MVModel *)model;

@end
