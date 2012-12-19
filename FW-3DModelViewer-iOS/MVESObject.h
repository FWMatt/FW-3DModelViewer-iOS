//
//  MVESObject.h
//  3D Model Viewer
//
//  Created by Kamil Kocemba on 19/12/2012.
//  Copyright (c) 2012 Future Workshops. All rights reserved.
//

@protocol MVESObject <NSObject>

@required
- (void)setProjectionMatrix:(GLKMatrix4)projection;
- (void)setModelviewMatrix:(GLKMatrix4)modelview;

- (void)draw;

@end
