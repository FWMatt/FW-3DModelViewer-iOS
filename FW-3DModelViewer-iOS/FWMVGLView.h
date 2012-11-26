//
//  FWMVGLView.h
//  
//
//  Created by Tim Chilvers on 26/11/2012.
//
//

#import <GLKit/GLKit.h>

@interface FWMVGLView : GLKView

@property (nonatomic, assign) CGFloat fov;
@property (nonatomic, assign) CGFloat near;
@property (nonatomic, assign) CGFloat far;

- (void)setUp;
- (void)display;
- (void)bindFramebuffer;
- (BOOL)presentRenderbuffer;

@property (nonatomic, assign) NSTimeInterval frameInterval;
@property (nonatomic, assign) NSTimeInterval elapsedTime;

- (void)startAnimating;
- (void)stopAnimating;
- (BOOL)isAnimating;
- (void)step:(NSTimeInterval)dt;

- (UIImage *)snapshot;

@end
