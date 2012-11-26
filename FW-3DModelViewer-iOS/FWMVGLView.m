//
//  FWMVGLView.m
//  
//
//  Created by Tim Chilvers on 26/11/2012.
//
//

#import "FWMVGLView.h"
#import "GLUtils.h"

#import <QuartzCore/QuartzCore.h>

@interface FWMVGLLayer : CAEAGLLayer

@end


@interface FWMVGLView ()

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, assign) CGSize previousSize;
@property (nonatomic, assign) GLint framebufferWidth;
@property (nonatomic, assign) GLint framebufferHeight;
@property (nonatomic, assign) GLuint defaultFramebuffer;
@property (nonatomic, assign) GLuint colorRenderbuffer;
@property (nonatomic, assign) GLuint depthRenderbuffer;
@property (nonatomic, assign) NSTimeInterval lastTime;
@property (nonatomic, assign, getter = isAnimating) BOOL animating;
@property (nonatomic, unsafe_unretained) NSTimer *timer;

@end


@implementation FWMVGLLayer

- (void)display
{
    //get view
    FWMVGLView *view = (FWMVGLView *)self.delegate;
    
    //bind context and frame buffer
    [view bindFramebuffer];
    
    //clear view
    [view.backgroundColor ?: [UIColor clearColor] bindGLClearColor];
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    //do drawing
    [view drawRect:view.bounds];
    
    //present
    [view presentRenderbuffer];
}

- (void)renderInContext:(CGContextRef)ctx
{
    //get view
    FWMVGLView *view = (FWMVGLView *)self.delegate;
    
    //bind context and frame buffer
    [view bindFramebuffer];
    
    //clear view
    [view.backgroundColor ?: [UIColor clearColor] bindGLClearColor];
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    //do drawing
    [view drawRect:view.bounds];
    
    //read pixel data from the framebuffer
    NSInteger width = view.framebufferWidth;
    NSInteger height = view.framebufferHeight;
    NSInteger dataLength = width * height * 4;
    GLubyte *data = (GLubyte *)malloc(dataLength * sizeof(GLubyte));
    glPixelStorei(GL_PACK_ALIGNMENT, 4);
    glReadPixels(0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, data);
    
    //create CGImage with the pixel data
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, data, dataLength, NULL);
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGImageRef image = CGImageCreate(width, height, 8, 32, width * 4, colorspace, kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast, dataProvider, NULL, true, kCGRenderingIntentDefault);
    
    //render image in current context
    CGContextDrawImage(ctx, CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height), image);
    
    //render sublayers
    for (CALayer *layer in self.sublayers)
    {
        CGContextSaveGState(ctx);
        CGContextTranslateCTM(ctx, layer.frame.origin.x, layer.frame.origin.y);
        [layer renderInContext:ctx];
        CGContextRestoreGState(ctx);
    }
    
    //clean up
    free(data);
    CFRelease(dataProvider);
    CFRelease(colorspace);
    CGImageRelease(image);
}

@end


@implementation FWMVGLView

@synthesize context = _context;
@synthesize previousSize = _previousSize;
@synthesize framebufferWidth = _framebufferWidth;
@synthesize framebufferHeight = _framebufferHeight;
@synthesize defaultFramebuffer = _defaultFramebuffer;
@synthesize colorRenderbuffer = _colorRenderbuffer;
@synthesize depthRenderbuffer = _depthRenderbuffer;
@synthesize lastTime = _lastTime;
@synthesize animating = _animating;
@synthesize frameInterval = _frameInterval;
@synthesize elapsedTime = _elapsedTime;
@synthesize timer = _timer;
@synthesize fov = _fov;
@synthesize near = _near;
@synthesize far = _far;

- (void)dealloc
{
    [self deleteFramebuffer];
    if ([EAGLContext currentContext] == _context)
    {
        [EAGLContext setCurrentContext:nil];
    }
    [_context release];
    [super ah_dealloc];
}

+ (EAGLContext *)sharedContext
{
    //this is used to allow texture sharing, and initialisation
    //of GLImages when no GLView has been created yet
    static EAGLContext *sharedContext = nil;
    if (sharedContext == nil)
    {
        sharedContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    }
    return sharedContext;
}

+ (Class)layerClass
{
    return [FWMVGLLayer class];
}

- (void)setUp
{
    //set up layer
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    eaglLayer.contentsScale = [UIScreen mainScreen].scale;
    eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking,
                                    kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
    
    //create context
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1
                                     sharegroup:[[self class] sharedContext].sharegroup];
    
    //create framebuffer
    _framebufferWidth = 0.0f;
    _framebufferHeight = 0.0f;
    _previousSize = CGSizeZero;
    [self createFramebuffer];
	
	//defaults
	_fov = 0.0f; //orthographic
    _frameInterval = 1.0/60.0; // 60 fps
}

