//
//  FWMVGLView.m
//  FW-3DModelViewer-iOS
//
//  Created by Tim Chilvers on 22/11/2012.
//  Copyright (c) 2012 Future Workshops. All rights reserved.
//

#import "FWMVGLView.h"
#import "GLModel.h"

@interface FWMVGLView ()

@property (nonatomic,retain,readwrite) GLModel *model;

@end

@implementation FWMVGLView

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

- (void)useModelNamed:(NSString *)modelName {
    self.model = [GLModel modelNamed:modelName];
}

@end
