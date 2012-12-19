//
//  MVCameraController.m
//  3D Model Viewer
//
//  Created by Kamil Kocemba on 19/12/2012.
//  Copyright (c) 2012 Future Workshops. All rights reserved.
//

#import "MVCameraController.h"

#define kInputAngleCoefficient (( 180.0f / M_PI ) * 0.0001)

@interface MVCameraController ()<UIGestureRecognizerDelegate>

@property (nonatomic, assign) GLKVector3 target, camera;
@property (nonatomic, assign) CGFloat cameraDistance, theta, upsilon;
@property (nonatomic, assign) CGFloat lastPinchScale;
@property (nonatomic, assign) GLKMatrix4 cameraModelview;
@property (nonatomic, assign) CGPoint lastPosition;
@property (nonatomic, weak) UIView *view;

@end

@implementation MVCameraController

- (id)initWithView:(UIView *)view {
    if ((self = [super init])) {
        self.view = view;
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(gesturePanned:)];
        panGesture.delegate = self;
        panGesture.maximumNumberOfTouches = 1;
        [self.view addGestureRecognizer:panGesture];
        
        UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(gesturePinched:)];
        pinchGesture.delegate = self;
        [self.view addGestureRecognizer:pinchGesture];

    }
    return self;
}


- (void)reset {
    self.target = GLKVector3Make(.0f, .0f, .0f);
    self.cameraDistance = sqrtf(2.0f);
    self.theta = self.upsilon = M_PI_4;
    [self updateCamera];
}

- (void)updateCamera {
    GLKVector3 camera = GLKVector3Make(sin(self.upsilon), cos(self.upsilon) * cos(self.theta), cos(self.upsilon) * sin(self.theta));
    self.camera = GLKVector3MultiplyScalar(camera, self.cameraDistance);

    self.cameraModelview = GLKMatrix4MakeLookAt(self.camera.x, self.camera.y, self.camera.z, self.target.x, self.target.y, self.target.z, .0f, 1.0f, .0f);
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

- (void)gesturePanned:(UIPanGestureRecognizer *)panGesture {
    CGPoint currentPointInView = [panGesture translationInView:self.view];
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        self.lastPosition = currentPointInView;
    }
    CGFloat deltaUpsilon = ((self.lastPosition.x - currentPointInView.x) * kInputAngleCoefficient);
    CGFloat deltaTheta = ((self.lastPosition.y - currentPointInView.y) * kInputAngleCoefficient);
    self.theta += deltaTheta;
    self.upsilon += deltaUpsilon;
    [self updateCamera];
    self.lastPosition = currentPointInView;
}

- (void)gesturePinched:(UIPinchGestureRecognizer *)pinchGesture {
    if (pinchGesture.state == UIGestureRecognizerStateBegan) {
        self.lastPinchScale = pinchGesture.scale;
    }
    self.cameraDistance = self.cameraDistance + (self.lastPinchScale - pinchGesture.scale);
    [self updateCamera];
    self.lastPinchScale = pinchGesture.scale;
}


@end
