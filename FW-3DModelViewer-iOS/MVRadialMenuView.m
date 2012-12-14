//
//  MVRadialMenuView.m
//  3D Model Viewer
//
//  Created by Tim Chilvers on 27/11/2012.
//  Copyright (c) 2012 Future Workshops. All rights reserved.
//

#import "MVRadialMenuView.h"

@implementation MVRadialMenuView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu-bg"]];
        [self addSubview:backgroundView];
    }
    return self;
}

- (NSInteger)segmentIndexForPoint:(CGPoint)inputPoint { // UNTESTED!!
    assert(CGRectContainsPoint(self.bounds, inputPoint) && self.numberOfSegments > 0);
    CGPoint bottomLeftPoint = CGPointMake(inputPoint.x, self.bounds.size.height - inputPoint.y);
    CGFloat coeff = fabsf(bottomLeftPoint.y / bottomLeftPoint.x);
    CGFloat theta = asinf(coeff);
    if(coeff > 1.0f) {
        coeff = 1.0f / coeff;
        theta = asinf(coeff);
        theta = M_PI_4 - theta;
    }
    return (NSInteger) (fabsf(theta) / (M_PI_2 / self.numberOfSegments));
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.delegate radialMenuView:self didSelectIndex:0];
    return;
}

@end
