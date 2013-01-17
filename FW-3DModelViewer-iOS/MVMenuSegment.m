//
//  MVMenuSegment.m
//  3D Model Viewer
//
//  Created by Kamil Kocemba on 21/12/2012.
//  Copyright (c) 2012 Future Workshops. All rights reserved.
//

#import "MVMenuSegment.h"
#import <QuartzCore/QuartzCore.h>

@implementation MVMenuSegment

- (id)initWithIndex:(NSInteger)index count:(NSInteger)count title:(NSString *)title {
    if (self = [super initWithFrame:CGRectZero]) {
        UIImage *image = [self imageForIndex:index count:count title:title];
        [self setImage:image forState:UIControlStateNormal];
    }
    return self;
}


- (UIImage *)imageForIndex:(NSInteger)index count:(NSInteger)count title:(NSString *)title {
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGSize size = CGSizeMake(255 * scale, 255 * scale);
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
        
    CGFloat w[3] = {
        130.0f * scale, 90.0f * scale, 30.0f * scale
    };
    CGFloat span = M_PI_2 / count;
    CGFloat a1 = -M_PI_2 + span * index, a2 = -M_PI_2 + span * (index + 1);
    
    UIColor *outerColor = [UIColor colorWithRed:222.0f / 255.0f green:222.0f / 255.0f blue:222.0f / 255.0f alpha:1.0f];
    CGContextBeginPath(context);
    CGContextSetStrokeColorWithColor(context, outerColor.CGColor);
    CGContextSetLineWidth(context, w[2]);
    CGContextAddArc(context, 0.0f, size.height, w[0] + w[1] + 0.5f * w[2], a1, a2, 0);
    CGContextStrokePath(context);
    
    UIColor *innerColor = [UIColor colorWithRed:46.0f / 255.0f green:41.0f / 255.0f blue:41.0f / 255.0f alpha:1.0f];
    CGContextBeginPath(context);
    CGContextSetStrokeColorWithColor(context, innerColor.CGColor);
    CGContextSetLineWidth(context, w[1]);
    CGContextAddArc(context, 0.0f, size.height, w[0] + 0.5f * w[1], a1, a2, 0);
    CGContextStrokePath(context);

    CGContextSaveGState(context);
    CGFloat angle = span * (index + 0.5f);
    CGFloat inner = w[0], outer = w[1]  + w[2];
    
    CGFloat transX = inner * sin(angle);
    CGFloat transY = outer + inner * (1 - cos(angle));
    CGContextTranslateCTM(context, transX, transY + 20);
    CGContextRotateCTM(context, -M_PI_2 + angle);

    const CGFloat fontSize = 10.0f * scale;
    UIFont *font = [UIFont fontWithName:@"Avenir-Roman" size:fontSize];
    [[UIColor whiteColor] set];
    NSString *text = [title uppercaseString];
    CGSize textSize = [text sizeWithFont:font];
    CGFloat offset = 2.5 * scale;
    [text drawAtPoint:CGPointMake((w[1] - textSize.width) / 2.0 + offset, -textSize.height / 2.0) forWidth:200 * scale withFont:font fontSize:fontSize lineBreakMode:NSLineBreakByClipping baselineAdjustment:UIBaselineAdjustmentAlignCenters];
        
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
    
    return image;
}

@end
