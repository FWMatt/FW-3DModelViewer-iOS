//
//  MVGLModelViewController.m
//  3D Model Viewer
//
//  Created by Tim Chilvers on 26/11/2012.
//  Copyright (c) 2012 Future Workshops. All rights reserved.
//

#import "MVGLModelViewController.h"
#import "MVRadialMenuView.h"
#import "MVFavouriteMenuViewController.h"
#import "MVModel.h"
#import "MVScene.h"
#import "MVCameraController.h"

#import <QuartzCore/QuartzCore.h>

#define kPopupSize 192.5f
#define kMenuButtonSize 44.0f


@interface MVGLModelViewController ()<GLKViewControllerDelegate>

@property (nonatomic, strong) UIButton *menuButton;
@property (nonatomic, strong) UIView *menuView;
@property (nonatomic, strong) UIViewController *selectedMenuViewController;
@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) MVCameraController *cameraController;

@property (nonatomic, strong) MVModel *model;
@property (nonatomic, strong) MVScene *scene;
@property (nonatomic, assign) GLKMatrix4 projection;

@end

@implementation MVGLModelViewController

- (void)loadView {
    [super loadView];
    self.menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.menuButton.frame = CGRectMake(0.0f, CGRectGetMaxY(self.view.bounds) - kMenuButtonSize, kMenuButtonSize, kMenuButtonSize);
    [self.menuButton setBackgroundImage:[UIImage imageNamed:@"menu-btn"] forState:UIControlStateNormal];
    [self.menuButton addTarget:self action:@selector(openMenu:) forControlEvents:UIControlEventTouchUpInside];
    self.menuButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:self.menuButton];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    self.scene = [[MVScene alloc] init];
    
    self.cameraController = [[MVCameraController alloc] initWithView:self.view];
    [self.cameraController reset];

    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    self.delegate = self;
    [self setupGL];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self setupGL];
}

- (void)dealloc {
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
    self.context = nil;
}

- (void)setupGL {
    [EAGLContext setCurrentContext:self.context];
    
    const GLfloat znear = 1.0f, zfar = 51.0f;
    GLfloat aspect = self.view.bounds.size.width / self.view.bounds.size.height;
    GLfloat top = tanf(M_PI_2 * 0.5f) * znear;
    self.projection = GLKMatrix4Translate(GLKMatrix4MakeFrustum(aspect * -top, aspect * top, -top, top, znear, zfar), .0f, .0f, -1.0f);
    [self.scene setProjectionMatrix:self.projection];
}

- (UIView *)menuView {
    if (!self->_menuView) {
        MVRadialMenuView *menuView = [[MVRadialMenuView alloc] initWithFrame:CGRectZero];
        menuView.delegate = self;
        menuView.numberOfSegments = 4;
        menuView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
        self->_menuView = menuView;
    }
    return self->_menuView;
}

- (void)openMenu:(UIButton *)button {
    if (self.selectedMenuViewController) {
        [UIView animateWithDuration:0.3f animations:^{
            CGRect menuViewFrame = self.selectedMenuViewController.view.frame;
            menuViewFrame.origin.x = -menuViewFrame.size.width;
            self.selectedMenuViewController.view.frame = menuViewFrame;
        } completion:^(BOOL finished) {
            [self.selectedMenuViewController.view removeFromSuperview];
            self.selectedMenuViewController = nil;
        }];
    } else if (!self.menuView.superview) {
        self.menuView.transform = CGAffineTransformIdentity;
        self.menuView.layer.anchorPoint = CGPointMake(0.0f, 1.0f);
        self.menuView.frame = CGRectMake(0.0f, CGRectGetMaxY(self.view.bounds) - kPopupSize, kPopupSize, kPopupSize);
        
        self.menuView.transform = CGAffineTransformMakeRotation(M_PI_2);
        
        [self.view addSubview:self.menuView];
        [self.view bringSubviewToFront:self.menuButton];
        [UIView animateWithDuration:0.4f animations:^{
            self.menuView.transform = CGAffineTransformIdentity;
        }];
    } else {
        [UIView animateWithDuration:0.4f animations:^{
            self.menuView.transform = CGAffineTransformMakeRotation(M_PI_2);
        } completion:^(BOOL finished) {
            [self.menuView removeFromSuperview];
        }];
    }
}

- (void)radialMenuView:(MVRadialMenuView *)radialMenuView didSelectIndex:(NSInteger)index {
    MVFavouriteMenuViewController *favouriteMenuViewController = [[MVFavouriteMenuViewController alloc] init];
    favouriteMenuViewController.selectionDelegate = self;   
    self.selectedMenuViewController = favouriteMenuViewController;
    self.selectedMenuViewController.view.frame = CGRectMake(-2.0f *kPopupSize, CGRectGetMaxY(self.view.bounds) - kPopupSize, CGRectGetWidth(self.view.bounds), kPopupSize);
    self.selectedMenuViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth| UIViewAutoresizingFlexibleTopMargin;

    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.view addSubview:self.selectedMenuViewController.view];
        [self.view bringSubviewToFront:self.menuButton];
        self.selectedMenuViewController.view.frame = CGRectMake(0.0f, CGRectGetMaxY(self.view.bounds) - kPopupSize, CGRectGetWidth(self.view.bounds), kPopupSize);
    } completion:nil];
}

- (void)favouriteModelSelected:(MVModel *)model {
    [model load:NULL];
    [model setProjectionMatrix:self.projection];
    self.model = model;
    [self.cameraController reset];
}

- (void)glkViewControllerUpdate:(GLKViewController *)controller {
    GLKMatrix4 modelview = self.cameraController.cameraModelview;
    [self.scene setModelviewMatrix:modelview];
    [self.model setModelviewMatrix:modelview];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [self.scene draw];
    [self.model draw];
}


@end
