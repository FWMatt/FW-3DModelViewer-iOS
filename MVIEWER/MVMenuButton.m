//
//  MVMenuButton.m
//  3D Model Viewer
//
//  Created by Kamil Kocemba on 16/01/2013.
//  Copyright (c) 2013 Future Workshops. All rights reserved.
//

#import "MVMenuButton.h"

@interface MVMenuButton ()

@property (nonatomic, strong) UIImageView *buttonImage;
@property (nonatomic, assign) BOOL rotated;

@end

@implementation MVMenuButton

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        
        [self setImage:[UIImage imageNamed:@"menu-btn"] forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"menu-btn-sel"] forState:UIControlStateHighlighted];
        
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
        UIImageView *buttonImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu-btn-image"]];
        [self addSubview:buttonImage];
        CGRect frame = buttonImage.frame;
        frame.origin = CGPointMake(9.0f, 26.0f);
        buttonImage.frame = frame;
        self.buttonImage = buttonImage;
        
        [self addTarget:self action:@selector(toggle) forControlEvents:UIControlEventTouchUpInside];
        
        self.rotated = NO;
        [self toggleAnimated:NO];
    }
    return self;
}

- (void)toggle {
    [self toggleAnimated:YES];
}

- (void)toggleAnimated:(BOOL)animated {
    CGAffineTransform t = (self.rotated) ? CGAffineTransformIdentity : CGAffineTransformMakeRotation(M_PI_4);
    if (animated)
        [UIView animateWithDuration:0.4f animations:^{
            self.buttonImage.transform = t;
        }];
    else
        self.buttonImage.transform = t;
    self.rotated = !self.rotated;
}

@end
