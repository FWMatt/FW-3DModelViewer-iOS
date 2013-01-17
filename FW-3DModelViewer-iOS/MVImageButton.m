//
//  MVImageButton.m
//  3D Model Viewer
//
//  Created by Kamil Kocemba on 17/01/2013.
//  Copyright (c) 2013 Future Workshops. All rights reserved.
//

#import "MVImageButton.h"

@interface MVImageButton ()

@property (nonatomic, assign) const UInt8 *pixelData;
@property (nonatomic, assign) NSUInteger bytesPerRow;

@end

@implementation MVImageButton


- (void)setImage:(UIImage *)image forState:(UIControlState)state {
    if (state == UIControlStateNormal) {
        CFDataRef pixelData = CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage));
        size_t length = CFDataGetLength(pixelData);
        self.bytesPerRow = length / image.size.height / 4;
        self.pixelData = (const UInt8 *)CFDataGetBytePtr(pixelData);
    }
    [super setImage:image forState:state];
}

- (void)dealloc {
    CFRelease(self.pixelData);
}

#pragma mark - Hit Test

- (BOOL)point:(CGPoint)point visibleForImage:(UIImage *)image {
    point.x *= image.size.width / self.bounds.size.width;
    point.y *= image.size.height / self.bounds.size.height;
    NSInteger idx = ((self.bytesPerRow * point.y) + point.x) * 4;
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
