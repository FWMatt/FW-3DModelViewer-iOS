//
//  MVGLModelViewController.m
//  3D Model Viewer
//
//  Created by Tim Chilvers on 26/11/2012.
//  Copyright (c) 2012 Future Workshops. All rights reserved.
//

#import "MVGLModelViewController.h"
#import "MVModel.h"
#import "MVScene.h"
#import "MVCameraController.h"

#import <QuartzCore/QuartzCore.h>


@interface MVGLModelViewController ()<GLKViewControllerDelegate>

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) MVCameraController *cameraController;

@property (nonatomic, strong) MVModel *model;
@property (nonatomic, strong) MVScene *scene;
@property (nonatomic, assign) GLKMatrix4 projection;

@end

@implementation MVGLModelViewController

- (void)loadView {
    [super loadView];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view.opaque = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    self.scene = [[MVScene alloc] init];
    
    self.cameraController = [[MVCameraController alloc] initWithView:self.view];
    [self.cameraController reset];

    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    self.delegate = self;
    [self setupGL];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self setupGL];
}

- (void)dealloc {
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
    self.context = nil;
}

- (void)setupGL {
    [EAGLContext setCurrentContext:self.context];
    
    const GLfloat znear = 0.1f, zfar = 40.0f;
    GLfloat aspect = self.view.bounds.size.width / self.view.bounds.size.height;
    
    self.projection = GLKMatrix4MakePerspective(120, aspect, znear, zfar);
    [self.scene setProjectionMatrix:self.projection];
}

- (void)loadModel:(MVModel *)model {
    [model load:NULL];
    [model setProjectionMatrix:self.projection];
    self.model = model;
    [self.cameraController reset];
    [self glkViewControllerUpdate:self];
    if (!model.thumbnail) {
        UIImage *image = [(GLKView *)self.view snapshot];
        model.thumbnail = UIImagePNGRepresentation(image);
        NSError *error;
        [model.managedObjectContext save:&error];
        NSLog(@"%@", [error localizedDescription]);
    }
}


#pragma mark - GLKViewControllerDelegate

- (void)glkViewControllerUpdate:(GLKViewController *)controller {
    GLKMatrix4 modelview = [self.cameraController getModelview];
    [self.scene setModelviewMatrix:modelview];
    [self.model setModelviewMatrix:modelview];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [self.scene draw];
    [self.model draw];
}




@end
