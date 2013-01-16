//
//  MVScene.m
//  3D Model Viewer
//
//  Created by Kamil Kocemba on 19/12/2012.
//  Copyright (c) 2012 Future Workshops. All rights reserved.
//

#import "MVScene.h"

@interface MVScene ()

@property (nonatomic, strong) GLKBaseEffect *effect;

@end

@implementation MVScene

- (id)init {
    if ((self = [super init])) {
        self.effect = [[GLKBaseEffect alloc] init];
    }
    return self;
}

- (void)setProjectionMatrix:(GLKMatrix4)projection {
    self.effect.transform.projectionMatrix = projection;
}

- (void)setModelviewMatrix:(GLKMatrix4)modelview {
    self.effect.transform.modelviewMatrix = GLKMatrix4Scale(modelview, 0.6f, 0.6f, 0.6f);
}

- (void)draw {
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    
    [self.effect prepareToDraw];
    
    glEnable(GL_DEPTH_TEST);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
//    static const GLfloat vertices[18] = {
//        1.0f, 0.0f, 0.0f,// X axis
//        0.0f, 0.0f, 0.0f,
//        0.0f, 0.0f, 0.0f,
//        0.0f, 1.0f, 0.0f, // Y axis
//        0.0f, 0.0f, 0.0f,
//        0.0f, 0.0f, 1.0f
//    }; // Z axis
//    
//    static const GLfloat colors[24] = {
//        1.0f, 0.0f, 0.0f, 1.0f, // x
//        1.0f, 0.0f, 0.0f, 1.0f,
//        0.0f, 1.0f, 0.0f, 1.0f, // y
//        0.0f, 1.0f, 0.0f, 1.0f,
//        0.0f, 0.0f, 1.0f, 1.0f, // z
//        0.0f, 0.0f, 1.0f, 1.0f
//    };
//    
//    
//
//    glEnableVertexAttribArray(GLKVertexAttribPosition);
//    glEnableVertexAttribArray(GLKVertexAttribColor);
//    
//    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, vertices);
//    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, 0, colors);
//    
//    glDrawArrays(GL_LINES, 0, 6);
//    
//    
//    glDisableVertexAttribArray(GLKVertexAttribPosition);
//    glDisableVertexAttribArray(GLKVertexAttribColor);
}


@end
