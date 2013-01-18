//
//  MVCameraController.h
//  3D Model Viewer
//
//  Created by Kamil Kocemba on 19/12/2012.
//  Copyright (c) 2012 Future Workshops. All rights reserved.
//

@interface MVCameraController : NSObject

- (id)initWithView:(UIView *)view;
- (void)reset;

- (GLKMatrix4)getModelview;

@end
