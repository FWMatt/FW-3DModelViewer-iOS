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

@end

@implementation CollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOpacity = 0.75f;
        self.layer.shadowRadius = 3.0f;
        self.layer.shadowOffset = CGSizeZero;
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.imageView];
        self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list-item-bg"]];
        self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list-item-bg-sel"]];
        
        [self.contentView addSubview:self.deleteButton];
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
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect: CGRectInset(self.bounds, 10.0f, 10.0f)].CGPath;
    self.imageView.frame = self.bounds;
    self.deleteButton.frame = CGRectMake(CGRectGetMaxX(self.contentView.bounds) - 26.0f, -5.0f, 32.0f, 32.0f);
}

- (UIView *)deleteButton {
    if(!self->_deleteButton) {
        self->_deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self->_deleteButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteButtonPressed:)]];
        [self->_deleteButton setBackgroundImage:[UIImage imageNamed:@"remove-btn"] forState:UIControlStateNormal];
    }
    return self->_deleteButton;
}


@end








