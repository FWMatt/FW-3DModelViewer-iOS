//
//  MVGLModelViewController.m
//  3D Model Viewer
//
//  Created by Tim Chilvers on 26/11/2012.
//  Copyright (c) 2012 Future Workshops. All rights reserved.
//

#import "MVGLModelViewController.h"
#import "MVGLModelView.h"
#import "GLLight.h"
#import "MVGLModelView.h"
#import "MVRadialMenuView.h"
#import "MVFavouriteMenuViewController.h"
#import "MVModel.h"

#define kPopupSize 192.5f
#define kMenuButtonSize 44.0f

@interface MVGLModelViewController ()

@property (nonatomic,strong) MVGLModelView *modelView;
@property (nonatomic,strong) UIButton *menuButton;
@property (nonatomic,strong) UIView *menuView;
@property (nonatomic,strong) UIViewController *selectedMenuViewController;

@end

@implementation MVGLModelViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.modelView = [[MVGLModelView alloc] initWithFrame:self.view.bounds];
    self.modelView.backgroundColor = [UIColor colorWithRed:57.0f / 255.0f green:57.0f / 255.0f blue:57.0f / 255.0f alpha:1.0f];
    [self.view addSubview:self.modelView];
    self.modelView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
    self.menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.menuButton.frame = CGRectMake(0.0f, CGRectGetMaxY(self.view.bounds) - kMenuButtonSize, kMenuButtonSize, kMenuButtonSize);
    [self.menuButton setBackgroundImage:[UIImage imageNamed:@"menu-btn"] forState:UIControlStateNormal];
    [self.menuButton addTarget:self action:@selector(openMenu:) forControlEvents:UIControlEventTouchUpInside];
    self.menuButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:self.menuButton];
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
        
        NSLog(@"Adding %@ to %@",self.menuView,self.view);
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.modelView startAnimating];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.modelView stopAnimating];
    [super viewWillDisappear:animated];
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
    [self.modelView stopAnimating];
    [model load:NULL];
    [self.modelView setModel:model];
    [self.modelView startAnimating];
}

@end
