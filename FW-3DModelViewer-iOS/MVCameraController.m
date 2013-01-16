//
//  MVCameraController.m
//  3D Model Viewer
//
//  Created by Kamil Kocemba on 19/12/2012.
//  Copyright (c) 2012 Future Workshops. All rights reserved.
//

#import "MVCameraController.h"

@interface MVCameraController ()<UIGestureRecognizerDelegate>

@property (nonatomic, assign) GLKQuaternion quaternion;
@property (nonatomic, assign) GLKVector3 lastPosition;
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
        panGesture.maximumNumberOfTouches = 2;
        [self.view addGestureRecognizer:panGesture];
        
        UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
        pinchGesture.delegate = self;
        [self.view addGestureRecognizer:pinchGesture];

    }
    return self;
}

- (void)reset {
    self.quaternion = GLKQuaternionIdentity;
    self.scale = 1.0f;
    [self updateCamera];
}

- (void)updateCamera {
    self.cameraModelview = GLKMatrix4MakeLookAt(0.75f, 0.75f, 0.75f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f);
    self.cameraModelview = GLKMatrix4Multiply(self.cameraModelview, GLKMatrix4MakeWithQuaternion(self.quaternion));
    self.cameraModelview = GLKMatrix4Scale(self.cameraModelview, self.scale, self.scale, self.scale);
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    CGPoint location = [recognizer translationInView:self.view];
    GLKVector3 position;
    if (recognizer.state == UIGestureRecognizerStateCancelled || recognizer.state == UIGestureRecognizerStateEnded)
        return;
    if (recognizer.numberOfTouches == 2)
        position = GLKVector3Make(self.lastPosition.x, self.lastPosition.y, location.y);
    else
        position = GLKVector3Make(location.x, location.y, self.lastPosition.z);
    if (recognizer.state == UIGestureRecognizerStateBegan)
        self.lastPosition = position;

    [self rotateMatrixWithVector:GLKVector3Subtract(position, self.lastPosition)];
    self.lastPosition = position;
}

- (void)handlePinch:(UIPinchGestureRecognizer *)recognizer {
    const CGFloat minScale = 0.25f, maxScale = 2.0f, factor = 0.3f;
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.lastScale = 1.0f;
    }
    CGFloat scale = 1.0f - (self.lastScale - recognizer.scale) * factor;
    self.scale = MIN(MAX(self.scale * scale, minScale), maxScale);
    [self updateCamera];
    self.lastScale = recognizer.scale;
}

- (void)rotateMatrixWithVector:(GLKVector3)delta {
    const CGFloat rate = M_PI / 250.0f;
	GLKVector3 up = GLKQuaternionRotateVector3(GLKQuaternionInvert(self.quaternion), GLKVector3Make(0.0f, 1.0f, 0.0f));
	self.quaternion = GLKQuaternionMultiply(GLKQuaternionMakeWithAngleAndVector3Axis(delta.x * rate, up), self.quaternion);
    GLKVector3 right = GLKQuaternionRotateVector3(GLKQuaternionInvert(self.quaternion), GLKVector3Make(1.0f, 0.0f, 0.0f));
	self.quaternion = GLKQuaternionMultiply(GLKQuaternionMakeWithAngleAndVector3Axis(delta.y * rate, right), self.quaternion);
    GLKVector3 front = GLKQuaternionRotateVector3(GLKQuaternionInvert(self.quaternion), GLKVector3Make(0.0f, 0.0f, -1.0f));
    self.quaternion = GLKQuaternionMultiply(GLKQuaternionMakeWithAngleAndVector3Axis(delta.z * rate, front), self.quaternion);
    [self updateCamera];

}




@end