- (id)initWithCoder:(NSCoder*)coder
{
	if ((self = [super initWithCoder:coder]))
    {
        [self setUp];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
    {
        [self setUp];
    }
    return self;
}

- (void)setFov:(CGFloat)fov
{
	_fov = fov;
	[self setNeedsDisplay];
}

- (void)setNear:(CGFloat)near
{
	_near = near;
	[self setNeedsDisplay];
}

- (void)setFar:(CGFloat)far
{
	_far = far;
	[self setNeedsDisplay];
}

- (void)setFrameInterval:(NSTimeInterval)frameInterval
{
    if (_frameInterval != frameInterval)
    {
        _frameInterval = frameInterval;
        if (self.animating)
        {
            [self.timer invalidate];
            [self startTimer];
        }
    }
}

- (void)layoutSubviews
{
    CGSize size = self.bounds.size;
    if (!CGSizeEqualToSize(size, self.previousSize))
    {
        //rebuild framebuffer
        [self deleteFramebuffer];
        [self createFramebuffer];
        
        //update size
        self.previousSize = size;
    }
}

- (void)createFramebuffer
{
    [EAGLContext setCurrentContext:self.context];
    
    //create default framebuffer object
    glGenFramebuffers(1, &_defaultFramebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, self.defaultFramebuffer);
    
    //set up color render buffer
    glGenRenderbuffers(1, &_colorRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, self.colorRenderbuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.colorRenderbuffer);
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_framebufferWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_framebufferHeight);
    
    //set up depth buffer
    glGenRenderbuffers(1, &_depthRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, self.depthRenderbuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, self.framebufferWidth, self.framebufferHeight);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, self.depthRenderbuffer);
    
    //check success
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
    {
        NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
    }
}

- (void)deleteFramebuffer
{
    [EAGLContext setCurrentContext:self.context];
    
    if (_defaultFramebuffer)
    {
        glDeleteFramebuffers(1, &_defaultFramebuffer);
        self.defaultFramebuffer = 0;
    }
    
    if (_colorRenderbuffer)
    {
        glDeleteRenderbuffers(1, &_colorRenderbuffer);
        self.colorRenderbuffer = 0;
    }
    
    if (_depthRenderbuffer)
    {
        glDeleteRenderbuffers(1, &_depthRenderbuffer);
        self.depthRenderbuffer = 0;
    }
}

- (void)bindFramebuffer
{
    [EAGLContext setCurrentContext:self.context];
    
    glBindFramebuffer(GL_FRAMEBUFFER, self.defaultFramebuffer);
	glViewport(0, 0, _framebufferWidth, self.framebufferHeight);
	
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
	if (self.fov <= 0.0f)
	{
		GLfloat near = self.near ?: (-self.framebufferWidth * 0.5f);
		GLfloat far = self.far ?: (self.framebufferWidth * 0.5f);
    	glOrthof(0, self.bounds.size.width, self.bounds.size.height, 0.0f, near, far);
	}
	else
	{
		GLfloat near = (self.near > 0.0f)? self.near: 1.0f;
		GLfloat far = (self.far > self.near)? self.far: (near + 50.0f);
		GLfloat aspect = self.bounds.size.width / self.bounds.size.height;
		GLfloat top = tanf(self.fov * 0.5f) * near;
		glFrustumf(aspect * -top, aspect * top, -top, top, near, far);
		glTranslatef(0.0f, 0.0f, -near);
	}
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
}

- (BOOL)presentRenderbuffer
{
    [EAGLContext setCurrentContext:self.context];
    
    glBindRenderbuffer(GL_RENDERBUFFER, self.colorRenderbuffer);
    return [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)display
{
    [self.layer display];
}

- (void)drawRect:(CGRect)rect
{
    //override this
}

- (void)didMoveToSuperview
{
	[super didMoveToSuperview];
	if (!self.superview)
	{
        //pause
		[self.timer invalidate];
        self.timer = nil;
	}
    else if (!self.timer && self.animating)
    {
        //resume
        [self startTimer];
        [self step];
    }
}


#pragma mark Animation

- (void)startTimer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.frameInterval
                                                  target:self
                                                selector:@selector(step)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)startAnimating
{
    self.animating = YES;
	self.lastTime = CACurrentMediaTime();
	self.elapsedTime = 0.0;
	if (!self.timer)
	{
		[self startTimer];
	}
}

- (void)stopAnimating
{
	[self.timer invalidate];
	self.timer = nil;
    self.animating = NO;
}

- (void)step
{
	//update time
	NSTimeInterval currentTime = CACurrentMediaTime();
	NSTimeInterval deltaTime = currentTime - self.lastTime;
	self.elapsedTime += deltaTime;
	self.lastTime = currentTime;
    
    //step animation
    [self step:deltaTime];
    
    //update view
    [self setNeedsDisplay];
}

- (void)step:(NSTimeInterval)dt
{
	//override this
}


#pragma mark Screen capture

- (UIImage *)snapshot
{
    //create image context
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, self.layer.contentsScale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //render the image
    [self.layer renderInContext:context];
    
    //retrieve the image from the current context
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
