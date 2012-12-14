//
//  MVGLModelView.m
//  3D Model Viewer
//
//  Created by Tim Chilvers on 22/11/2012.
//  Copyright (c) 2012 Future Workshops. All rights reserved.
//

#import "MVGLModelView.h"
#import "MVModel.h"
#import "GLLight.h"

#define LookatLogOn NO
#define kInputAngleCoefficient (( 180.0f / M_PI ) * 0.0001)

@interface MVGLModelView ()

@property (nonatomic, assign) CGFloat targetX, targetY, targetZ;
@property (nonatomic, assign) CGFloat cameraX, cameraY, cameraZ;
@property (nonatomic, assign) CGFloat cameraDistance, cameraTheta, cameraUpsilon;
@property (nonatomic, assign) CGFloat lastPanX, lastPanY, lastPinchScale;

@end


@implementation MVGLModelView

static NSNumberFormatter *formatter;

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
        
        [self resetCamera];
    }
    return self;
}

- (void)setUp {
	[super setUp];
    
	self.fov = M_PI_2;
    
    GLLight *light = [[GLLight alloc] init];
    light.ambientColor = [UIColor colorWithRed:32.0f / 255.0f green: 32.0f / 255.0f blue: 32.0f / 255.0f alpha:1.0f];
    light.diffuseColor = [UIColor colorWithRed:204 / 255.0f green: 204.0f / 255.0f blue: 204.0f / 255.0f alpha:1.0f];
    light.specularColor = [UIColor whiteColor];
    light.transform = CATransform3DMakeTranslation(0.0f, 2.0f, 2.0f);
    self.light = light;
        
    glEnable(GL_NORMALIZE);
    [self.light bind:GL_LIGHT0];
    glShadeModel(GL_SMOOTH_POINT_SIZE_RANGE);
}


- (void)setModel:(MVModel *)model {
    if (self->_model != model) {
        self->_model = model;
        [self resetCamera];
        [self setNeedsDisplay];
    }
}

- (void)setLight:(GLLight *)light {
    if (self->_light != light) {
        self->_light = light;
        [self setNeedsDisplay];
    }
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

- (void)resetCamera {
    self.targetX = self.targetY = self.targetZ = 0.0f;
    self.cameraDistance = sqrtf(2.0f);
    self.cameraTheta = M_PI * 0.25;
    self.cameraUpsilon = M_PI * 0.25;
    [self updateCameraPosition];

}

- (void)updateCameraPosition {
    self.cameraX = self.cameraDistance * sin(self.cameraUpsilon);
    self.cameraY = self.cameraDistance * cos(self.cameraUpsilon) * cos(self.cameraTheta);
    self.cameraZ = self.cameraDistance * cos(self.cameraUpsilon) * sin(self.cameraTheta);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}


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
}

- (void)gesturePinched:(UIPinchGestureRecognizer *)pinchGesture {
    if (pinchGesture.state == UIGestureRecognizerStateBegan) {
        self.lastPinchScale = pinchGesture.scale;
    }
    self.cameraDistance = self.cameraDistance + (self.lastPinchScale - pinchGesture.scale);
    [self updateCameraPosition];
    self.lastPinchScale = pinchGesture.scale;
}

- (void)drawOrigin {
    glPushMatrix();
    glLoadIdentity();
    
    glDisable(GL_LIGHTING);
    glDisable(GL_TEXTURE_2D);
    
    glEnable(GL_DEPTH_TEST);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);

    GLfloat vertices [18] = {
        1.0f,0.0f,0.0f,// X axis
        0.0f,0.0f,0.0f,
        0.0f,0.0f,0.0f,
        0.0f,1.0f,0.0f, // Y axis
        0.0f,0.0f,0.0f,
        0.0f,0.0f,1.0f}; // Z axis
    glVertexPointer(3, GL_FLOAT, 0, vertices);
    
    GLfloat colors [24] = {
        1.0f,0.0f,0.0f,1.0f, // x
        1.0f,0.0f,0.0f,1.0f,
        0.0f,1.0f,0.0f,1.0f, // y
        0.0f,1.0f,0.0f,1.0f,
        0.0f,0.0f,1.0f,1.0f, // z
        0.0f,0.0f,1.0f,1.0f};
    glColorPointer(4, GL_FLOAT, 0, colors);
        
    gluLookAt((GLfloat)self.cameraX, (GLfloat)self.cameraY, (GLfloat)self.cameraZ, (GLfloat)self.targetX, (GLfloat)self.targetY, (GLfloat)self.targetZ);

    glDrawArrays(GL_LINES, 0, 6);
    glDisableClientState(GL_COLOR_ARRAY);
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisable(GL_DEPTH_TEST);
    
    glEnable(GL_LIGHTING);
    glEnable(GL_TEXTURE_2D);
    
    glPopMatrix();
}

- (void)drawRect:(CGRect)rect {
    glLoadIdentity();
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    [self drawOrigin];
    gluLookAt(self.cameraX, self.cameraY, self.cameraZ, self.targetX, self.targetY, self.targetZ);

    CATransform3D transform = self.model.normalisingTransform;
    glMultMatrixf((GLfloat *)&transform);
    [self.model draw];
}

@end
