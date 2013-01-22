//
//  MVAxisViewController.m
//  MVIEWER
//
//  Created by Kamil Kocemba on 1/22/13.
//  Copyright (c) 2013 Future Workshops. All rights reserved.
//

#import "MVAxisViewController.h"

@interface MVAxisViewController ()<GLKViewControllerDelegate>

@property (nonatomic, strong) GLKBaseEffect *effect;

@end

@implementation MVAxisViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    self.view.opaque = NO;
    self.effect = [[GLKBaseEffect alloc] init];
    
    [self setupGL];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self setupGL];
}

- (void)setupGL {
    const GLfloat znear = 0.1f, zfar = 40.0f;
    GLfloat aspect = self.view.bounds.size.width / self.view.bounds.size.height;
    self.effect.transform.projectionMatrix = GLKMatrix4MakePerspective(120, aspect, znear, zfar);
}

- (void)setCameraModelView:(GLKMatrix4)modelview {
    self.effect.transform.modelviewMatrix = modelview;
}


#pragma mark - GLKViewControllerDelegate


- (void)glkViewControllerUpdate:(GLKViewController *)controller {

}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    
    [self.effect prepareToDraw];
    
    glEnable(GL_DEPTH_TEST);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glLineWidth(2.0f);
    
    static const GLfloat vertices[18] = {
        1.0f, 0.0f, 0.0f,// X axis
        0.0f, 0.0f, 0.0f,
        0.0f, 0.0f, 0.0f,
        0.0f, 1.0f, 0.0f, // Y axis
        0.0f, 0.0f, 0.0f,
        0.0f, 0.0f, 1.0f
    }; // Z axis

    static const GLfloat colors[24] = {
        222.0f / 255.0f, 222.0f / 255.0f, 220.0f / 255.0f, 1.0f, // x
        222.0f / 255.0f, 222.0f / 255.0f, 220.0f / 255.0f, 1.0f, // x
         44.0f / 255.0f,  41.0f / 255.0f,  41.0f / 255.0f, 1.0f, // y
         44.0f / 255.0f,  41.0f / 255.0f,  41.0f / 255.0f, 1.0f, // y
        246.0f / 255.0f, 139.0f / 255.0f,  26.0f / 255.0f, 1.0f, // z
        246.0f / 255.0f, 139.0f / 255.0f,  26.0f / 255.0f, 1.0f // z
    };

    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glEnableVertexAttribArray(GLKVertexAttribColor);

    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, vertices);
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, 0, colors);

    glDrawArrays(GL_LINES, 0, 6);

    glDisableVertexAttribArray(GLKVertexAttribPosition);
    glDisableVertexAttribArray(GLKVertexAttribColor);
}


@end
