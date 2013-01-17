//
//  MVRadialMenuView.m
//  3D Model Viewer
//
//  Created by Tim Chilvers on 27/11/2012.
//  Copyright (c) 2012 Future Workshops. All rights reserved.
//

#import "MVRadialMenuView.h"
#import "MVMenuSegment.h"

#import <QuartzCore/QuartzCore.h>

@interface MVRadialMenuView ()

@property (nonatomic, assign) BOOL visible;

@end

@implementation MVRadialMenuView

const CGFloat ROTATION_ANGLE = -M_PI_2;

- (id)initWithFrame:(CGRect)frame segments:(NSArray *)segments {
    if ((self = [super initWithFrame:frame])) {

        CGRect btnFrame = CGRectMake(.0f, .0f, frame.size.width, frame.size.height);
        for (NSInteger i = 0; i < segments.count; ++i) {
            MVMenuSegment *btn = [[MVMenuSegment alloc] initWithIndex:i count:segments.count title:segments[i]];
            btn.frame = btnFrame;
            btn.tag = i;
            [btn addTarget:self action:@selector(didSelectSegment:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
        }
        self.layer.anchorPoint = CGPointMake(0.0f, 1.0f);
        
        self.layer.shadowRadius = 10.0f;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOpacity = 0.4f;
        self.clipsToBounds = NO;
        
        self.visible = YES;
    }
    return self;
}

- (void)toggleAnimated:(BOOL)animated {
    if (!self.visible)
        [self showAnimated:animated];
    else
        [self hideAnimated:animated];
}

- (void)showAnimated:(BOOL)animated {
    if (self.visible)
        return;
    self.visible = YES;
    if (animated) {
        self.transform = CGAffineTransformMakeRotation(ROTATION_ANGLE);
        [UIView animateWithDuration:0.4f animations:^{
            self.transform = CGAffineTransformIdentity;
        }];
    } else {
        self.transform = CGAffineTransformIdentity;
    }
}

- (void)hideAnimated:(BOOL)animated {
    [self.delegate radialMenuViewWillHide:self];
    if (!self.visible)
        return;
    self.visible = NO;
    if (animated) {
        self.transform = CGAffineTransformIdentity;
        [UIView animateWithDuration:0.4f animations:^{
            self.transform = CGAffineTransformMakeRotation(ROTATION_ANGLE);
        }];
    } else {
        self.transform = CGAffineTransformMakeRotation(ROTATION_ANGLE);
    }
}

- (void)didSelectSegment:(UIButton *)sender {
    NSInteger index = sender.tag;
    [self.delegate radialMenuView:self didSelectIndex:index];
}

@end
