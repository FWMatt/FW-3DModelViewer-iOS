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

#import "MVMenuButton.h"

#import <QuartzCore/QuartzCore.h>

#define kPopupSize 280.0f
#define kMenuButtonSize 44.0f


@interface MVGLModelViewController ()<GLKViewControllerDelegate>

@property (nonatomic, strong) UIButton *menuButton;
@property (nonatomic, strong) MVRadialMenuView *menuView;
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
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    self.menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.menuButton.frame = CGRectMake(0.0f, CGRectGetMaxY(self.view.bounds) - kMenuButtonSize, kMenuButtonSize, kMenuButtonSize);
    [self.menuButton setBackgroundImage:[UIImage imageNamed:@"menu-btn"] forState:UIControlStateNormal];
    [self.menuButton addTarget:self action:@selector(openMenu:) forControlEvents:UIControlEventTouchUpInside];
    self.menuButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    
    CGRect menuFrame = CGRectMake(-kPopupSize / 2.0f, CGRectGetMaxY(self.view.bounds) - kPopupSize * 1.5f, kPopupSize, kPopupSize);
    MVRadialMenuView *menuView = [[MVRadialMenuView alloc] initWithFrame:menuFrame segments:@[@"Favorites", @"Download", @"Background", @"Share"]];
    menuView.delegate = self;
    menuView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    self.menuView = menuView;
    [self.view addSubview:self.menuView];
    
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
    [self.menuView hideAnimated:NO];
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

- (void)openMenu:(UIButton *)button {
    [self.menuView toggleAnimated:YES];
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
    GLKMatrix4 modelview = [self.cameraController getModelview];
    [self.scene setModelviewMatrix:modelview];
    [self.model setModelviewMatrix:modelview];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [self.scene draw];
    [self.model draw];
}


@end
