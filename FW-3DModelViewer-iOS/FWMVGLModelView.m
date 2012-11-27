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

#define LookatLogOn YES
#define kInputAngleCoefficient (( 180.0f / M_PI ) * 0.0001)

@interface FWMVGLModelView ()

@property (nonatomic, assign) CGFloat targetX;
@property (nonatomic, assign) CGFloat targetY;
@property (nonatomic, assign) CGFloat targetZ;

@property (nonatomic, assign) CGFloat cameraX;
@property (nonatomic, assign) CGFloat cameraY;
@property (nonatomic, assign) CGFloat cameraZ;

@property (nonatomic, assign) CGFloat cameraDistance;
@property (nonatomic, assign) CGFloat cameraTheta;
@property (nonatomic, assign) CGFloat cameraUpsilon;

@property (nonatomic, assign) CGFloat lastPanX;
@property (nonatomic, assign) CGFloat lastPanY;
@property (nonatomic, assign) CGFloat lastPinchScale;

@end

@implementation FWMVGLModelView

- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
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
        
        self.cameraDistance = sqrtf(2.0f);
        self.cameraTheta = 0.5 * M_PI / 180.0f;
        self.cameraUpsilon = 0.0f;
        [self updateCameraPosition];
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

- (void)updateCameraPosition {
    self.cameraX = self.cameraDistance * sin(self.cameraUpsilon);
    self.cameraY = self.cameraDistance * cos(self.cameraUpsilon) * cos(self.cameraTheta);
    self.cameraZ = self.cameraDistance * cos(self.cameraUpsilon) * sin(self.cameraTheta);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

static NSNumberFormatter *formatter;

- (NSString *)parseFloat:(float)number {
    if (!formatter) {
        formatter =  [[NSNumberFormatter alloc] init];
        [formatter setUsesSignificantDigits:YES];
        [formatter setMaximumSignificantDigits:7];
        [formatter setMinimumSignificantDigits:7];
        [formatter setPositivePrefix:@"+"];
        [formatter setRoundingMode:NSNumberFormatterRoundHalfDown];
    }
    return [[formatter stringFromNumber:[NSNumber numberWithFloat:number]] substringToIndex:8];
}

- (void)gesturePanned:(UIPanGestureRecognizer *)panGesture {
    CGPoint currentPointInView = [panGesture translationInView:self];
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        self.lastPanX = currentPointInView.x;
        self.lastPanY = currentPointInView.y;
    }
    CGFloat deltaUpsilon = ((self.lastPanX - currentPointInView.x) * kInputAngleCoefficient);
    CGFloat deltaTheta = ((self.lastPanY - currentPointInView.y) * kInputAngleCoefficient);
    self.cameraTheta = self.cameraTheta + deltaTheta;
    self.cameraUpsilon = self.cameraUpsilon + deltaUpsilon;
    [self updateCameraPosition];
    self.lastPanX = currentPointInView.x;
    self.lastPanY = currentPointInView.y;

    NSLog(@"translation %@ %@ leads to delta theta %@ delta upsilon %@",
          [self parseFloat:currentPointInView.x],
          [self parseFloat:currentPointInView.y],
          [self parseFloat:deltaTheta],
          [self parseFloat:deltaUpsilon]);
}

- (void)gesturePinched:(UIPinchGestureRecognizer *)pinchGesture {
    if (pinchGesture.state == UIGestureRecognizerStateBegan) {
        self.lastPinchScale = pinchGesture.scale;
    }
    self.cameraDistance = self.cameraDistance + (self.lastPinchScale - pinchGesture.scale);
    [self updateCameraPosition];
    self.lastPinchScale = pinchGesture.scale;
    NSLog(@"Pinch %@ scale %f velocity %f",pinchGesture,pinchGesture.scale,pinchGesture.velocity);
}

- (void)drawOrigin {
    // save previous matrix
    glPushMatrix();
    // clear matrix
    glLoadIdentity();
    
    glDisable(GL_LIGHTING);
    glDisable(GL_TEXTURE_2D);
    glEnable(GL_BLEND);
    glEnable(GL_DEPTH_TEST);
    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    glDisableClientState(GL_NORMAL_ARRAY);
    glEnableClientState (GL_VERTEX_ARRAY);
    glEnableClientState (GL_COLOR_ARRAY);
    
    GLfloat vertices [18] ={1.0f,0.0f,0.0f,// X axis
        0.0f,0.0f,0.0f,
        0.0f,0.0f,0.0f,
        0.0f,1.0f,0.0f, // Y axis
        0.0f,0.0f,0.0f,
        0.0f,0.0f,1.0f}; // Z axis
    
    glVertexPointer(3, GL_FLOAT, 0, vertices);
    
    GLfloat colors [24] = { 1.0f,0.0f,0.0f,1.0f, // x
        1.0f,0.0f,0.0f,1.0f,
        0.0f,1.0f,0.0f,1.0f, // y
        0.0f,1.0f,0.0f,1.0f,
        0.0f,0.0f,1.0f,1.0f, // z
        0.0f,0.0f,1.0f,1.0f};
    
    glColorPointer(4, GL_FLOAT, 0, colors);
    
    if (LookatLogOn) {
        NSLog(@"Lookat On - %f %f %f",self.cameraX, self.cameraY, self.cameraZ);
    }
    gluLookAt((GLfloat)self.cameraX, (GLfloat)self.cameraY, (GLfloat)self.cameraZ, (GLfloat)self.targetX, (GLfloat)self.targetY, (GLfloat)self.targetZ);

    glDrawArrays(GL_LINES, 0, 6);
    glDisableClientState(GL_COLOR_ARRAY);
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisable(GL_DEPTH_TEST);
    
    glPopMatrix();

}

- (void)drawRect:(CGRect)rect {
    
    [self drawOrigin];

    glLoadIdentity();
    GLfloat projMatrix[16];
    GLfloat modelMatrix[16];
    glGetFloatv(GL_PROJECTION, projMatrix);
    glGetFloatv(GL_MODELVIEW, modelMatrix);
    
    if (LookatLogOn) {
        NSLog(@"Lookat On - %f %f %f",self.cameraX, self.cameraY, self.cameraZ);
    }
    gluLookAt(self.cameraX, self.cameraY, self.cameraZ, self.targetX, self.targetY, self.targetZ);

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
//    NSLog(@"Proj unaltered");
//    [self logArray:projMatrix];
//    NSLog(@"Moder unaltered");
//    [self logArray:modelMatrix];
//    NSLog(@"Proj altered");
//    [self logArray:altProjMatrix];
//    NSLog(@"Moder altered");
//    [self logArray:altModelMatrix];
//    NSLog(@"Proj final");
//    [self logArray:finalProjMatrix];
//    NSLog(@"Moder final");
//    [self logArray:finalModelMatrix];
    
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
