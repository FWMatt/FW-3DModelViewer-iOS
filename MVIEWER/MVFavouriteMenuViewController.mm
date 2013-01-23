//
//  MVFavouriteMenuViewController.m
//  3D Model Viewer
//
//  Created by Tim Chilvers on 28/11/2012.
//  Copyright (c) 2012 Future Workshops. All rights reserved.
//

#import "MVFavouriteMenuViewController.h"
#import "CollectionViewCell.h"
#import "MVModel.h"
#import "MVAppDelegate.h"
#import <QuartzCore/QuartzCore.h>


@interface MVFavouriteMenuViewController ()<NSFetchedResultsControllerDelegate>

@property (nonatomic, assign) BOOL editing;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end


@implementation MVFavouriteMenuViewController

static NSString * const cellIdentifier = @"MVFavoriteCell";

- (id)init {
    if (self = [super init]) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"MVModel"];
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES]];
        RKManagedObjectStore *store = [(MVAppDelegate *)[UIApplication sharedApplication].delegate store];
        self.context = store.managedObjectContextForCurrentThread;
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.context sectionNameKeyPath:nil cacheName:nil];
        self.fetchedResultsController.delegate = self;
    }
    return self;
}

- (void)loadView {
    [super loadView];

    [self.collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];

    UIFont *buttonFont = [UIFont fontWithName:@"Avenir-Light" size:20.0f];
    UIColor *lightGrayColor = [UIColor colorWithRed:222.0f / 255.0f green:222.0f / 255.0f blue:222.0f / 255.0f alpha:1.0f];
    
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    editButton.titleLabel.font =  buttonFont;
    UIImage *buttonImage = [[UIImage imageNamed:@"edit-btn-bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(6.0f, 5.0f, 6.0f, 5.0f)];
    [editButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    UIImage *buttonImageSelected = [[UIImage imageNamed:@"done-btn-bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(6.0f, 38.0f, 6.0f, 39.0f)];
    [editButton setBackgroundImage:buttonImageSelected forState:UIControlStateSelected];
    [editButton setTitle:@"edit" forState:UIControlStateNormal];
    [editButton setTitle:@"done" forState:UIControlStateSelected];
    [editButton setTitleColor:lightGrayColor forState:UIControlStateNormal];
    [editButton setTitleColor:[UIColor colorWithRed:246.0f / 255.0f green:139.0f / 255.0f blue:26.0f / 255.0f alpha:1.0f] forState:UIControlStateSelected];
    [editButton addTarget:self action:@selector(editButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    editButton.frame = CGRectMake(CGRectGetHeight(self.view.bounds) - 140.0f, 26.0f, 120.0f, 43.0f);
    [self.view addSubview:editButton];

    self.titleLabel.text = @"FAVORITES";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.fetchedResultsController performFetch:NULL];
}

- (void)editButtonTapped:(UIButton *)editButton {
    editButton.selected = !editButton.selected;
    self.editing = editButton.selected;
    self.collectionView.allowsReordering = self.editing;
    [self.collectionView reloadData];
}

- (UIColor *)colorForIndex:(NSInteger)index {
    const CGFloat saturation = .7f, brightness = .65f;
    NSInteger count = [self collectionView:self.collectionView numberOfItemsInSection:0];
    return [UIColor colorWithHue:(CGFloat)index / (CGFloat)count saturation:saturation brightness:brightness alpha:1.0f];
}

#pragma mark - UICollectionViewDataSource

- (void)collectionView:(UICollectionView *)collectionView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    for (NSInteger i = sourceIndexPath.row + 1; i <= destinationIndexPath.row; ++i) {
        MVModel *model = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        --model.index;
    }
    MVModel *model = [self.fetchedResultsController objectAtIndexPath:sourceIndexPath];
    model.index = destinationIndexPath.row;
    [self.context save:NULL];
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    return [sectionInfo numberOfObjects];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    MVModel *model = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.imageView.image = model.thumbnail;
    cell.deleteButton.hidden = !self.editing;
    if (self.editing) {
        CABasicAnimation* anim = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        CGFloat angle = M_PI / 48.0f;
        anim.toValue = @(angle);
        anim.fromValue = @(-angle);
        anim.duration = 0.15f;
        anim.timeOffset = anim.duration * (CGFloat)indexPath.row / (CGFloat)[self collectionView:self.collectionView numberOfItemsInSection:indexPath.section];
        anim.repeatCount = NSUIntegerMax;
        anim.autoreverses = YES;
        [cell.layer addAnimation:anim forKey:@"MVShakeAnimation"];
    }
    cell.informOnDeletion = self;
    cell.deleteMethod = @selector(deleteModelForCollectionViewCell:);
    return cell;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    MVModel *model = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.selectionDelegate favouriteModelSelected:model];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch(type) {
        case NSFetchedResultsChangeDelete:
            [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
            break;
    }
}

- (void)deleteModelForCollectionViewCell:(CollectionViewCell *)cell {
    NSIndexPath *deletePath = [self.collectionView indexPathForCell:cell];
    MVModel *model = [self.fetchedResultsController objectAtIndexPath:deletePath];
    [self.context deleteObject:model];
    [self.context save:NULL];
}

@end
