//
//  MVRootViewController.m
//  3D Model Viewer
//
//  Created by Kamil Kocemba on 16/01/2013.
//  Copyright (c) 2013 Future Workshops. All rights reserved.
//

#import "MVRootViewController.h"
#import "MVGLModelViewController.h"
#import "MVRadialMenuView.h"
#import "MVMenuButton.h"

#import "MVFavouriteMenuViewController.h"
#import "MVBackgroundsMenuViewController.h"

#import "MVModel.h"

#import <QuartzCore/QuartzCore.h>

#define kPopupSize 255.0f


@interface MVRootViewController ()<MVRadialMenuViewDelegate, MVFavouriteModelSelection, MVBackgroundSelection>

@property (nonatomic, strong) UIImageView *backgroundView;
@property (nonatomic, strong) MVMenuButton *menuButton;
@property (nonatomic, strong) MVRadialMenuView *menuView;
@property (nonatomic, strong) UIViewController *selectedMenuViewController;
@property (nonatomic, strong) MVGLModelViewController *modelViewController;

@end

@implementation MVRootViewController

- (void)loadView {
    [super loadView];
    self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default"]];
    [self.view addSubview:self.backgroundView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    MVGLModelViewController *vc = [[MVGLModelViewController alloc] init];
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
    self.modelViewController = vc;
    
    CGSize menuSize = CGSizeMake(255.0f, 255.0f);
    CGRect menuFrame = CGRectMake(0.0f, CGRectGetMaxY(self.view.bounds) - menuSize.height, menuSize.width, menuSize.height);
    MVRadialMenuView *menuView = [[MVRadialMenuView alloc] initWithFrame:menuFrame segments:@[@"Favorites", @"Download", @"Backgrounds", @"Share"]];
    menuView.delegate = self;
    menuView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    self.menuView = menuView;
    [self.view addSubview:self.menuView];
    
    [self.menuView hideAnimated:NO];
    
    const CGSize buttonSize = CGSizeMake(48.0f, 48.0f);
    self.menuButton = [[MVMenuButton alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.view.bounds) - buttonSize.height, buttonSize.width, buttonSize.height)];
    [self.menuButton addTarget:self action:@selector(menuAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.menuButton];
}

- (void)menuAction:(UIButton *)button {
    if (self.selectedMenuViewController) {
        [self.menuView hideAnimated:YES];
    } else {
        [self.view bringSubviewToFront:self.menuView];
        [self.menuView toggleAnimated:YES];
        [self.view bringSubviewToFront:self.menuButton];
    }
}

#pragma mark - Selection Delegate Methods

- (void)favouriteModelSelected:(MVModel *)model {
    [self.modelViewController loadModel:model];
}

- (void)backgroundSelected:(UIImage *)image {
    self.backgroundView.image = image;
}

#pragma mark - MVRadialMenuViewDelegate


- (void)showMenuViewController {
        
    CGSize menuViewSize = CGSizeMake(CGRectGetWidth(self.view.bounds), 269.0f);
    self.selectedMenuViewController.view.frame = CGRectMake(0.0f, CGRectGetMaxY(self.view.bounds) - menuViewSize.height, menuViewSize.width, menuViewSize.height);
    self.selectedMenuViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth| UIViewAutoresizingFlexibleTopMargin;
    [self.view insertSubview:self.selectedMenuViewController.view belowSubview:self.menuView];
            
    self.selectedMenuViewController.view.transform = CGAffineTransformMakeTranslation(-CGRectGetWidth(self.view.bounds), 0.0f);
    [UIView animateWithDuration:0.6f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.selectedMenuViewController.view.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [self.view sendSubviewToBack:self.menuView];
    }];
}

- (void)radialMenuView:(MVRadialMenuView *)radialMenuView didSelectIndex:(MVMenuSegmentIndex)index {
    if (self.selectedMenuViewController) {
        return;
    }
    
    UIViewController *mvc;
    if (index == MVMenuSegmentIndexFavorites) {
        MVFavouriteMenuViewController *vc = [[MVFavouriteMenuViewController alloc] init];
        vc.selectionDelegate = self;
        mvc = vc;
    } else if (index == MVMenuSegmentIndexBackgrounds) {
        MVBackgroundsMenuViewController *vc = [[MVBackgroundsMenuViewController alloc] init];
        vc.selectionDelegate = self;
        mvc = vc;
    }
    
    if (mvc) {
        [self.menuView hideAnimated:YES];
        self.selectedMenuViewController = mvc;
        [self showMenuViewController];
    }
}

- (void)radialMenuViewWillHide:(MVRadialMenuView *)radialMenuView {
    if (self.selectedMenuViewController) {    
        [UIView animateWithDuration:0.6f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.selectedMenuViewController.view.transform = CGAffineTransformMakeTranslation(-CGRectGetWidth(self.view.bounds), 0.0f);
        } completion:^(BOOL successful){
            [self.selectedMenuViewController.view removeFromSuperview];
            self.selectedMenuViewController = nil;
        }];
    }
}


@end
