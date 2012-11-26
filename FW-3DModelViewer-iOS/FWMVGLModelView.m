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

- (void)setUp
{
	[super setUp];
    
	self.fov = M_PI_2;
    
    GLLight *light = [[GLLight alloc] init];
    light.transform = CATransform3DMakeTranslation(-0.5f, 1.0f, 0.5f);
    self.lights = [NSArray arrayWithObject:light];
    [light release];
}

- (void)setLights:(NSArray *)lights
{
    if (_lights != lights)
    {
        [_lights release];
        _lights = [lights ah_retain];
        [self setNeedsDisplay];
    }
}

- (void)setModel:(GLModel *)model
{
    if (_model != model)
    {
        [_model release];
        _model = [model ah_retain];
        [self setNeedsDisplay];
    }
}

- (void)setBlendColor:(UIColor *)blendColor
{
    if (_blendColor != blendColor)
    {
        [_blendColor release];
        _blendColor = [blendColor ah_retain];
        [self setNeedsDisplay];
    }
}

- (void)setTexture:(GLImage *)texture
{
    if (_texture != texture)
    {
        [_texture release];
        _texture = [texture ah_retain];
        [self setNeedsDisplay];
    }
}

- (void)setTransform:(CATransform3D)transform
{
    _transform = transform;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    //apply lights
    if ([self.lights count])
    {
        //normalize normals
        glEnable(GL_NORMALIZE);
        
        for (int i = 0; i < GL_MAX_LIGHTS; i++)
        {
            if (i < [self.lights count])
            {
                [[self.lights objectAtIndex:i] bind:GL_LIGHT0 + i];
            }
            else
            {
                glDisable(GL_LIGHT0 + i);
            }
        }
    }
    else
    {
        glDisable(GL_LIGHTING);
    }
    
    //apply transform
    glLoadMatrixf((GLfloat *)&_transform);
    
    //set texture
    [self.blendColor ?: [UIColor whiteColor] bindGLColor];
    if (self.texture)
    {
        [self.texture bindTexture];
    }
    else
    {
        glDisable(GL_TEXTURE_2D);
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    }
    
    //render the model
    [self.model draw];
}

@end
