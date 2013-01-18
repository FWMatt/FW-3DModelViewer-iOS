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
#import <QuartzCore/QuartzCore.h>


@interface MVFavouriteMenuViewController ()<NSFetchedResultsControllerDelegate>

@property (nonatomic, assign) BOOL editing;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end


@implementation MVFavouriteMenuViewController

static NSString * const cellIdentifier = @"MVFavoriteCell";

- (id)init {
    if (self = [super init]) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"MVModel"];
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"modelName" ascending:YES]];
        NSManagedObjectContext *context = [RKObjectManager sharedManager].objectStore.managedObjectContextForCurrentThread;
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
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
    
    [self.collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];

    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [editButton setBackgroundColor:[UIColor colorWithRed:48.0f / 255.0f green:48.0f / 255.0f blue:48.0f / 255.0f alpha:1.0f]];
    [editButton setTitle:[@"Edit" uppercaseString] forState:UIControlStateNormal];
    [editButton setTitle:[@"Done" uppercaseString] forState:UIControlStateSelected];
    [editButton addTarget:self action:@selector(editButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [editButton sizeToFit];
    CGSize offset = CGSizeMake(10.0f, -10.0f);
    editButton.frame = CGRectInset(editButton.frame, -20.0f, -10.0f);
    editButton.frame = CGRectMake(CGRectGetMaxX(self.view.bounds) - editButton.frame.size.width - offset.width,
                                  CGRectGetMinY(self.view.bounds) - offset.height,
                                  editButton.frame.size.width,
                                  editButton.frame.size.height);
    editButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self.view addSubview:editButton];

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    titleLabel.backgroundColor = [UIColor colorWithRed:222.0f / 255.0f green:222.0f / 255.0f blue:222.0f / 255.0f alpha:1.0f];
    titleLabel.textColor = [UIColor colorWithRed:44.0f / 255.0f green:41.0f / 255.0f blue:41.0f / 255.0f alpha:1.0f];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.fetchedResultsController performFetch:NULL];
}

- (void)editButtonTapped:(UIButton *)editButton {
    editButton.selected = !editButton.selected;
    self.editing = editButton.selected;
    for (CollectionViewCell *cell in [self.collectionView visibleCells]) {
        cell.showDeleteButton = editButton.selected;
        [cell setNeedsLayout];
    }

}

- (UIColor *)colorForIndex:(NSInteger)index {
    const CGFloat saturation = .7f, brightness = .65f;
    NSInteger count = [self collectionView:self.collectionView numberOfItemsInSection:0];
    return [UIColor colorWithHue:(CGFloat)index / (CGFloat)count saturation:saturation brightness:brightness alpha:1.0f];
}

//- (void)updateFilesToReflectModelArray {
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    
//    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
//    [formatter setMinimumIntegerDigits:3];
//    
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    
//    NSString *modelDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Models"]; // Get documents folder
//
//    for (MVFavouriteModelMeta *data in self.modelDataArray) {
//        NSString *oldFilePath = [modelDirectory stringByAppendingPathComponent:data.filePath];
//        NSInteger index = [self.modelDataArray indexOfObject:data];
//        NSString *newFilePath = [[oldFilePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@",[formatter stringFromNumber:[NSNumber numberWithInteger:index]],[[oldFilePath lastPathComponent] substringFromIndex:4]]];
//        if (![newFilePath isEqualToString:oldFilePath]) {
//            data.filePath = [newFilePath lastPathComponent];
//            NSError *error = nil;
//            [fileManager moveItemAtPath:oldFilePath toPath:newFilePath error:&error];
//            if (error) {
//                NSLog(@"Moving error %@ for old path %@ to new path %@",error,oldFilePath,newFilePath);
//            }
//        
//        }        
//    }
//}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    return [sectionInfo numberOfObjects];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
//    MVModel *model = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.showDeleteButton = self.editing;
    cell.informOnDeletion = self;
    cell.deleteMethod = @selector(deleteModelForCollectionViewCell:);
    return cell;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    MVModel *model = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.selectionDelegate favouriteModelSelected:model];
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
//    NSIndexPath *deletePath = [self.collectionView indexPathForCell:cell];
//    FWMVFavouriteModelMeta *modelData = [self.modelDataArray objectAtIndex:deletePath.row];
//
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    
//    NSString *modelDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Models"]; // Get documents folder
//    NSError *error = nil;
//    
//    [fileManager removeItemAtPath:[modelDirectory stringByAppendingPathComponent:modelData.filePath] error:&error];
//    [self.modelDataArray removeObjectAtIndex:deletePath.row];
//    [self updateFilesToReflectModelArray];
//    [self.collectionView deleteItemsAtIndexPaths:@[deletePath]];

}
@end
