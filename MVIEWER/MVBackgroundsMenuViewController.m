//
//  MVBackgroundsMenuViewController.m
//  MVIEWER
//
//  Created by Kamil Kocemba on 1/22/13.
//  Copyright (c) 2013 Future Workshops. All rights reserved.
//

#import "MVBackgroundsMenuViewController.h"
#import "CollectionViewCell.h"

@interface MVBackgroundsMenuViewController ()

@property (nonatomic, strong) NSArray *backgrounds;

@end

@implementation MVBackgroundsMenuViewController

static NSString * const cellIdentifier = @"MVBackgroundsMenuCell";

- (void)loadView {
    [super loadView];
    
    CGRect frame = self.titleLabel.frame;
    CGSize size = frame.size;
    self.titleLabel.frame = CGRectMake(frame.origin.x, frame.origin.y, size.width + 60.0f, size.height);
    self.titleLabel.text = @"BACKGROUNDS";
    
    [self.collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.backgrounds = @[
        @"Default",
        @"Deep Purple",
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
    CollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    NSString *imageName = self.backgrounds[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:imageName];
    cell.deleteButton.hidden = YES;
    return cell;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *imageName = self.backgrounds[indexPath.row];
    UIImage *image = [UIImage imageNamed:imageName];
    [self.selectionDelegate backgroundSelected:image];
}

@end
