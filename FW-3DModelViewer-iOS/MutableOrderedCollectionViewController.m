//
//  MutableOrderedCollectionViewController.m
//  TestCollectionView
//
//  Created by Marco Meschini on 03/10/2012.
//  Copyright (c) 2012 Marco Meschini. All rights reserved.
//

#import "MutableOrderedCollectionViewController.h"
#import "UICollectionView+FWT.h"
#import "UIScrollView+FWT.h"
#import <QuartzCore/QuartzCore.h>

@implementation MutableOrderedCollectionView
@dynamic dataSource;

- (id)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath*)indexPath
{
    id toReturn = [super dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    NSLog(@"dequeueReusableCellWithReuseIdentifier");
    return toReturn;
}

@end

UIImage* (^MMImageFromLayerBlock)(CALayer *, BOOL, CGFloat) = ^(CALayer *layer, BOOL opaque, CGFloat scale) {
    UIGraphicsBeginImageContextWithOptions(layer.bounds.size, opaque, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
};

@interface MutableOrderedCollectionViewController () <MutableOrderedCollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, readwrite, strong) MutableOrderedCollectionView *collectionView;

@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;
@property (nonatomic, strong) UIImageView *panImageView;
@property (nonatomic, assign) CGPoint touchPoint;
@property (nonatomic, assign) CGFloat autoscrollDistance;
@property (nonatomic, assign) CGFloat autoscrollThreshold;
@property (nonatomic, strong) CADisplayLink *autoscrollDisplayLink;

@end

@implementation MutableOrderedCollectionViewController

- (void)dealloc
{
    [self _autoscrollDisplayLinkEnabled:NO];
}

- (void)loadView
{
    [super loadView];
    
    //
    self.collectionView.frame = self.view.bounds;
    [self.view addSubview:self.collectionView];
    
    //
    [self.collectionView addGestureRecognizer:self.longPressGesture];
    
    //
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    if (layout.scrollDirection == UICollectionViewScrollDirectionVertical)
        self.autoscrollThreshold = layout.itemSize.height*.4f;
    else
        self.autoscrollThreshold = layout.itemSize.width*.4f;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getters
- (MutableOrderedCollectionView *)collectionView
{
    if (!self->_collectionView)
    {
        UICollectionViewFlowLayout *layout = [[self class] defaultCollectionViewFlowLayout];
        self->_collectionView = [[MutableOrderedCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        self->_collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self->_collectionView.delaysContentTouches = NO;
        self->_collectionView.dataSource = self;
        self->_collectionView.delegate = self;
    }
    
    return self->_collectionView;
}

- (UILongPressGestureRecognizer *)longPressGesture
{
    if (!self->_longPressGesture)
    {
        self->_longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
        self->_longPressGesture.minimumPressDuration = .2f;
    }
    
    return self->_longPressGesture;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    
}

#pragma mark - Gesture handler
- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer
{
    switch (gestureRecognizer.state)
    {
        case UIGestureRecognizerStatePossible:
        case UIGestureRecognizerStateFailed:
            // do nothing
            break;
            
        case UIGestureRecognizerStateCancelled:
        {
            NSLog(@"UIGestureRecognizerStateCancelled");
            [self _autoscrollDisplayLinkEnabled:NO];
            
        } break;
            
        case UIGestureRecognizerStateEnded      : [self _gestureEnded:gestureRecognizer]; break;
        case UIGestureRecognizerStateChanged    : [self _gestureChanged:gestureRecognizer]; break;
        case UIGestureRecognizerStateBegan      : [self _gestureBegan:gestureRecognizer]; break;
    }
}

#pragma mark - Gesture private
- (void)_gestureEnded:(UIGestureRecognizer *)gestureRecognizer
{
    void(^RemoveAndRestorePanImageView)(UIView *) = ^(UIView *view) {
        [view removeFromSuperview];
        view.transform = CGAffineTransformIdentity;
    };
    
    NSIndexPath *ghostIndexPath = [self _collectionViewFlowLayout].ghostIndexPath;
    if (ghostIndexPath)
    {
        CGPoint centerPoint = [gestureRecognizer locationInView:self.collectionView];
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:centerPoint];
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath ? indexPath : ghostIndexPath];
        CGRect targetFrame = [self.view convertRect:cell.frame fromView:cell.superview];
        [UIView animateWithDuration:.2f
                         animations:^{
                             self.panImageView.frame = targetFrame;
                         }
                         completion:^(BOOL finished) {
                             RemoveAndRestorePanImageView(self.panImageView);
                             
                             // if indexPath then check if we need to update the model
                             if (indexPath)
                                 [self _moveDataObjectAtIndexPath:ghostIndexPath toIndexPath:indexPath];
                             
                             [self _collectionViewFlowLayout].ghostIndexPath = nil;
                             
                         }];
    }
    else
    {
        NSLog(@"no indexPath found");
        RemoveAndRestorePanImageView(self.panImageView);
    }
    
    [self _autoscrollDisplayLinkEnabled:NO];
}

- (void)_gestureChanged:(UIGestureRecognizer *)gestureRecognizer
{
    //
    CGPoint centerPoint = [gestureRecognizer locationInView:self.collectionView];
    CGPoint convertedCenterPoint = [self.collectionView convertPoint:centerPoint toView:self.view];
    float diffx = convertedCenterPoint.x - self.touchPoint.x;
    float diffy = convertedCenterPoint.y - self.touchPoint.y;
    CGPoint center = self.panImageView.center;
    center.x += diffx;
    center.y += diffy;
    
    //
    CGRect collectionFrame = self.collectionView.frame;
    CGFloat minX = CGRectGetMinX(collectionFrame);
    CGFloat maxX = CGRectGetMaxX(collectionFrame);
    CGFloat minY = CGRectGetMinY(collectionFrame);
    CGFloat maxY = CGRectGetMaxY(collectionFrame);
    center.x = center.x < minX ? minX : center.x;
    center.x = center.x > maxX ? maxX : center.x;
    center.y = center.y < minY ? minY : center.y;
    center.y = center.y > maxY ? maxY : center.y;
    
    //
    self.panImageView.center = center;
    
    //
    self.touchPoint = convertedCenterPoint;
    
    //
    [self _updateGhostIndexPath];
    
    //
    [self _autoscrollIfNeeded];
}

- (void)_gestureBegan:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint touchCenterPoint = [gestureRecognizer locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:touchCenterPoint];
    if (indexPath)
    {
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
        [self _collectionViewFlowLayout].ghostIndexPath = indexPath;
        
        //
        touchCenterPoint = [self.collectionView convertPoint:touchCenterPoint toView:self.view];
        CGPoint cellCenterPoint = [self.collectionView convertPoint:cell.center toView:self.view];
        
        //
        self.touchPoint = touchCenterPoint;
        
        //
        UIImage *image = MMImageFromLayerBlock(cell.layer, NO, .0f);
        if (!self.panImageView) self.panImageView = [[UIImageView alloc] init];
        self.panImageView.image = image;
        self.panImageView.frame = CGRectMake(.0f, .0f, image.size.width, image.size.height);
        self.panImageView.center = cellCenterPoint;
        [self.view addSubview:self.panImageView];
        [UIView animateWithDuration:.15f
                         animations:^{
                             self.panImageView.alpha = .85f;
                             self.panImageView.center = touchCenterPoint;
                             self.panImageView.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
                         }
         ];
    }
}

#pragma mark - Private
- (void)_autoscrollDisplayLinkEnabled:(BOOL)enabled
{
    if (enabled && self.autoscrollDisplayLink == nil)
    {
        self.autoscrollDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(autoscrollTimerFired:)];
        [self.autoscrollDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
    else if (!enabled && self.autoscrollDisplayLink != nil)
    {
        [self.autoscrollDisplayLink invalidate];
        self.autoscrollDisplayLink = nil;
    }
}

- (void)_moveDataObjectAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath
{
    if (indexPath.row == newIndexPath.row) return;
   
    NSLog(@"_moveDataObjectAtIndexPath:%@ toIndexPath:%@", indexPath, newIndexPath);
    [self.collectionView.dataSource collectionView:self.collectionView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
}

- (void)_updateGhostIndexPath
{
    CGFloat side = 80.0f;
    CGRect rect = {
        .origin = CGPointMake((CGRectGetWidth(self.panImageView.bounds)-side)*.5f, (CGRectGetHeight(self.panImageView.bounds)-side)*.5f),
        .size = CGSizeMake(side, side)
    };
    
    //    UIView *debugView = [self.panImageView viewWithTag:0xbeef];
    //    if (!debugView)
    //    {
    //        debugView = [[UIView alloc] initWithFrame:rect];
    //        debugView.layer.borderWidth = 1.0f;
    //        debugView.layer.borderColor = [UIColor redColor].CGColor;
    //        debugView.tag = 0xbeef;
    //        [self.panImageView addSubview:debugView];
    //    }
    //    debugView.frame = rect;
    
    CGRect targetRect = [self.collectionView convertRect:rect fromView:self.panImageView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemInRect:targetRect];
    if (indexPath)
    {
        if (![indexPath isEqual:[self _collectionViewFlowLayout].ghostIndexPath])
        {
            [self.collectionView performBatchUpdates:^{
                [self _moveDataObjectAtIndexPath:[self _collectionViewFlowLayout].ghostIndexPath toIndexPath:indexPath];
                [self.collectionView moveItemAtIndexPath:[self _collectionViewFlowLayout].ghostIndexPath toIndexPath:indexPath];
            }
                                          completion:NULL];
        }
        
        [self _collectionViewFlowLayout].ghostIndexPath = indexPath;
    }
}

- (MutableOrderedCollectionViewFlowLayout *)_collectionViewFlowLayout
{
    return (MutableOrderedCollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
}

#pragma mark - Autoscrolling methods
- (void)_autoscrollIfNeeded
{
    self.autoscrollDistance = 0;
    
    CGRect collectionFrame = self.collectionView.frame;
    CGRect panImageFrame = self.panImageView.frame;
    
    // only autoscroll if the panImageView is overlapping the collectionView frame
    if (!CGRectContainsRect(collectionFrame, panImageFrame))
    {
        CGRect intersection = CGRectIntersection(collectionFrame, panImageFrame);
        CGSize intersectionSize = intersection.size;
        
        CGFloat distanceFromTopEdge = .0f;
        CGFloat distanceFromBottomEdge = .0f;
        BOOL needsToAutoscroll = NO;
        UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
        if (layout.scrollDirection == UICollectionViewScrollDirectionVertical)
        {
            if (intersectionSize.height < CGRectGetHeight(panImageFrame))
            {
                distanceFromTopEdge = self.touchPoint.y - CGRectGetMinY(collectionFrame);
                distanceFromBottomEdge = CGRectGetMaxY(collectionFrame)-self.touchPoint.y;
                needsToAutoscroll = YES;
            }
        }
        else
        {
            if (intersectionSize.width < CGRectGetWidth(panImageFrame))
            {
                distanceFromTopEdge = self.touchPoint.x - CGRectGetMinX(collectionFrame);
                distanceFromBottomEdge = CGRectGetMaxX(collectionFrame)-self.touchPoint.x;
                needsToAutoscroll = YES;
            }
        }
        
        CGFloat (^autoscrollDistanceForProximityToEdge)(CGFloat) = ^(CGFloat proximity) {
            return ceilf((_autoscrollThreshold - proximity) / 5.0);
        };
        
        if (distanceFromTopEdge < _autoscrollThreshold && needsToAutoscroll)
            self.autoscrollDistance = autoscrollDistanceForProximityToEdge(distanceFromTopEdge) * -1; // if scrolling top, distance is negative
        else if (distanceFromBottomEdge < _autoscrollThreshold && needsToAutoscroll)
            self.autoscrollDistance = autoscrollDistanceForProximityToEdge(distanceFromBottomEdge);
        
        //
        [self _autoscrollDisplayLinkEnabled:(self.autoscrollDistance == 0) ? NO : YES];
    }
}

- (void)autoscrollTimerFired:(NSTimer *)timer
{
    // makes sure the autoscroll distance won't result in scrolling past the content of the scroll view
    CGPoint contentOffset = self.collectionView.contentOffset;
    float minimumLegalDistance = self.collectionView.minimumScrollDistance;
    float maximumLegalDistance = self.collectionView.maximumScrollDistance;
    self.autoscrollDistance = MAX(self.autoscrollDistance, minimumLegalDistance);
    self.autoscrollDistance = MIN(self.autoscrollDistance, maximumLegalDistance);
    
    // autoscroll by changing content offset
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    if (layout.scrollDirection == UICollectionViewScrollDirectionVertical)
        contentOffset.y += self.autoscrollDistance;
    else
        contentOffset.x += self.autoscrollDistance;
    
    self.collectionView.contentOffset = contentOffset;
    
    //
    [self _updateGhostIndexPath];
}

#pragma mark - Public


#pragma mark - To be overridden
+ (MutableOrderedCollectionViewFlowLayout *)defaultCollectionViewFlowLayout
{
    return [[MutableOrderedCollectionViewFlowLayout alloc] init];
}

@end
