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

#define LookatOn YES

@interface FWMVGLModelView ()

@property (nonatomic, assign) CGFloat targetX;
@property (nonatomic, assign) CGFloat targetY;
@property (nonatomic, assign) CGFloat targetZ;

@property (nonatomic, assign) CGFloat cameraX;
@property (nonatomic, assign) CGFloat cameraY;
@property (nonatomic, assign) CGFloat cameraZ;

@property (nonatomic, assign) CGFloat cameraDistance;

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
        
        self.targetX = 0.0f;
        self.targetY = 0.0f;
        self.targetZ = 0.0f;
        
        self.cameraX = 0.0f;
        self.cameraY = 10.0f;
        self.cameraZ = 0.0f;
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

- (void)drawRect:(CGRect)rect {
    glLoadIdentity();
    GLfloat projMatrix[16];
    GLfloat modelMatrix[16];
    glGetFloatv(GL_PROJECTION, projMatrix);
    glGetFloatv(GL_MODELVIEW, modelMatrix);
    
    if (LookatOn) {
        NSLog(@"Lookat On - %f %f %f",self.cameraX, self.cameraY, self.cameraZ);
        gluLookAt(self.cameraX, self.cameraY, self.cameraZ, self.targetX, self.targetY, self.targetZ);
    }

    GLfloat altProjMatrix[16];
    GLfloat altModelMatrix[16];
    glGetFloatv(GL_PROJECTION, altProjMatrix);
    glGetFloatv(GL_MODELVIEW, altModelMatrix);
    [super drawRect:rect];
    GLfloat finalProjMatrix[16];
    GLfloat finalModelMatrix[16];
    glGetFloatv(GL_PROJECTION, finalProjMatrix);
    glGetFloatv(GL_MODELVIEW, finalModelMatrix);

    for (NSInteger i = 0; i < 16; i++) {
        projMatrix[i] = fabsf(projMatrix[i]);
        modelMatrix[i] = fabsf(modelMatrix[i]);
        altProjMatrix[i] = fabsf(altProjMatrix[i]);
        altModelMatrix[i] = fabsf(altModelMatrix[i]);
        finalProjMatrix[i] = fabsf(finalProjMatrix[i]);
        finalModelMatrix[i] = fabsf(finalModelMatrix[i]);
    }
    NSLog(@"Proj unaltered");
    [self logArray:projMatrix];
    NSLog(@"Moder unaltered");
    [self logArray:modelMatrix];
    NSLog(@"Proj altered");
    [self logArray:altProjMatrix];
    NSLog(@"Moder altered");
    [self logArray:altModelMatrix];
    NSLog(@"Proj final");
    [self logArray:finalProjMatrix];
    NSLog(@"Moder final");
    [self logArray:finalModelMatrix];
    
}

- (void)logArray:(GLfloat *)array {
    printf("\n");
    for (NSInteger i = 0; i < 4; i ++) {
        for (NSInteger j = 0; j < 4; j ++) {
            printf("%f, ",array[i * 4 + j]);
        }
        printf("\n");
    }
}
@end
