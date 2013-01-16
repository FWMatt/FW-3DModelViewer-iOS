//
//  MVMenuButton.m
//  3D Model Viewer
//
//  Created by Kamil Kocemba on 21/12/2012.
//  Copyright (c) 2012 Future Workshops. All rights reserved.
//

#import "MVMenuButton.h"

@interface MVMenuButton ()

@property (nonatomic, assign) const UInt8 *pixelData;

@end

@implementation MVMenuButton

- (id)initWithIndex:(NSInteger)index count:(NSInteger)count title:(NSString *)title {
    if (self = [super initWithFrame:CGRectZero]) {
        UIImage *image = [self imageForIndex:index count:count title:(NSString *)title];
        [self setImage:image forState:UIControlStateNormal];
    }
    return self;
}


- (UIImage *)imageForIndex:(NSInteger)index count:(NSInteger)count title:(NSString *)title {
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGSize size = CGSizeMake(280 * scale, 280 * scale);
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
    
    CGFloat w[3] = {
        155.0f * scale, 20.0f * scale, 100.0f * scale
    };
    CGFloat span = M_PI_2 / count;
    CGFloat a1 = -M_PI_2 + span * index, a2 = -M_PI_2 + span * (index + 1);
    
    CGSize shadowSize = CGSizeMake(0, 0);
    CGFloat blurRadius = 1.0f * scale;
    CGContextSetShadowWithColor(context, shadowSize, blurRadius, [UIColor colorWithRed:240.0f / 255.0f green:240.0f blue:240.0f alpha:1.0f].CGColor);
    
    CGContextBeginPath(context);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:25.0f / 255.0f green:25.0f / 255.0f blue:25.0f / 255.0f alpha:1.0f].CGColor);
    CGContextSetLineWidth(context, w[2]);
    CGContextAddArc(context, 0.0f, size.height, w[0] + w[1] + 0.5f * w[2], a1, a2, 0);
    CGContextStrokePath(context);
    
    CGContextBeginPath(context);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:49.0f / 255.0f green:49.0f / 255.0f blue:49.0f / 255.0f alpha:1.0f].CGColor);
    CGContextSetLineWidth(context, w[1]);
    CGContextAddArc(context, 0.0f, size.height, w[0] + 0.5f * w[1], a1, a2, 0);
    CGContextStrokePath(context);

    CGContextSaveGState(context);
    CGFloat angle = span * (index + 1);
    CGFloat transX = (w[0] + w[1]) * sin(angle);
    CGFloat transY = w[2] + (w[1] + w[0] - (w[0] + w[1]) * cos(angle));
    CGContextTranslateCTM(context, transX, transY);
    CGContextRotateCTM(context, a2);

    UIFont *font = [UIFont fontWithName:@"AndaleMono" size:30];
    [[UIColor whiteColor] set];
    [title drawAtPoint:CGPointMake(5, -35) forWidth:400 withFont:font fontSize:30 lineBreakMode:NSLineBreakByClipping baselineAdjustment:UIBaselineAdjustmentAlignCenters];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CFDataRef pixelData = CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage));
    self.pixelData = CFDataGetBytePtr(pixelData);
    UIGraphicsEndImageContext();
    return image;
}

- (void)dealloc {
    CFRelease(self.pixelData);
}

#pragma mark - Hit Test

- (BOOL)point:(CGPoint)point visibleForImage:(UIImage *)image {
    point.x *= image.size.width / self.bounds.size.width;
    point.y *= image.size.height / self.bounds.size.height;
    NSInteger idx = ((image.size.width * point.y) + point.x) * 4;
    UInt8 alpha = self.pixelData[idx + 3];
    const CGFloat threshold = 10;
    return alpha >= threshold;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (![super pointInside:point withEvent:event]) {
        return NO;
    }
    UIImage *image = [self imageForState:UIControlStateNormal];
    return ([self point:point visibleForImage:image]);
}

@end
