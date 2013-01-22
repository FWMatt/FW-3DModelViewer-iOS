//
//  MVCameraController.m
//  3D Model Viewer
//
//  Created by Kamil Kocemba on 19/12/2012.
//  Copyright (c) 2012 Future Workshops. All rights reserved.
//

#import "MVCameraController.h"
#import "MVAxisViewController.h"

@interface MVCameraController ()<UIGestureRecognizerDelegate>

@property (nonatomic, assign) GLKQuaternion quaternion, slerp;
@property (nonatomic, assign) CGPoint lastPosition;
@property (nonatomic, assign) CGFloat lastScale, scale;
@property (nonatomic, assign) GLKMatrix4 cameraModelview;
@property (nonatomic, weak) UIView *view;

@property (nonatomic, strong) UIView *axisBgView;
@property (nonatomic, strong) MVAxisViewController *axisViewController;
@property (nonatomic, assign) BOOL axesVisible;
@property (nonatomic, strong) NSTimer *axisTimer;

@end

@implementation MVCameraController

- (id)initWithView:(UIView *)view context:(EAGLContext *)context {
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

        
        self.axisBgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"axis-box"]];
        self.axisBgView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self.view addSubview:self.axisBgView];
        CGSize size = self.axisBgView.bounds.size;
        self.axisBgView.frame = CGRectMake(CGRectGetWidth(self.view.bounds) - size.width, 0.0f, size.width, size.height);
        
        self.axisViewController = [[MVAxisViewController alloc] init];
        [(GLKView *)self.axisViewController.view setContext:context];
        self.axisViewController.view.frame = self.axisBgView.bounds;
        [self.axisBgView addSubview:self.axisViewController.view];
        
        self.axisBgView.alpha = 0.0f;
        self.axesVisible = NO;
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
    const CGFloat axisScale = 0.7f;
    const CGFloat axisTranslation = 0.0f;
    self.cameraModelview = GLKMatrix4MakeTranslation(0.0, 0.0f, -3.5f);
    GLKMatrix4 axisMatrix = GLKMatrix4Translate(self.cameraModelview, axisTranslation, 0.15f, 0.0f);
    GLKMatrix4 rotation = GLKMatrix4MakeWithQuaternion(self.quaternion);
    self.cameraModelview = GLKMatrix4Multiply(self.cameraModelview, rotation);
    axisMatrix = GLKMatrix4Multiply(axisMatrix, rotation);
    axisMatrix = GLKMatrix4Scale(axisMatrix, axisScale, axisScale, axisScale);
    [self.axisViewController setCameraModelView:axisMatrix];
    
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

- (void)hideAxes:(NSTimer *)timer {
    [UIView animateWithDuration:1.0f animations:^{
        self.axisBgView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        self.axesVisible = NO;
    }];
}

- (void)showAxes:(id)sender {
    [self.axisTimer invalidate];
    self.axisTimer = nil;
    [UIView animateWithDuration:1.0f animations:^{
        self.axisBgView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        self.axesVisible = YES;
    }];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (self.axesVisible)
            self.axisTimer = [NSTimer scheduledTimerWithTimeInterval:4.0f target:self selector:@selector(hideAxes:) userInfo:nil repeats:NO];
    } else {
        if (!self.axesVisible)
            [self showAxes:nil];
    }
    
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
