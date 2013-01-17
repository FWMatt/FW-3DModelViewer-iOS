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

#define kPopupSize 255.0f


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
    [self.menuButton addTarget:self action:@selector(menuAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.menuButton];
    
    CGSize menuSize = CGSizeMake(255.0f, 255.0f);
    CGRect menuFrame = CGRectMake(menuSize.width / 2.0f, CGRectGetMaxY(self.view.bounds) - 0.5f * menuSize.height, menuSize.width, menuSize.height);
    MVRadialMenuView *menuView = [[MVRadialMenuView alloc] initWithFrame:menuFrame segments:@[@"Favorites", @"Download", @"Background", @"Share"]];
    menuView.delegate = self;
    menuView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    self.menuView = menuView;
    [self.view addSubview:self.menuView];
    
    [self.menuView hideAnimated:NO];

}

- (void)menuAction:(UIButton *)button {
    if (self.selectedMenuViewController) {
        [self.menuView hideAnimated:YES];
    } else {
        [self.menuView toggleAnimated:YES];
        [self.view bringSubviewToFront:self.menuButton];
    }
}

- (void)favouriteModelSelected:(MVModel *)model {
    [self.modelViewController loadModel:model];
}

#pragma mark - MVRadialMenuViewDelegate

- (void)radialMenuView:(MVRadialMenuView *)radialMenuView didSelectIndex:(MVMenuSegmentIndex)index {
    
    if (index == MVMenuSegmentIndexFavorites) {
        
        if (!self.selectedMenuViewController) {
        
            CGSize menuViewSize = CGSizeMake(CGRectGetWidth(self.view.bounds), 269.0f);
            MVFavouriteMenuViewController *favouriteMenuViewController = [[MVFavouriteMenuViewController alloc] init];
            favouriteMenuViewController.selectionDelegate = self;
            favouriteMenuViewController.view.frame = CGRectMake(0.0f, CGRectGetMaxY(self.view.bounds) - menuViewSize.height, menuViewSize.width, menuViewSize.height);
            
            
            [self.menuView hideAnimated:YES];
            
            self.selectedMenuViewController = favouriteMenuViewController;
            self.selectedMenuViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth| UIViewAutoresizingFlexibleTopMargin;
            [self.view addSubview:self.selectedMenuViewController.view];
            [self.view bringSubviewToFront:self.menuButton];
            
            
            self.selectedMenuViewController.view.transform = CGAffineTransformMakeTranslation(CGRectGetWidth(self.view.bounds), 0.0f);
            [UIView animateWithDuration:0.4f animations:^{
                self.selectedMenuViewController.view.transform = CGAffineTransformIdentity;
            }];
        }
    }
}

- (void)radialMenuViewWillHide:(MVRadialMenuView *)radialMenuView {
    if (self.selectedMenuViewController) {    
        [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.selectedMenuViewController.view.transform = CGAffineTransformMakeTranslation(CGRectGetWidth(self.view.bounds), 0.0f);
        } completion:^(BOOL successful){
            [self.selectedMenuViewController.view removeFromSuperview];
            self.selectedMenuViewController = nil;
        }];
    }
}


@end
