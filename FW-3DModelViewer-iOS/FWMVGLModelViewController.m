//
//  FWMVGLModelViewController.m
//  FW-3DModelViewer-iOS
//
//  Created by Tim Chilvers on 26/11/2012.
//  Copyright (c) 2012 Future Workshops. All rights reserved.
//

#import "FWMVGLModelViewController.h"
#import "FWMVGLModelView.h"
#import "GLModel.h"
#import "GLLight.h"
#import "GLImage.h"
#import "FWMVGLModelView.h"
#import "FWMVRadialMenuView.h"
#import "FWMVFavouriteMenuViewController.h"

#define kPopupSize 235.0f
#define kMenuButtonSize 44.0f
@interface FWMVGLModelViewController ()

@property (nonatomic,strong) FWMVGLModelView *modelView;
@property (nonatomic,strong) UIButton *menuButton;
@property (nonatomic,strong) UIView *menuView;
@property (nonatomic,strong) UIViewController *selectedMenuViewController;

@end

@implementation FWMVGLModelViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.modelView = [[FWMVGLModelView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.modelView];
    self.modelView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    [self setModel];
    
    self.menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.menuButton.frame = CGRectMake(0.0f, CGRectGetMaxY(self.view.bounds) - kMenuButtonSize, kMenuButtonSize, kMenuButtonSize);
    [self.menuButton setTitle:@"+" forState:UIControlStateNormal];
    self.menuButton.backgroundColor = [UIColor purpleColor];
    [self.menuButton addTarget:self action:@selector(openMenu:) forControlEvents:UIControlEventTouchUpInside];
    self.menuButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:self.menuButton];
}

- (UIView *)menuView {
    if (!self->_menuView) {
        FWMVRadialMenuView *menuView = [[FWMVRadialMenuView alloc] init];
        menuView.delegate = self;
        menuView.numberOfSegments = 4;
        menuView.backgroundColor = [UIColor orangeColor];
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
        self.menuView.frame = CGRectMake(0.0f, CGRectGetMaxY(self.view.bounds) - kPopupSize, kPopupSize, kPopupSize);
        self.menuView.transform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(M_PI / 2.0f),kPopupSize,0.0f);
        NSLog(@"Adding %@ to %@",self.menuView,self.view);
        [self.view addSubview:self.menuView];
        [self.view bringSubviewToFront:self.menuButton];
        [UIView animateWithDuration:0.3f animations:^{
            self.menuButton.transform = CGAffineTransformMakeRotation(-M_PI / 4.0f);
            self.menuView.transform = CGAffineTransformIdentity;
        }];
    } else {
        [UIView animateWithDuration:0.3f animations:^{
            self.menuView.transform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(M_PI / 2.0f),kPopupSize,0.0f);
            self.menuButton.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [self.menuView removeFromSuperview];
        }];
    }
}

- (void)setModel
{
    //set model
    self.modelView.texture = nil;
    self.modelView.blendColor = [UIColor whiteColor];
    self.modelView.model = [GLModel modelWithContentsOfFile:@"translated_desk.obj"];
    
    GLLight *light = [[GLLight alloc] init];
    light.ambientColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:1.0f];
    light.specularColor = [UIColor colorWithRed:0.3f green:1.0f blue:0.3f alpha:1.0f];
    light.diffuseColor = [UIColor colorWithRed:0.2f green:0.5f blue:0.2f alpha:1.0f];
    
    light.transform = CATransform3DMakeTranslation(0.0f, 2.0f, 0.0f);
    
    self.modelView.lights = @[light];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.modelView startAnimating];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.modelView stopAnimating];
    [super viewWillDisappear:animated];
}

- (void)radialMenuView:(FWMVRadialMenuView *)radialMenuView didSelectIndex:(NSInteger)index {
    FWMVFavouriteMenuViewController *favouriteMenuViewController = [[FWMVFavouriteMenuViewController alloc] init];
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

- (void)favouriteModelSelectedWithName:(NSString *)modelName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *modelsPath = [documentsDirectory stringByAppendingPathComponent:@"Models"];
    NSString *selectedModelPath = [modelsPath stringByAppendingPathComponent:modelName];
    [self.modelView setModel:[[GLModel alloc] initWithContentsOfFile:selectedModelPath]];
}
@end
