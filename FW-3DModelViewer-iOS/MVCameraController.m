//
//  MVCameraController.m
//  3D Model Viewer
//
//  Created by Kamil Kocemba on 19/12/2012.
//  Copyright (c) 2012 Future Workshops. All rights reserved.
//

#import "MVCameraController.h"

@interface MVCameraController ()<UIGestureRecognizerDelegate>

@property (nonatomic, assign) GLKQuaternion quaternion, slerp;
@property (nonatomic, assign) CGPoint lastPosition;
@property (nonatomic, assign) CGFloat lastScale, scale;
@property (nonatomic, assign) GLKMatrix4 cameraModelview;
@property (nonatomic, weak) UIView *view;

@end

@implementation MVCameraController

- (id)initWithView:(UIView *)view {
    if ((self = [super init])) {
        self.view = view;
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        panGesture.delegate = self;
        panGesture.maximumNumberOfTouches = 1;
        [self.view addGestureRecognizer:panGesture];
        
        UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
        pinchGesture.delegate = self;
        [self.view addGestureRecognizer:pinchGesture];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        tapGesture.delegate = self;
        tapGesture.numberOfTapsRequired = 2;
        [self.view addGestureRecognizer:tapGesture];

    }
    return self;
}

- (GLKMatrix4)getModelview {
    [self processAnimation];
    return _cameraModelview;
}


- (void)processAnimation {
    const CGFloat rate = 1.0f / 5.0f;
    self.quaternion = GLKQuaternionSlerp(self.quaternion, self.slerp, rate);
    [self updateCamera];
}

- (void)reset {
    self.quaternion = GLKQuaternionIdentity;
    self.slerp = GLKQuaternionIdentity;
    self.scale = 1.0f;
    [self updateCamera];
}

- (void)updateCamera {
    self.cameraModelview = GLKMatrix4MakeTranslation(0.0, 0.0f, -3.5f);
    self.cameraModelview = GLKMatrix4Multiply(self.cameraModelview, GLKMatrix4MakeWithQuaternion(self.quaternion));
    self.cameraModelview = GLKMatrix4Scale(self.cameraModelview, self.scale, self.scale, self.scale);
}

- (void)rotateMatrixWithDelta:(CGPoint)delta {
    const CGFloat rate = M_PI / 250.0f;
    
    GLKVector3 up = GLKVector3Make(0.0f, 1.0f, 0.0f), right = GLKVector3Make(-1.0f, 0.0f, 0.0f);
    GLKQuaternion inverseQuaternion = GLKQuaternionInvert(self.quaternion);
    
    GLKQuaternion upQ = GLKQuaternionMultiply(inverseQuaternion, GLKQuaternionMultiply(GLKQuaternionMakeWithVector3(up, 1.0f), self.quaternion));
    self.quaternion = GLKQuaternionMultiply(self.quaternion, GLKQuaternionMakeWithAngleAndVector3Axis(delta.x * rate, upQ.v));
    
    inverseQuaternion = GLKQuaternionInvert(self.quaternion);
    GLKQuaternion rightQ = GLKQuaternionMultiply(inverseQuaternion, GLKQuaternionMultiply(GLKQuaternionMakeWithVector3(right, 1.0f), self.quaternion));
    self.quaternion = GLKQuaternionMultiply(self.quaternion, GLKQuaternionMakeWithAngleAndVector3Axis(delta.y * rate, rightQ.v));

    self.slerp = self.quaternion;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    CGPoint position = [recognizer translationInView:self.view];
    if (recognizer.state == UIGestureRecognizerStateBegan)
        self.lastPosition = position;
    
    CGPoint delta = CGPointMake(position.x - self.lastPosition.x, self.lastPosition.y - position.y);
    self.lastPosition = position;
    [self rotateMatrixWithDelta:delta];
}

- (void)handlePinch:(UIPinchGestureRecognizer *)recognizer {
    const CGFloat minScale = 0.125f, maxScale = 2.0f, factor = 0.5f;
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.lastScale = 1.0f;
    }
    CGFloat scale = 1.0f - (self.lastScale - recognizer.scale) * factor;
    self.scale = MIN(MAX(self.scale * scale, minScale), maxScale);
    [self updateCamera];
    self.lastScale = recognizer.scale;
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer {
    self.slerp = GLKQuaternionIdentity;
}


@end
