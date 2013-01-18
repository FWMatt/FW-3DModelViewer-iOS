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

@property (nonatomic, strong) UIButton *deleteButton;

@end

@implementation CollectionViewCell

@synthesize imageView = _imageView;



- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOpacity = 0.75f;
        self.layer.shadowRadius = 3.0f;
        self.layer.shadowOffset = CGSizeZero;
    }
    return self;
}

- (void)deleteButtonPressed:(UIGestureRecognizer *) gesture{
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [self.informOnDeletion performSelector:self.deleteMethod withObject:self afterDelay:0.0f];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    
    if (!self.imageView.superview)
        [self.contentView addSubview:self.imageView];
    
    self.imageView.frame = self.bounds;
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect: CGRectInset(self.bounds, 10.0f, 10.0f)].CGPath;

    
    if (self.showDeleteButton) {
        self.deleteButton.frame = CGRectMake(CGRectGetMaxX(self.contentView.bounds) - 20.0f, -5.0f, 28.0f, 28.0f);
        [self.contentView addSubview:self.deleteButton];
    } else {
        [self->_deleteButton removeFromSuperview];
    }
}

- (UIView *)deleteButton {
    if(!self->_deleteButton) {
        self->_deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self->_deleteButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteButtonPressed:)]];
        [self->_deleteButton setBackgroundImage:[UIImage imageNamed:@"remove-btn"] forState:UIControlStateNormal];
    }
    return self->_deleteButton;
}

- (UIImageView *)imageView {
    if (!self->_imageView) {        
        self->_imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list-item-bg"]];
    }
    return self->_imageView;
}

@end








