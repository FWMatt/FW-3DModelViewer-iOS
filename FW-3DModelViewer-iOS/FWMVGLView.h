//
//  FWMVGLView.h
//  FW-3DModelViewer-iOS
//
//  Created by Tim Chilvers on 22/11/2012.
//  Copyright (c) 2012 Future Workshops. All rights reserved.
//

#import <GLKit/GLKit.h>

@class GLModel;

@interface FWMVGLView : GLKView

@property (nonatomic,retain,readonly) GLModel *model;

- (void)useModelNamed:(NSString *)modelName;

@end
