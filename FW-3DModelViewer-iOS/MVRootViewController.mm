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

#import "MVModel.h"

#define kPopupSize 280.0f


@interface MVRootViewController ()<MVRadialMenuViewDelegate, MVFavouriteModelSelection>

@property (nonatomic, strong) UIImageView *backgroundView;
@property (nonatomic, strong) MVMenuButton *menuButton;
@property (nonatomic, strong) MVRadialMenuView *menuView;
@property (nonatomic, strong) UIViewController *selectedMenuViewController;
@property (nonatomic, strong) MVGLModelViewController *modelViewController;

@end

@implementation MVRootViewController

- (void)loadView {
    [super loadView];
    self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    [self.view addSubview:self.backgroundView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    MVGLModelViewController *vc = [[MVGLModelViewController alloc] init];
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
    self.modelViewController = vc;
    
    const CGSize buttonSize = CGSizeMake(48.0f, 48.0f);
    self.menuButton = [[MVMenuButton alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.view.bounds) - buttonSize.height, buttonSize.width, buttonSize.height)];
    [self.menuButton addTarget:self action:@selector(openMenu:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.menuButton];
    
    CGRect menuFrame = CGRectMake(-kPopupSize / 2.0f, CGRectGetMaxY(self.view.bounds) - kPopupSize * 1.5f, kPopupSize, kPopupSize);
    MVRadialMenuView *menuView = [[MVRadialMenuView alloc] initWithFrame:menuFrame segments:@[@"Favorites", @"Download", @"Background", @"Share"]];
    menuView.delegate = self;
    menuView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    self.menuView = menuView;
    [self.view addSubview:self.menuView];
    
    [self.menuView hideAnimated:NO];

}

- (void)openMenu:(UIButton *)button {
    [self.menuView toggleAnimated:YES];
    [self.view bringSubviewToFront:self.menuButton];
}

- (void)favouriteModelSelected:(MVModel *)model {
    [self.modelViewController loadModel:model];
}

#pragma mark - MVRadialMenuViewDelegate

- (void)radialMenuView:(MVRadialMenuView *)radialMenuView didSelectIndex:(NSInteger)index {
    MVFavouriteMenuViewController *favouriteMenuViewController = [[MVFavouriteMenuViewController alloc] init];
    favouriteMenuViewController.selectionDelegate = self;
    self.selectedMenuViewController = favouriteMenuViewController;
    self.selectedMenuViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth| UIViewAutoresizingFlexibleTopMargin;
    
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.view addSubview:self.selectedMenuViewController.view];
        [self.view bringSubviewToFront:self.menuButton];
        self.selectedMenuViewController.view.frame = CGRectMake(0.0f, CGRectGetMaxY(self.view.bounds) - kPopupSize, CGRectGetWidth(self.view.bounds), kPopupSize);
    } completion:nil];
}

- (void)radialMenuViewWillHide:(MVRadialMenuView *)radialMenuView {
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.selectedMenuViewController.view.frame = CGRectMake(-2.0f *kPopupSize, CGRectGetMaxY(self.view.bounds) - kPopupSize, CGRectGetWidth(self.view.bounds), kPopupSize);
    } completion:^(BOOL successful){
        [self.selectedMenuViewController.view removeFromSuperview];
    }];
}


@end
