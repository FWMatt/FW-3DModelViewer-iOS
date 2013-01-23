//
//  MVBackgroundsMenuViewController.m
//  MVIEWER
//
//  Created by Kamil Kocemba on 1/22/13.
//  Copyright (c) 2013 Future Workshops. All rights reserved.
//

#import "MVBackgroundsMenuViewController.h"
#import "MVBackgroundMenuCell.h"
#import "MVModel.h"
#import "MVPopoverBackground.h"

@interface MVBackgroundsMenuViewController ()<UIPopoverControllerDelegate>

@property (nonatomic, strong) NSArray *backgrounds;
@property (nonatomic, strong) UIImage *modelThumbnail;
@property (nonatomic, strong) UIPopoverController *popover;
@property (nonatomic, strong) UIButton *cameraButton;

@end

@implementation MVBackgroundsMenuViewController

static NSString * const cellIdentifier = @"MVBackgroundsMenuCell";

@synthesize model = _model;
@synthesize popover = _popover;


- (void)setModel:(MVModel *)model {
    self.modelThumbnail = model.thumbnail;
    self->_model = model;
}

- (UIPopoverController *)popover {
    if (!self->_popover) {
        UIViewController *vc = [[UIViewController alloc] init];
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:vc];
        popover.delegate = self;
        popover.popoverBackgroundViewClass = [MVPopoverBackground class];
        self->_popover = popover;
    }
    return self->_popover;
}

- (void)loadView {
    [super loadView];
    
    CGRect frame = self.titleLabel.frame;
    CGSize size = frame.size;
    self.titleLabel.frame = CGRectMake(frame.origin.x, frame.origin.y, size.width + 60.0f, size.height);
    self.titleLabel.text = @"BACKGROUNDS";

    UIButton *cameraButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetHeight(self.view.bounds) - 140.0f, 26.0f, 128.0f, 43.0f)];
    [cameraButton setImage:[UIImage imageNamed:@"camera-btn"] forState:UIControlStateNormal];
    [cameraButton setImage:[UIImage imageNamed:@"camera-btn-sel"] forState:UIControlStateSelected];


    [cameraButton addTarget:self action:@selector(presentImagePickerPopover:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cameraButton];
    self.cameraButton = cameraButton;
    
    [self.collectionView registerClass:[MVBackgroundMenuCell class] forCellWithReuseIdentifier:cellIdentifier];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.backgrounds = @[
        @"Default",
        @"Stellar Sky",
        @"Skyscraper",
        @"Sea",
        @"Snowy White",
        @"Lemon Yellow",
        @"Orange",
        @"Red",
        @"Sky Blue",
        @"Deep Sea",
        @"Green"
    ];
}

- (void)presentImagePickerPopover:(UIButton *)sender {
//    [self.popover presentPopoverFromRect:sender.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
//    self.cameraButton.selected = YES;
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    self.cameraButton.selected = NO;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return self.backgrounds.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MVBackgroundMenuCell *cell = [cv dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    NSString *backgroundName = self.backgrounds[indexPath.row];
    NSString *imageName = [NSString stringWithFormat:@"%@-thumb", backgroundName];
    cell.backgroundImageView.image = [UIImage imageNamed:imageName];
    cell.imageView.image = self.modelThumbnail;
    cell.titleLabel.text = backgroundName;
    return cell;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *imageName = self.backgrounds[indexPath.row];
    UIImage *image = [UIImage imageNamed:imageName];
    [self.selectionDelegate backgroundSelected:image];
}

@end
