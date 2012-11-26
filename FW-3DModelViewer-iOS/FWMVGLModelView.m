//
//  FWMVGLView.m
//  FW-3DModelViewer-iOS
//
//  Created by Tim Chilvers on 22/11/2012.
//  Copyright (c) 2012 Future Workshops. All rights reserved.
//

#import "FWMVGLModelView.h"
#import "GLModel.h"
#import "GLImage.h"
#import "GLLight.h"

@interface FWMVGLModelView ()

@property (nonatomic, assign) CGFloat targetX;
@property (nonatomic, assign) CGFloat targetY;
@property (nonatomic, assign) CGFloat targetZ;

@property (nonatomic, assign) CGFloat cameraX;
@property (nonatomic, assign) CGFloat cameraY;
@property (nonatomic, assign) CGFloat cameraZ;

@end

@implementation FWMVGLModelView

- (id) init {
    self = [super init];
    if (self != nil) {
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(gesturePanned:)];
        panGesture.delegate = self;
        panGesture.maximumNumberOfTouches = 1;
        [self addGestureRecognizer:panGesture];
        
        UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(gesturePinched:)];
        pinchGesture.delegate = self;
        [self addGestureRecognizer:pinchGesture];
    }
    return self;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer *)gestureRecognizer;
        if (panGesture.numberOfTouches >= 1) {
            return NO;
        }
    } else if ([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
        UIPinchGestureRecognizer *pinchGesture = (UIPinchGestureRecognizer *)gestureRecognizer;
        if (pinchGesture.numberOfTouches == 2) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

- (void)gesturePanned:(UIPanGestureRecognizer *)panGesture {
    NSLog(@"Pan %@ velocity %@",panGesture, NSStringFromCGPoint([panGesture velocityInView:self]));
}

- (void)gesturePinched:(UIPinchGestureRecognizer *)pinchGesture {
    NSLog(@"Pinch %@ scale %f velocity %f",pinchGesture,pinchGesture.scale,pinchGesture.velocity);
}

@end
