//
//  MVRadialMenuView.m
//  3D Model Viewer
//
//  Created by Tim Chilvers on 27/11/2012.
//  Copyright (c) 2012 Future Workshops. All rights reserved.
//

#import "MVRadialMenuView.h"
#import "MVMenuButton.h"

#import <QuartzCore/QuartzCore.h>

@interface MVRadialMenuView ()

@property (nonatomic, assign) BOOL visible;

@end

@implementation MVRadialMenuView

- (id)initWithFrame:(CGRect)frame segments:(NSArray *)segments {
    if ((self = [super initWithFrame:frame])) {

        CGRect btnFrame = CGRectMake(.0f, .0f, frame.size.width, frame.size.height);
        for (NSInteger i = 0; i < segments.count; ++i) {
            MVMenuButton *btn = [[MVMenuButton alloc] initWithIndex:i count:segments.count title:segments[i]];
            btn.frame = btnFrame;
            btn.tag = i;
            [btn addTarget:self action:@selector(didSelectSegment:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
        }
        self.layer.anchorPoint = CGPointMake(0.0f, 1.0f);
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
    self.visible = YES;
    if (animated) {
        self.transform = CGAffineTransformMakeRotation(M_PI_2);
        [UIView animateWithDuration:0.4f animations:^{
            self.transform = CGAffineTransformIdentity;
        }];
    } else {
        self.transform = CGAffineTransformIdentity;
    }
}

- (void)hideAnimated:(BOOL)animated {
    self.visible = NO;
    if (animated) {
        self.transform = CGAffineTransformIdentity;
        [UIView animateWithDuration:0.4f animations:^{
            self.transform = CGAffineTransformMakeRotation(M_PI_2);
        }];
    } else {
        self.transform = CGAffineTransformMakeRotation(M_PI_2);
    }
}

- (void)didSelectSegment:(UIButton *)sender {
    NSInteger index = sender.tag;
    [self.delegate radialMenuView:self didSelectIndex:index];
}

@end
