//
//  FWMVFavouriteMenuViewController.m
//  FW-3DModelViewer-iOS
//
//  Created by Tim Chilvers on 28/11/2012.
//  Copyright (c) 2012 Future Workshops. All rights reserved.
//

#import "FWMVFavouriteMenuViewController.h"
#import "CollectionViewCell.h"
#import <QuartzCore/QuartzCore.h>


@interface MutableOrderedCollectionViewController (Known)
@property (nonatomic, assign) CGFloat autoscrollDistance;
- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer;
@end

@interface FWMVFavouriteModelMeta : NSObject

@property (nonatomic,strong) NSString *modelName;
@property (nonatomic,strong) NSString *filePath;
@property (nonatomic,strong) NSString *imagePath;

@end

@implementation FWMVFavouriteModelMeta

@end

@interface FWMVFavouriteMenuViewController ()

@property (nonatomic, assign) BOOL editing;
@property (nonatomic, assign) UICollectionViewScrollDirection scrollDirection;
@property (nonatomic, strong) NSMutableArray *modelDataArray;
@end

@implementation FWMVFavouriteMenuViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return self;
}

- (void)viewDidLoad
{

    [super viewDidLoad];
    
    //
    self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    //
    BOOL isiPad = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
    self.collectionView.frame = CGRectInset(self.view.bounds, isiPad ? 60.0f : 20.0f, isiPad ? 30.0f : 20.0f);
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.layer.borderColor = [UIColor redColor].CGColor;
    self.collectionView.layer.borderWidth = 2.0f;
    [self.collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [editButton setTitle:@"Edit" forState:UIControlStateNormal];
    [editButton setTitle:@"Done" forState:UIControlStateSelected];
    [editButton addTarget:self action:@selector(editButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [editButton sizeToFit];
    editButton.frame = CGRectMake(CGRectGetMaxX(self.view.bounds) - editButton.frame.size.width,
                                  CGRectGetMinY(self.view.bounds),
                                  editButton.frame.size.width,
                                  editButton.frame.size.height);
    [self.view addSubview:editButton];
    
}

- (void)editButtonTapped:(UIButton *)editButton {
    editButton.selected = !editButton.selected;
    self.editing = editButton.selected;
    for (CollectionViewCell *cell in [self.collectionView visibleCells]) {
        cell.showDeleteButton = editButton.selected;
        [cell setNeedsLayout];
    }

}

- (CGColorRef)colorForIndex:(NSInteger)index {
    index = index % 4;
    switch (index) {
        case 0:
            return [UIColor redColor].CGColor;
            break;
        case 1:
            return [UIColor greenColor].CGColor;
            break;
        case 2:
            return [UIColor purpleColor].CGColor;
            break;
        case 3:
            return [UIColor grayColor].CGColor;
            break;
        default:
            return [UIColor whiteColor].CGColor;
            break;
    }
}

- (void)updateFilesToReflectModelArray {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMinimumIntegerDigits:3];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *modelDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Models"]; // Get documents folder

    for (FWMVFavouriteModelMeta *data in self.modelDataArray) {
        NSString *oldFilePath = [modelDirectory stringByAppendingPathComponent:data.filePath];
        NSInteger index = [self.modelDataArray indexOfObject:data];
        NSString *newFilePath = [[oldFilePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@",[formatter stringFromNumber:[NSNumber numberWithInteger:index]],[[oldFilePath lastPathComponent] substringFromIndex:4]]];
        if (![newFilePath isEqualToString:oldFilePath]) {
            data.filePath = [newFilePath lastPathComponent];
            NSError *error = nil;
            [fileManager moveItemAtPath:oldFilePath toPath:newFilePath error:&error];
            if (error) {
                NSLog(@"Moving error %@ for old path %@ to new path %@",error,oldFilePath,newFilePath);
            }
        
        }        
    }
}

- (NSMutableArray *)modelDataArray {
    if (!self->_modelDataArray) {
        NSMutableArray *array = [NSMutableArray array];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
        
        NSArray *contentsOfModels = [fileManager contentsOfDirectoryAtPath:[documentsDirectory stringByAppendingPathComponent:@"Models"] error:nil];
        contentsOfModels = [contentsOfModels sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        
        for (NSString *modelFileName in contentsOfModels) {
            FWMVFavouriteModelMeta *data = [[FWMVFavouriteModelMeta alloc] init];
            data.modelName = [[modelFileName stringByDeletingPathExtension] substringFromIndex:4];
            data.imagePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"Thumbs/%@.png",data.modelName]];
            data.filePath = modelFileName;
            [array addObject:data];
        }
        self->_modelDataArray = array;
    }
    return self->_modelDataArray;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return self.modelDataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    FWMVFavouriteModelMeta *data = [self.modelDataArray objectAtIndex:indexPath.row];
    cell.label.text = data.modelName;
    cell.imageView.image = [UIImage imageWithContentsOfFile:data.imagePath];
    cell.decoratorView.layer.borderColor = [self colorForIndex:indexPath.row];
    cell.showDeleteButton = self.editing;
    cell.informOnDeletion = self;
    cell.deleteMethod = @selector(deleteModelForCollectionViewCell:);
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    id object = [self.modelDataArray objectAtIndex:sourceIndexPath.row];
    [self.modelDataArray removeObjectAtIndex:sourceIndexPath.row];
    [self.modelDataArray insertObject:object atIndex:destinationIndexPath.row];
    
    [self updateFilesToReflectModelArray];
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    FWMVFavouriteModelMeta *selectedData = [self.modelDataArray objectAtIndex:indexPath.row];
    [self.selectionDelegate favouriteModelSelectedWithName:selectedData.filePath];
}
#pragma mark - Overridden
+ (MutableOrderedCollectionViewFlowLayout *)defaultCollectionViewFlowLayout
{
    return [[[self class] layoutsArray] objectAtIndex:0];
}

+ (NSArray *)layoutsArray
{
    static NSArray *_array = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        MutableOrderedCollectionViewFlowLayout *l0 = [[MutableOrderedCollectionViewFlowLayout alloc] init];
        l0.itemSize = CGSizeMake(100, 120);
        l0.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        l0.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        l0.minimumInteritemSpacing = .0f;
        
        _array = @[l0];
    });
    
    return _array;
}


- (void)deleteModelForCollectionViewCell:(CollectionViewCell *)cell {
    NSIndexPath *deletePath = [self.collectionView indexPathForCell:cell];
    FWMVFavouriteModelMeta *modelData = [self.modelDataArray objectAtIndex:deletePath.row];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *modelDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Models"]; // Get documents folder
    NSError *error = nil;
    
    [fileManager removeItemAtPath:[modelDirectory stringByAppendingPathComponent:modelData.filePath] error:&error];
    [self.modelDataArray removeObjectAtIndex:deletePath.row];
    [self updateFilesToReflectModelArray];
    [self.collectionView deleteItemsAtIndexPaths:@[deletePath]];

}
@end
