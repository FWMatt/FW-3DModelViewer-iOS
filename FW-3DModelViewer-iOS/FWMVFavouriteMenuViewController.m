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

@interface FWMVFavouriteModelMeta : NSObject

@property (nonatomic,strong) NSString *modelName;
@property (nonatomic,strong) NSString *filePath;
@property (nonatomic,strong) NSString *imagePath;

@end

@implementation FWMVFavouriteModelMeta

@end

@interface FWMVFavouriteMenuViewController ()

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
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    id object = [self.modelDataArray objectAtIndex:sourceIndexPath.row];
    [self.modelDataArray removeObjectAtIndex:sourceIndexPath.row];
    [self.modelDataArray insertObject:object atIndex:destinationIndexPath.row];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMinimumIntegerDigits:3];
    
    for (FWMVFavouriteModelMeta *data in self.modelDataArray) {
        NSString *oldFilePath = data.filePath;
        NSInteger index = [self.modelDataArray indexOfObject:data];
        NSString *newFilePath = [[oldFilePath stringByDeletingLastPathComponent] stringByAppendingString:[NSString stringWithFormat:@"%@_%@",[formatter stringFromNumber:[NSNumber numberWithInteger:index]],[[oldFilePath lastPathComponent] substringFromIndex:4]]];
        if (![newFilePath isEqualToString:oldFilePath]) {
            [fileManager moveItemAtPath:oldFilePath toPath:newFilePath error:nil];
        }
    
    }
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

@end
