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
@property (nonatomic, strong) NSMutableArray *segments;

@end

@implementation MVRadialMenuView

const CGFloat ROTATION_ANGLE = -M_PI_2;

- (id)initWithFrame:(CGRect)frame segments:(NSArray *)segments {
    if ((self = [super initWithFrame:frame])) {

        self.segments = [NSMutableArray array];
        CGRect btnFrame = CGRectMake(-CGRectGetWidth(frame) / 2.0f, CGRectGetHeight(frame) / 2.0f, CGRectGetWidth(frame), CGRectGetHeight(frame));
        for (NSInteger i = 0; i < segments.count; ++i) {
            MVMenuSegment *btn = [[MVMenuSegment alloc] initWithIndex:i count:segments.count title:segments[i]];
            btn.frame = btnFrame;
            btn.tag = i;
            btn.layer.anchorPoint = CGPointMake(0.0f, 1.0f);
            [btn addTarget:self action:@selector(didSelectSegment:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
            [self sendSubviewToBack:btn];
            [self.segments addObject:btn];
        }
        
        self.layer.shadowRadius = 10.0f;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOpacity = 0.5f;
        self.clipsToBounds = NO;
                
        self.visible = YES;
    }
    return self;
}

- (void)rotateByAngle:(CGFloat)angle animated:(BOOL)animated {
    
    void (^alignSegments)(void) = ^{
        [self.segments enumerateObjectsUsingBlock:^(MVMenuSegment *segment, NSUInteger i, BOOL *stop) {
            segment.layer.transform = CATransform3DRotate(segment.layer.transform, (i + 1) * 1.0f /  self.segments.count * angle, 0.0f, 0.0f, 1.0f);
        }];
    };
    
    if (animated) {
        
        [CATransaction begin];
        [CATransaction setValue:[NSNumber numberWithFloat:0.4f] forKey:kCATransactionAnimationDuration];
        
        NSMutableArray *keyTimes = [NSMutableArray arrayWithCapacity:self.segments.count];
        for (NSInteger i = 0; i <= self.segments.count; ++i) {
            [keyTimes addObject:@(i * 1.0f / self.segments.count)];
        }
        [self.segments enumerateObjectsUsingBlock:^(MVMenuSegment *segment, NSUInteger i, BOOL *stop) {
            CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            animation.keyTimes = keyTimes;
            NSMutableArray *values = [NSMutableArray arrayWithCapacity:self.segments.count];
            for (NSInteger j = 0; j <= self.segments.count; ++j) {
                NSInteger x;
                if (angle < 0.0f) {
                    x = j + i + 1 - self.segments.count;
                    if (x < 0)
                        x = 0;
                } else {
                    if (j == 0)
                        x = 0;
                    else if (j > i + 1)
                        x = i + 1;
                    else
                        x = j;
                }
                CGFloat a = x * 1.0f / self.segments.count * angle;
                CATransform3D transform = CATransform3DRotate(segment.layer.transform, a, 0.0f, 0.0f, 1.0f);
                [values addObject:[NSValue valueWithCATransform3D:transform]];
            }
            animation.values = values;
            [segment.layer addAnimation:animation forKey:@"rotation"];
        }];
        [CATransaction setCompletionBlock:alignSegments];
        [CATransaction commit];

    } else {
        alignSegments();
    }
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
    [self rotateByAngle:-ROTATION_ANGLE animated:animated];
}

- (void)hideAnimated:(BOOL)animated {
    [self.delegate radialMenuViewWillHide:self];
    if (!self.visible)
        return;
    self.visible = NO;
    [self rotateByAngle:ROTATION_ANGLE animated:animated];
}

- (void)didSelectSegment:(UIButton *)sender {
    NSInteger index = sender.tag;
    [self.delegate radialMenuView:self didSelectIndex:index];
}

@end
