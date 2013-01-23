//
//  MVBackgroundMenuCell.m
//  MVIEWER
//
//  Created by Kamil Kocemba on 23/01/2013.
//  Copyright (c) 2013 Future Workshops. All rights reserved.
//

#import "MVBackgroundMenuCell.h"

#import <QuartzCore/QuartzCore.h>

@interface MVBackgroundMenuCell()

@property (nonatomic, strong) UIView *titleBackgroundView;

@end

@implementation MVBackgroundMenuCell

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOpacity = 0.75f;
        self.layer.shadowRadius = 3.0f;
        self.layer.shadowOffset = CGSizeZero;
        
        self.backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.backgroundImageView];
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.imageView];
        
        self.titleBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        self.titleBackgroundView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.titleBackgroundView.layer.shadowOpacity = 0.75f;
        self.titleBackgroundView.layer.shadowRadius = 3.0f;
        self.titleBackgroundView.layer.shadowOffset = CGSizeZero;
        self.titleBackgroundView.alpha = 0.6f;
        self.titleBackgroundView.backgroundColor = [UIColor whiteColor];

        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.font = [UIFont fontWithName:@"Avenir-Roman" size:16.0f];
        self.titleLabel.textColor = [UIColor blackColor];
        [self.titleBackgroundView addSubview:self.titleLabel];
        [self addSubview:self.titleBackgroundView];

        self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list-item-bg"]];
        self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list-item-bg-sel"]];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect frame = CGRectInset(self.bounds, 10.0f, 10.0f);
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect: frame].CGPath;
    self.imageView.frame = frame;
    self.backgroundImageView.frame = frame;
    CGFloat titleHeight = 24.0f;
    self.titleBackgroundView.frame = CGRectMake(10.0f, frame.size.height + 10.0f - titleHeight, frame.size.width, titleHeight);
    self.titleBackgroundView.layer.shadowPath = [UIBezierPath bezierPathWithRect: self.titleLabel.frame].CGPath;
    self.titleLabel.frame = CGRectInset(self.titleBackgroundView.bounds, 10.0f, 0.0f);
}

@end
