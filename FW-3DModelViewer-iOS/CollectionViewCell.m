//
//  Cell.m
//  TestCollectionView
//
//  Created by Marco Meschini on 27/09/2012.
//  Copyright (c) 2012 Marco Meschini. All rights reserved.
//

#import "CollectionViewCell.h"
#import <QuartzCore/QuartzCore.h>

@interface CollectionViewCell ()
@property (nonatomic, strong) UIView *deleteButton;
@property (nonatomic, readwrite, strong) UIView *decoratorView;
@end

@implementation CollectionViewCell
@synthesize label = _label;
@synthesize imageView = _imageView;
@synthesize decoratorView = _decoratorView;

- (void)deleteButtonPressed:(UIGestureRecognizer *) gesture{
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [self.informOnDeletion performSelector:self.deleteMethod withObject:self afterDelay:0.0f];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!self.imageView.superview)
        [self.contentView addSubview:self.imageView];
    
    self.imageView.frame = self.bounds;
 
    if (!self.decoratorView.superview)
        [self.contentView addSubview:self.decoratorView];

    self.decoratorView.frame = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(6, 6, 6, 6));
    
    if (!self.label.superview)
        [self.contentView addSubview:self.label];
    
    self.label.frame = self.bounds;
    
    if (self.showDeleteButton) {
        self.deleteButton.frame = CGRectMake(CGRectGetMaxX(self.contentView.bounds) - 30.0f,
                                             0.0f,
                                             20.0f,
                                             20.0f);
        [self.contentView addSubview:self.deleteButton];
    } else {
        [self->_deleteButton removeFromSuperview];
    }
}

- (UIView *)deleteButton {
    if(!self->_deleteButton) {
        self->_deleteButton = [[UIView alloc] init];
        [self->_deleteButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteButtonPressed:)]];
        self->_deleteButton.backgroundColor = [UIColor blackColor];
    }
    return self->_deleteButton;
}

- (UILabel *)label
{
    if (!self->_label)
    {
        self->_label = [[UILabel alloc] init];
        self->_label.backgroundColor = [UIColor clearColor];
        self->_label.textAlignment = NSTextAlignmentCenter;
        self->_label.font = [UIFont boldSystemFontOfSize:12];
        self->_label.textColor = [[UIColor blackColor] colorWithAlphaComponent:.3f];
        self->_label.shadowColor = [[UIColor whiteColor] colorWithAlphaComponent:.5f];
        self->_label.shadowOffset = CGSizeMake(.0f, 1.0f);
        self->_label.text = @"...";
    }
    
    return self->_label;
}

- (UIView *)decoratorView
{
    if (!self->_decoratorView)
    {
        self->_decoratorView = [[UIView alloc] init];
        self->_decoratorView.layer.borderWidth = 10.0f;
        self->_decoratorView.backgroundColor = [UIColor colorWithWhite:.9f alpha:1.0f];
        self->_decoratorView.layer.cornerRadius = 4.0f;
    }
    
    return self->_decoratorView;
}

- (UIImageView *)imageView
{
    if (!self->_imageView)
    {
        static UIImage *_image = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
            //
            CGFloat shadowBlur = 5.0f;
            CGFloat cornerRadius = 4.0f;
            CGColorRef strokeColorRef = [UIColor colorWithWhite:.945f alpha:1.0f].CGColor;
            CGColorRef fillColorRef = [UIColor colorWithWhite:.9f alpha:1.0f].CGColor;
            CGColorRef shadowColorRef = [[UIColor blackColor] colorWithAlphaComponent:.8f].CGColor;
            CGSize shadowOffset = CGSizeMake(.0f, 1.0f);
            
            _image = [self _squareTileImageWithCornerRadius:cornerRadius
                                             strokeColorRef:strokeColorRef
                                               fillColorRef:fillColorRef
                                                 shadowBlur:shadowBlur
                                               shadowOffset:shadowOffset
                                             shadowColorRef:shadowColorRef];
        });

        
        self->_imageView = [[UIImageView alloc] initWithImage:_image];
    }
    
    return self->_imageView;
}

- (UIImage *)_squareTileImageWithCornerRadius:(CGFloat)cornerRadius
                               strokeColorRef:(CGColorRef)strokeColorRef
                                 fillColorRef:(CGColorRef)fillColorRef
                                   shadowBlur:(CGFloat)shadowBlur
                                 shadowOffset:(CGSize)shadowOffset
                               shadowColorRef:(CGColorRef)shadowColorRef
{
    CGFloat side = shadowBlur*2+cornerRadius*2+1.0f;
    CGSize size = CGSizeMake(side, side);
    CGRect ctxRect = CGRectMake(.0f, .0f, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, .0f);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGRect bpRect = CGRectInset(ctxRect, shadowBlur, shadowBlur);
    CGContextSetStrokeColorWithColor(ctx, strokeColorRef);
    CGContextSetFillColorWithColor(ctx, fillColorRef);
    UIBezierPath *bp = [UIBezierPath bezierPathWithRoundedRect:bpRect cornerRadius:cornerRadius];
    CGContextSaveGState(ctx);
    CGContextSetShadowWithColor(ctx, shadowOffset, shadowBlur, shadowColorRef);
    [bp fill];
    CGContextRestoreGState(ctx);
    [bp stroke];
    
    //
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGFloat inset = shadowBlur+cornerRadius;
    return [image resizableImageWithCapInsets:UIEdgeInsetsMake(inset, inset, inset, inset)];
}


@end








