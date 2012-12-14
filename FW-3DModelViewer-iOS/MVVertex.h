//
//  MVVertex.h
//  3D Model Viewer
//
//  Created by Kamil Kocemba on 18/12/2012.
//  Copyright (c) 2012 Future Workshops. All rights reserved.
//

#import <set>

@class MVFace;

struct VertexGeometry {
    GLKVector3 position;
    GLKVector3 normal;
};

@interface MVVertex : NSObject {
    VertexGeometry geometry;
    std::set<MVFace *> faces;
}

- (id)initWithPosition:(GLKVector3)position;

- (const std::set<MVFace *> &) faces;
- (const VertexGeometry &) geometry;

- (void)addFaceObject:(MVFace *)face;
- (void)calculateNormal;

@end
