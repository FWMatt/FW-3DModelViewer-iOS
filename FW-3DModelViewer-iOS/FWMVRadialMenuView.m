//
//  FWMVRadialMenuView.m
//  FW-3DModelViewer-iOS
//
//  Created by Tim Chilvers on 27/11/2012.
//  Copyright (c) 2012 Future Workshops. All rights reserved.
//

#import "FWMVRadialMenuView.h"

@implementation FWMVRadialMenuView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (CGColorRef)colorForIndex:(NSInteger)index {
    switch (index) {
        case 0:
            return [UIColor redColor].CGColor;
            break;
        case 1:
            return [UIColor greenColor].CGColor;
            break;
        case 2:
            return [UIColor purpleColor].CGColor;
            break;
        case 3:
            return [UIColor grayColor].CGColor;
            break;
        default:
            return [UIColor whiteColor].CGColor;
            break;
    }
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
