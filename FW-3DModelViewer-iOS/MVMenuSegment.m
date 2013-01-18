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
//        if (index == 3) {
//            UIImage *image = [self highlightedImageForIndex:index count:count title:title];
//            [self setImage:image forState:UIControlStateNormal];
//        } else {
            UIImage *image = [self imageForIndex:index count:count title:title];
            [self setImage:image forState:UIControlStateNormal];
            UIImage *highlightedImage = [self highlightedImageForIndex:index count:count title:title];
            [self setImage:highlightedImage forState:UIControlStateHighlighted];
//        }
    }
    return self;
}


- (UIImage *)imageForIndex:(NSInteger)index count:(NSInteger)count title:(NSString *)title {
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGSize size = CGSizeMake(255 * scale, 255 * scale);
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
        
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

    
//    CGContextTranslateCTM(context, 150, 350);
//    
//    UIBezierPath *path = [[UIBezierPath alloc] init];
//    [path moveToPoint:CGPointMake(0, w[1])];
//    [path addArcWithCenter:CGPointMake(0, 0) radius:w[1] startAngle:-M_PI_2 endAngle:-M_PI_2 + M_PI_4 clockwise:YES];
//     [[UIColor redColor] set];
//    [path stroke];
    
    CGContextSaveGState(context);
    CGFloat angle = span * (index + 0.5f);
    CGFloat inner = w[0], outer = w[1]  + w[2];
    
    CGFloat transX = inner * sin(angle);
    CGFloat transY = outer + inner * (1 - cos(angle));
    CGContextTranslateCTM(context, transX, transY + 20);
    CGContextRotateCTM(context, -M_PI_2 + angle);

    const CGFloat fontSize = 10.0f * scale;
    UIFont *font = [UIFont fontWithName:@"Avenir-Roman" size:fontSize];
    [outerColor set];
    NSString *text = [title uppercaseString];
    CGSize textSize = [text sizeWithFont:font];
    CGFloat offset = 2.5 * scale;
    [text drawAtPoint:CGPointMake((w[1] - textSize.width) / 2.0 + offset, -textSize.height / 2.0) forWidth:200 * scale withFont:font fontSize:fontSize lineBreakMode:NSLineBreakByClipping baselineAdjustment:UIBaselineAdjustmentAlignCenters];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)highlightedImageForIndex:(NSInteger)index count:(NSInteger)count title:(NSString *)title {
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGSize size = CGSizeMake(255 * scale, 255 * scale);
    
    
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 1.0f * scale, 0.0f);
        
    CGFloat w[3] = {
        130.0f * scale, 90.0f * scale, 30.0f * scale
    };
    CGFloat span = M_PI_2 / count;
    CGFloat a1 = -M_PI_2 + span * index, a2 = -M_PI_2 + span * (index + 1);
    
    UIColor *outerColor = [UIColor colorWithRed:228.0f / 255.0f green:129.0f / 255.0f blue:24.0f / 255.0f alpha:1.0f];
    CGContextBeginPath(context);
    CGContextSetStrokeColorWithColor(context, outerColor.CGColor);
    CGContextSetLineWidth(context, w[2]);
    CGContextAddArc(context, 0.0f, size.height, w[0] + w[1] + 0.5f * w[2], a1, a2, 0);
    CGContextStrokePath(context);
    
    UIColor *innerColor = [UIColor colorWithRed:42.0f / 255.0f green:38.0f / 255.0f blue:39.0f / 255.0f alpha:1.0f];
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
    [outerColor set];
    NSString *text = [title uppercaseString];
    CGSize textSize = [text sizeWithFont:font];
    CGFloat offset = 2.5 * scale;
    
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, CGSizeZero, 10.0f * scale, outerColor.CGColor);
    
    [text drawAtPoint:CGPointMake((w[1] - textSize.width) / 2.0 + offset, -textSize.height / 2.0) forWidth:200 * scale withFont:font fontSize:fontSize lineBreakMode:NSLineBreakByClipping baselineAdjustment:UIBaselineAdjustmentAlignCenters];
    
    CGContextRestoreGState(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
