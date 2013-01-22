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


@interface MVFavouriteMenuViewController ()<NSFetchedResultsControllerDelegate, MutableOrderedCollectionViewDataSource>

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
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"menu-bg"]];

    self.collectionView.frame = CGRectOffset(self.view.bounds, 0.0f, 26.0f);
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.contentInset = UIEdgeInsetsMake(0.0, 30.0f, 0.0f, 30.0f);
    self.collectionView.dataSource = self;
    
    [self.collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];

    UIFont *buttonFont = [UIFont fontWithName:@"Avenir-Light" size:20.0f];
    UIColor *lightGrayColor = [UIColor colorWithRed:222.0f / 255.0f green:222.0f / 255.0f blue:222.0f / 255.0f alpha:1.0f];
    
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [editButton setTitleColor:lightGrayColor forState:UIControlStateNormal];
    editButton.titleLabel.font =  buttonFont;
    UIImage *buttonImage = [[UIImage imageNamed:@"edit-btn-bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(6.0f, 5.0f, 6.0f, 5.0f)];
    [editButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [editButton setTitle:@"edit" forState:UIControlStateNormal];
    [editButton setTitle:@"done" forState:UIControlStateSelected];
    [editButton addTarget:self action:@selector(editButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    editButton.frame = CGRectMake(CGRectGetHeight(self.view.bounds) - 140.0f, 26.0f, 120.0f, 46.0f);
    [self.view addSubview:editButton];

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(36.0f, -10.0f, 120.0f, 40)];
    titleLabel.backgroundColor = lightGrayColor;
    titleLabel.textColor = [UIColor colorWithRed:44.0f / 255.0f green:41.0f / 255.0f blue:41.0f / 255.0f alpha:1.0f];
    titleLabel.text = @"FAVORITES";
    titleLabel.font = buttonFont;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
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

#pragma mark - Overridden
+ (MutableOrderedCollectionViewFlowLayout *)defaultCollectionViewFlowLayout {
    return [[[self class] layoutsArray] objectAtIndex:0];
}

+ (NSArray *)layoutsArray {
    static NSArray *_array = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        MutableOrderedCollectionViewFlowLayout *l0 = [[MutableOrderedCollectionViewFlowLayout alloc] init];
        l0.itemSize = CGSizeMake(208, 161);
        l0.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        l0.minimumInteritemSpacing = .0f;
        _array = @[l0];
    });
    
    return _array;
}


- (void)deleteModelForCollectionViewCell:(CollectionViewCell *)cell {
    NSIndexPath *deletePath = [self.collectionView indexPathForCell:cell];
    MVModel *model = [self.fetchedResultsController objectAtIndexPath:deletePath];
    [self.context deleteObject:model];
    [self.context save:NULL];
}

@end
