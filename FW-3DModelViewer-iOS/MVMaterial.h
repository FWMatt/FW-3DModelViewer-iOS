//
//  MVMaterial.h
//  3D Model Viewer
//
//  Created by Kamil Kocemba on 17/12/2012.
//  Copyright (c) 2012 Future Workshops. All rights reserved.
//

@interface MVMaterial : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) GLKVector4 ambient, diffuse, specular;
@property (nonatomic, assign) CGFloat shininess;

- (void)bind:(GLenum)side;

@end
