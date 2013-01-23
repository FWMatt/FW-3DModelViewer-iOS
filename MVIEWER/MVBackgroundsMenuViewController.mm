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

@interface MVBackgroundsMenuViewController ()

@property (nonatomic, strong) NSArray *backgrounds;
@property (nonatomic, strong) UIImage *modelThumbnail;

@end

@implementation MVBackgroundsMenuViewController

static NSString * const cellIdentifier = @"MVBackgroundsMenuCell";

@synthesize model = _model;


- (void)setModel:(MVModel *)model {
    self.modelThumbnail = model.thumbnail;
    self->_model = model;
}

- (void)loadView {
    [super loadView];
    
    CGRect frame = self.titleLabel.frame;
    CGSize size = frame.size;
    self.titleLabel.frame = CGRectMake(frame.origin.x, frame.origin.y, size.width + 60.0f, size.height);
    self.titleLabel.text = @"BACKGROUNDS";
    
    [self.collectionView registerClass:[MVBackgroundMenuCell class] forCellWithReuseIdentifier:cellIdentifier];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.backgrounds = @[
        @"Default",
        @"Stellar Sky",
        @"Deep Sea",
        @"Green",
        @"Lemon Yellow",
        @"Orange",
        @"Red",
        @"Sea",
        @"Sky Blue",
        @"Skyscraper",
        @"Snowy White"
    ];
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
